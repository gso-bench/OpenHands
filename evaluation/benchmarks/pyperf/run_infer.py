import asyncio
import json
import os
import tempfile
from typing import Any

import numpy as np
import pandas as pd
import toml
from datasets import load_dataset

import openhands.agenthub
from evaluation.utils.shared import (
    EvalException,
    EvalMetadata,
    EvalOutput,
    assert_and_raise,
    codeact_user_response,
    get_metrics,
    is_fatal_evaluation_error,
    make_metadata,
    prepare_dataset,
    reset_logger_for_multiprocessing,
    run_evaluation,
    update_llm_config_for_completions_logging,
)
from openhands.controller.state.state import State
from openhands.core.config import (
    AgentConfig,
    AppConfig,
    SandboxConfig,
    get_llm_config_arg,
    get_parser,
)
from openhands.core.logger import openhands_logger as logger
from openhands.core.main import create_runtime, run_controller
from openhands.events.action import CmdRunAction, MessageAction
from openhands.events.observation import CmdOutputObservation, ErrorObservation
from openhands.events.serialization.event import event_to_dict
from openhands.runtime.base import Runtime
from openhands.utils.async_utils import call_async_from_sync
from openhands.utils.shutdown_listener import sleep_if_should_continue

USE_HINT_TEXT = os.environ.get('USE_HINT_TEXT', 'false').lower() == 'true'
RUN_WITH_BROWSING = os.environ.get('RUN_WITH_BROWSING', 'false').lower() == 'true'
USE_INSTALL_COMMANDS = True

AGENT_CLS_TO_FAKE_USER_RESPONSE_FN = {
    'CodeActAgent': codeact_user_response,
}

DOCKER_IMAGE_PREFIX = os.environ.get(
    'EVAL_DOCKER_IMAGE_PREFIX', 'docker.io/slimshetty/'
)
logger.info(f'Using docker image prefix: {DOCKER_IMAGE_PREFIX}')


def _get_pyperf_instance_docker_image(instance_id: str) -> str:
    image_name = 'pyperf:pyperf.eval.x86_64.' + instance_id
    return (DOCKER_IMAGE_PREFIX.rstrip('/') + '/' + image_name).lower()


def _get_pyperf_workspace_dir_name(instance: pd.Series) -> str:
    return f'{instance.repo}'.replace('/', '__')


def _get_pyperf_repo_install_script(instance: pd.Series) -> list[str]:
    filter_set = ['git clean -xfd', 'which python', 'python --version', 'uv venv']
    install_cmds = instance.install_commands
    filtered_cmds = [
        cmd for cmd in install_cmds if not any(cmd.startswith(f) for f in filter_set)
    ]

    # also strip 'git clean -xfd' if it is part of any command
    filtered_cmds = [
        cmd.replace('git clean -xfd &&', '').strip() for cmd in filtered_cmds
    ]
    return filtered_cmds


############################################## MAIN SCRIPT ######################################################


def get_instruction(instance: pd.Series, metadata: EvalMetadata):
    workspace_dir_name = _get_pyperf_workspace_dir_name(instance)
    # Prepare instruction
    instruction = (
        '<uploaded_files>\n'
        f'/workspace/{workspace_dir_name}\n'
        '</uploaded_files>\n'
        f"I've uploaded a python code repository in the directory {workspace_dir_name}. Consider the following test script showing an example usage of the repository:\n\n"
        f'<test_script>\n'
        f'{instance.prob_script}\n'
        '</test_script>\n\n'
        'Can you help me implement the necessary changes to the repository so that the runtime of the <test_script> is optimized?\n'
        'Your task is to make changes to non-tests files in the /workspace directory to improve the performance of the <test_script>.\n'
        'While making changes you must ensuring the repository is functionally equivalent to the original.\n'
        'Follow these steps to improve performance:\n'
        '1. As a first step, it might be a good idea to explore the repo to familiarize yourself with its structure.\n'
        '2. Create a script in the /workspace directory (e.g., /workspace/test_opt.py) to reproduce and time the example and execute it with `python /workspace/<filename.py>` using the BashTool.\n'
        '3. Edit the sourcecode of the repo to improve the performance\n'
        '4. Rerun your script and confirm that the performance has improved!\n'
        "Your thinking should be thorough and so it's fine if it's very long.\n"
    )

    if USE_INSTALL_COMMANDS:
        instruction += (
            f'\nTo rebuild the repo with your changes at any point, you can use the following in the {workspace_dir_name} directory:\n'
            f'```\n{instance['install_commands']}\n```\n'
        )

    if RUN_WITH_BROWSING:
        instruction += (
            '<IMPORTANT!>\n'
            'You SHOULD NEVER attempt to browse the web. '
            '</IMPORTANT!>\n'
        )
    return instruction


def get_config(
    instance: pd.Series,
    metadata: EvalMetadata,
) -> AppConfig:
    base_container_image = _get_pyperf_instance_docker_image(instance['instance_id'])
    logger.info(
        f'Using instance container image: {base_container_image}. '
        f'Please make sure this image exists. '
        f'Submit an issue on https://github.com/All-Hands-AI/OpenHands if you run into any issues.'
    )

    config = AppConfig(
        default_agent=metadata.agent_class,
        run_as_openhands=False,
        max_iterations=metadata.max_iterations,
        runtime=os.environ.get('RUNTIME', 'docker'),
        sandbox=SandboxConfig(
            base_container_image=base_container_image,
            enable_auto_lint=True,
            use_host_network=False,
            # large enough timeout, since some testcases take very long to run
            timeout=300,
            # Add platform to the sandbox config to solve issue 4401
            platform='linux/amd64',
            api_key=os.environ.get('ALLHANDS_API_KEY', None),
            remote_runtime_api_url=os.environ.get('SANDBOX_REMOTE_RUNTIME_API_URL'),
            keep_runtime_alive=False,
            remote_runtime_init_timeout=3600,
            remote_runtime_api_timeout=120,
            # remote_runtime_resource_factor=get_instance_resource_factor(
            #     dataset_name=metadata.dataset,
            #     instance_id=instance['instance_id'],
            # ),
            remote_runtime_enable_retries=True,
        ),
        # do not mount workspace
        workspace_base=None,
        workspace_mount_path=None,
    )
    config.set_llm_config(
        update_llm_config_for_completions_logging(
            metadata.llm_config, metadata.eval_output_dir, instance['instance_id']
        )
    )
    agent_config = AgentConfig(
        codeact_enable_jupyter=False,
        codeact_enable_browsing=RUN_WITH_BROWSING,
        codeact_enable_llm_editor=False,
        condenser=metadata.condenser_config,
        enable_prompt_extensions=False,
    )
    config.set_agent_config(agent_config)
    return config


def initialize_runtime(
    runtime: Runtime,
    instance: pd.Series,  # this argument is not required
):
    """Initialize the runtime for the agent.

    This function is called before the runtime is used to run the agent.
    """
    logger.info('-' * 30)
    logger.info('BEGIN Runtime Initialization Fn')
    logger.info('-' * 30)
    workspace_dir_name = _get_pyperf_workspace_dir_name(instance)
    obs: CmdOutputObservation

    # Set instance id
    action = CmdRunAction(
        command=f"""echo 'export PYPERF_INSTANCE_ID={instance['instance_id']}' >> ~/.bashrc && echo 'export PIP_CACHE_DIR=~/.cache/pip' >> ~/.bashrc && echo "alias git='git --no-pager'" >> ~/.bashrc"""
    )
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0, f'Failed to export PYPERF_INSTANCE_ID: {str(obs)}'
    )

    action = CmdRunAction(command="""export USER=$(whoami); echo USER=${USER} """)
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(obs.exit_code == 0, f'Failed to export USER: {str(obs)}')

    # inject the init script
    script_dir = os.path.dirname(__file__)

    # inject the instance info
    action = CmdRunAction(command='mkdir -p /pyperf_util/eval_data/instances')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0,
        f'Failed to create /pyperf_util/eval_data/instances: {str(obs)}',
    )

    pyperf_instance_json_name = 'pyperf-instance.json'
    with tempfile.TemporaryDirectory() as temp_dir:
        # Construct the full path for the desired file name within the temporary directory
        temp_file_path = os.path.join(temp_dir, pyperf_instance_json_name)
        # Write to the file with the desired name within the temporary directory
        with open(temp_file_path, 'w') as f:
            if not isinstance(instance, dict):
                json.dump([instance.to_dict()], f)
            else:
                json.dump([instance], f)

        # Copy the file to the desired location
        runtime.copy_to(temp_file_path, '/pyperf_util/eval_data/instances/')

    # inject the instance pyperf entry
    runtime.copy_to(
        str(os.path.join(script_dir, 'scripts/setup/instance_pyperf_entry.sh')),
        '/pyperf_util/',
    )

    # HACK: comment out the source .venv/bin/activate in .bashrc
    # NOTE: this is needed just because OH's runtime expects some special workspace not just /testbed
    action = CmdRunAction(
        command=r"""sed -i 's#source .venv/bin/activate#\#source .venv/bin/activate#g' ~/.bashrc"""
    )
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0,
        f'Failed to comment out source .venv/bin/activate: {str(obs)}',
    )

    action = CmdRunAction(command='source /pyperf_util/instance_pyperf_entry.sh')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0,
        f'Failed to source /pyperf_util/instance_pyperf_entry.sh: {str(obs)}',
    )

    action = CmdRunAction(command=f'cd /workspace/{workspace_dir_name}')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0,
        f'Failed to cd to /workspace/{workspace_dir_name}: {str(obs)}',
    )

    # HACK: setup the env using source .venv/bin/activate
    # Force new shell to source .venv/bin/activate and activate the env in which repo is installed
    action = CmdRunAction(command='source .venv/bin/activate')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    assert_and_raise(
        obs.exit_code == 0, f'Failed to source .venv/bin/activate: {str(obs)}'
    )

    action = CmdRunAction(command='which python')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        obs.exit_code == 0 and 'testbed' in obs.content,
        f'Expected to find python interpreter from testbed, but got: {str(obs)}',
    )

    logger.info('-' * 30)
    logger.info('END Runtime Initialization Fn')
    logger.info('-' * 30)


def complete_runtime(
    runtime: Runtime,
    instance: pd.Series,  # this argument is not required, but it is used to get the workspace_dir_name
) -> dict[str, Any]:
    """Complete the runtime for the agent.

    This function is called before the runtime is used to run the agent.
    If you need to do something in the sandbox to get the correctness metric after
    the agent has run, modify this function.
    """
    logger.info('-' * 30)
    logger.info('BEGIN Runtime Completion Fn')
    logger.info('-' * 30)
    obs: CmdOutputObservation
    workspace_dir_name = _get_pyperf_workspace_dir_name(instance)

    action = CmdRunAction(command=f'cd /workspace/{workspace_dir_name}')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        isinstance(obs, CmdOutputObservation) and obs.exit_code == 0,
        f'Failed to cd to /workspace/{workspace_dir_name}: {str(obs)}',
    )

    action = CmdRunAction(command='git config --global core.pager ""')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        isinstance(obs, CmdOutputObservation) and obs.exit_code == 0,
        f'Failed to git config --global core.pager "": {str(obs)}',
    )

    action = CmdRunAction(command='git add -A')
    action.set_hard_timeout(600)
    logger.info(action, extra={'msg_type': 'ACTION'})
    obs = runtime.run_action(action)
    logger.info(obs, extra={'msg_type': 'OBSERVATION'})
    assert_and_raise(
        isinstance(obs, CmdOutputObservation) and obs.exit_code == 0,
        f'Failed to git add -A: {str(obs)}',
    )

    n_retries = 0
    git_patch = None
    while n_retries < 5:
        action = CmdRunAction(
            command=f'git diff --no-color --cached {instance["base_commit"]}'
        )
        action.set_hard_timeout(max(300 + 100 * n_retries, 600))
        logger.info(action, extra={'msg_type': 'ACTION'})
        obs = runtime.run_action(action)
        logger.info(obs, extra={'msg_type': 'OBSERVATION'})
        n_retries += 1
        if isinstance(obs, CmdOutputObservation):
            if obs.exit_code == 0:
                git_patch = obs.content.strip()
                break
            else:
                logger.info('Failed to get git diff, retrying...')
                sleep_if_should_continue(10)
        elif isinstance(obs, ErrorObservation):
            logger.error(f'Error occurred: {obs.content}. Retrying...')
            sleep_if_should_continue(10)
        else:
            assert_and_raise(False, f'Unexpected observation type: {str(obs)}')

    assert_and_raise(git_patch is not None, 'Failed to get git diff (None)')

    logger.info('-' * 30)
    logger.info('END Runtime Completion Fn')
    logger.info('-' * 30)
    return {'git_patch': git_patch}


def process_instance(
    instance: pd.Series,
    metadata: EvalMetadata,
    reset_logger: bool = True,
    runtime_failure_count: int = 0,
) -> EvalOutput:
    config = get_config(instance, metadata)

    # format install commands
    instance['install_commands'] = _get_pyperf_repo_install_script(instance)
    instance = instance.apply(
        lambda x: ('\n'.join(x) if isinstance(x, (np.ndarray, list)) else x)
    )

    # Setup the logger properly, so you can run multi-processing to parallelize the evaluation
    if reset_logger:
        log_dir = os.path.join(metadata.eval_output_dir, 'infer_logs')
        reset_logger_for_multiprocessing(logger, instance.instance_id, log_dir)
    else:
        logger.info(f'Starting evaluation for instance {instance.instance_id}.')

    runtime = create_runtime(config)
    call_async_from_sync(runtime.connect)

    try:
        initialize_runtime(runtime, instance)
        instruction = get_instruction(instance, metadata)

        # Here's how you can run the agent (similar to the `main` function) and get the final task state
        state: State | None = asyncio.run(
            run_controller(
                config=config,
                initial_user_action=MessageAction(content=instruction),
                runtime=runtime,
                fake_user_response_fn=AGENT_CLS_TO_FAKE_USER_RESPONSE_FN[
                    metadata.agent_class
                ],
            )
        )

        # if fatal error, throw EvalError to trigger re-run
        if is_fatal_evaluation_error(state.last_error):
            raise EvalException('Fatal error detected: ' + state.last_error)

        # ======= THIS IS PYPERF specific =======
        # Get git patch
        return_val = complete_runtime(runtime, instance)
        git_patch = return_val['git_patch']
        logger.info(
            f'Got git diff for instance {instance.instance_id}:\n--------\n{git_patch}\n--------'
        )
    finally:
        runtime.close()
    # ==========================================

    test_result = {'git_patch': git_patch}

    if state is None:
        raise ValueError('State should not be None.')

    histories = [event_to_dict(event) for event in state.history]
    metrics = get_metrics(state)

    # Save the output
    output = EvalOutput(
        instance_id=instance.instance_id,
        instruction=instruction,
        instance=instance.to_dict(),  # PYPERF Bench specific
        test_result=test_result,
        metadata=metadata,
        history=histories,
        metrics=metrics,
        error=state.last_error if state and state.last_error else None,
    )
    return output


def filter_dataset(dataset: pd.DataFrame, filter_column: str) -> pd.DataFrame:
    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config.toml')
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            data = toml.load(file)
            if 'selected_ids' in data:
                selected_ids = data['selected_ids']
                logger.info(
                    f'Filtering {len(selected_ids)} tasks from "selected_ids"...'
                )
                subset = dataset[dataset[filter_column].isin(selected_ids)]
                logger.info(f'Retained {subset.shape[0]} tasks after filtering')
                return subset
    skip_ids = os.environ.get('SKIP_IDS', '').split(',')
    if len(skip_ids) > 0:
        logger.info(f'Filtering {len(skip_ids)} tasks from "SKIP_IDS"...')
        return dataset[~dataset[filter_column].isin(skip_ids)]
    return dataset


if __name__ == '__main__':
    parser = get_parser()
    parser.add_argument(
        '--dataset',
        type=str,
        default='manishs/pyperf',
        help='data set to evaluate on',
    )
    parser.add_argument(
        '--split',
        type=str,
        default='test',
        help='split to evaluate on',
    )
    args, _ = parser.parse_known_args()

    dataset = load_dataset(args.dataset, split=args.split)
    pyperf_tests = filter_dataset(dataset.to_pandas(), 'instance_id')
    logger.info(
        f'Loaded dataset {args.dataset} with split {args.split}: {len(pyperf_tests)} tasks'
    )

    llm_config = None
    if args.llm_config:
        llm_config = get_llm_config_arg(args.llm_config)
        llm_config.log_completions = True
        # modify_params must be False for evaluation purpose, for reproducibility and accurancy of results
        llm_config.modify_params = False

    if llm_config is None:
        raise ValueError(f'Could not find LLM config: --llm_config {args.llm_config}')

    details = {}
    _agent_cls = openhands.agenthub.Agent.get_cls(args.agent_cls)

    dataset_descrption = (
        args.dataset.replace('/', '__') + '-' + args.split.replace('/', '__')
    )
    metadata = make_metadata(
        llm_config,
        dataset_descrption,
        args.agent_cls,
        args.max_iterations,
        args.eval_note,
        args.eval_output_dir,
        details=details,
    )

    output_file = os.path.join(metadata.eval_output_dir, 'output.jsonl')
    print(f'### OUTPUT FILE: {output_file} ###')
    instances = prepare_dataset(pyperf_tests, output_file, args.eval_n_limit)

    run_evaluation(
        instances,
        metadata,
        output_file,
        args.eval_num_workers,
        process_instance,
        timeout_seconds=120 * 60,  # 2 hour PER instance should be more than enough
        max_retries=5,
    )

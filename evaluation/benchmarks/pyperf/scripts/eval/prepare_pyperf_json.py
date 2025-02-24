import argparse
import os

import pandas as pd

from evaluation.benchmarks.swe_bench.eval_infer import process_git_patch

parser = argparse.ArgumentParser()
parser.add_argument('oh_output_files', type=str, nargs='+')
args = parser.parse_args()


def convert_row_to_pyperf_format(row):
    if 'git_patch' in row:
        model_patch = row['git_patch']
    elif 'test_result' in row and 'git_patch' in row['test_result']:
        model_patch = row['test_result']['git_patch']
    else:
        print(f'WARNING: Row {row} does not have a git_patch')
        model_patch = ''

    return {
        'instance_id': row['instance_id'],
        'model_patch': process_git_patch(model_patch),
        'model_name_or_path': model_name,
    }


if len(args.oh_output_files) > 1 or os.path.isdir(args.oh_output_files[0]):
    args.oh_output_files = [d for d in args.oh_output_files if os.path.isdir(d)]
    print(f'Processing run directories: {len(args.oh_output_files)}')

    for run_dir in args.oh_output_files:
        input_file = os.path.join(run_dir, 'output.jsonl')
        if not os.path.exists(input_file):
            continue

        oh_format = pd.read_json(input_file, orient='records', lines=True)
        model_name = os.path.basename(run_dir)
        results = oh_format.apply(convert_row_to_pyperf_format, axis=1)

        output_filepath = os.path.join(run_dir, 'output.pyperf.jsonl')
        results.to_json(output_filepath, lines=True, orient='records')
        print(f'Wrote results to {output_filepath}')

else:
    output_filepath = args.oh_output_files[0].replace('.jsonl', '.pyperf.jsonl')
    print(f'Converting {args.oh_output_files[0]} to {output_filepath}')
    oh_format = pd.read_json(args.oh_output_files[0], orient='records', lines=True)
    model_name = os.path.basename(os.path.dirname(args.oh_output_files[0]))
    pyperf_format = oh_format.apply(convert_row_to_pyperf_format, axis=1)
    pyperf_format.to_json(output_filepath, lines=True, orient='records')

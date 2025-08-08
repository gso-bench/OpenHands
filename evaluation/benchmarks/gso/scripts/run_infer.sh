#!/bin/bash
set -eo pipefail

source "evaluation/utils/version_control.sh"

# Default values
COMMIT_HASH="HEAD"
AGENT="CodeActAgent"
MAX_ITER=50
NUM_WORKERS=1
DATASET="gso-bench/gso"
SPLIT="test"
USE_INSTANCE_IMAGE=true
RUN_WITH_BROWSING=false
N_RUNS=1
USE_HINT_TEXT=false
USE_PLANS=false
PLAN_TYPE="none"
PLAN_ID=0

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --model-config)
      MODEL_CONFIG="$2"
      shift 2
      ;;
    --commit-hash)
      COMMIT_HASH="$2"
      shift 2
      ;;
    --agent)
      AGENT="$2"
      shift 2
      ;;
    --eval-limit)
      EVAL_LIMIT="$2"
      shift 2
      ;;
    --max-iter)
      MAX_ITER="$2"
      shift 2
      ;;
    --num-workers)
      NUM_WORKERS="$2"
      shift 2
      ;;
    --dataset)
      DATASET="$2"
      shift 2
      ;;
    --split)
      SPLIT="$2"
      shift 2
      ;;
    --n-runs)
      N_RUNS="$2"
      shift 2
      ;;
    --use-instance-image)
      USE_INSTANCE_IMAGE="$2"
      shift 2
      ;;
    --run-with-browsing)
      RUN_WITH_BROWSING="$2"
      shift 2
      ;;
    --use-hint-text)
      USE_HINT_TEXT="$2"
      shift 2
      ;;
    --use-plans)
      USE_PLANS="$2"
      shift 2
      ;;
    --plan-type)
      PLAN_TYPE="$2"
      shift 2
      ;;
    --plan-id)
      PLAN_ID="$2"
      shift 2
      ;;
    --exp-name)
      EXP_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [ -z "$MODEL_CONFIG" ]; then
  echo "Error: --model-config is required"
  exit 1
fi

checkout_eval_branch

export USE_INSTANCE_IMAGE=$USE_INSTANCE_IMAGE
echo "USE_INSTANCE_IMAGE: $USE_INSTANCE_IMAGE"
export RUN_WITH_BROWSING=$RUN_WITH_BROWSING
echo "RUN_WITH_BROWSING: $RUN_WITH_BROWSING"
export USE_PLANS=$USE_PLANS
echo "USE_PLANS: $USE_PLANS"
export PLAN_TYPE=$PLAN_TYPE
echo "PLAN_TYPE: $PLAN_TYPE"
export PLAN_ID=$PLAN_ID
echo "PLAN_ID: $PLAN_ID"


get_openhands_version

echo "AGENT: $AGENT"
echo "OPENHANDS_VERSION: $OPENHANDS_VERSION"
echo "MODEL_CONFIG: $MODEL_CONFIG"
echo "DATASET: $DATASET"
echo "SPLIT: $SPLIT"

echo "USE_HINT_TEXT: $USE_HINT_TEXT"
EVAL_NOTE="$OPENHANDS_VERSION"
# if not using Hint, add -no-hint to the eval note
if [ "$USE_HINT_TEXT" = false ]; then
  EVAL_NOTE="$EVAL_NOTE-no-hint"
fi

if [ "$USE_PLANS" = true ]; then
  echo "USE_PLANS: $USE_PLANS"
  echo "PLAN_TYPE: $PLAN_TYPE"
  echo "PLAN_ID: $PLAN_ID"
  EVAL_NOTE="$EVAL_NOTE-$PLAN_TYPE-$PLAN_ID"
fi

if [ "$RUN_WITH_BROWSING" = true ]; then
  EVAL_NOTE="$EVAL_NOTE-with-browsing"
fi

if [ -n "$EXP_NAME" ]; then
  EVAL_NOTE="$EVAL_NOTE-$EXP_NAME"
fi

function run_eval() {
  local eval_note=$1
  COMMAND="poetry run python evaluation/benchmarks/gso/run_infer.py \
    --agent-cls $AGENT \
    --llm-config $MODEL_CONFIG \
    --max-iterations $MAX_ITER \
    --eval-num-workers $NUM_WORKERS \
    --eval-note $eval_note \
    --dataset $DATASET \
    --split $SPLIT"

  if [ -n "$EVAL_LIMIT" ]; then
    echo "EVAL_LIMIT: $EVAL_LIMIT"
    COMMAND="$COMMAND --eval-n-limit $EVAL_LIMIT"
  fi

  # Run the command
  eval $COMMAND
}

unset SANDBOX_ENV_GITHUB_TOKEN # prevent the agent from using the github token to push

# Skip runs if the run number is in the SKIP_RUNS list
# read from env variable SKIP_RUNS as a comma separated list of run numbers
SKIP_RUNS=(${SKIP_RUNS//,/ })
for i in $(seq 1 $N_RUNS); do
  if [[ " ${SKIP_RUNS[@]} " =~ " $i " ]]; then
    echo "Skipping run $i"
    continue
  fi
  current_eval_note="$EVAL_NOTE-run_$i"
  echo "EVAL_NOTE: $current_eval_note"
  run_eval $current_eval_note
done

checkout_original_branch

#!/bin/bash
set -eo pipefail

# # Detailed Plan 0
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 0  --max-iter 100
docker container prune -f

# # Detailed Plan 1
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 1 --max-iter 100
docker container prune -f

# # Detailed Plan 2
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 2 --max-iter 100
docker container prune -f

# # Detailed Plan 3
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 3 --max-iter 100
docker container prune -f

# # Detailed Plan 4
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 4 --max-iter 100
docker container prune -f


# -----------------------


# # Detailed Plan 0
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 0 --max-iter 100
# docker container prune -f

# # Detailed Plan 1
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 1 --max-iter 100
# docker container prune -f

# Detailed Plan 2
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 2 --max-iter 100
# docker container prune -f

# Detailed Plan 3
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 3 --max-iter 100
# docker container prune -f

# Detailed Plan 4
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 4 --max-iter 100
# docker container prune -f

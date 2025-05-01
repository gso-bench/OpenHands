#!/bin/bash
set -eo pipefail

# # Short Plan 0
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 0
# docker container prune -f

# # Short Plan 1
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 1
# docker container prune -f

# # Short Plan 2
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 2
# docker container prune -f

# # Short Plan 3
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 3
# docker container prune -f

# # Short Plan 4
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 4
# docker container prune -f


# # Detailed Plan 0
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 0
# docker container prune -f

# # Detailed Plan 1
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 1
# docker container prune -f

# # Detailed Plan 2
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 2
# docker container prune -f

# # Detailed Plan 3
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 3
# docker container prune -f

# # Detailed Plan 4
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --dataset manishs/pyperf-planned --num-workers 60 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 4
# docker container prune -f


# -----------------------


# Short Plan 0
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 0
# docker container prune -f

# # Short Plan 1
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 1
# docker container prune -f

# # Short Plan 2
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 2
# docker container prune -f

# # Short Plan 3
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 3
# docker container prune -f

# # Short Plan 4
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type short_plans --plan-id 4
# docker container prune -f



# # Detailed Plan 0
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 0
# docker container prune -f

# # Detailed Plan 1
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 1
# docker container prune -f

# Detailed Plan 2
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 2
docker container prune -f

# Detailed Plan 3
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 3
docker container prune -f

# Detailed Plan 4
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --dataset manishs/pyperf-planned --num-workers 45 --n-runs 1 --use-plans true --plan-type detailed_plans --plan-id 4
docker container prune -f

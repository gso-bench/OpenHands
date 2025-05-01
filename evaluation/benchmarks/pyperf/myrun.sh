#!/bin/bash
set -eo pipefail

########### Inference-time scaling [steps] ###########

# --------- o4-mini ---------

# o4-mini + Max Steps 50
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 50
# docker container prune -f

# o4-mini + Max Steps 100
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 100
# docker container prune -f

# o4-mini + Max Steps 200
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 200
# docker container prune -f

# o4-mini + Max Steps 400
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 400
# docker container prune -f

# o4-mini + Max Steps 800
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 800
# docker container prune -f

# o4-mini + Max Steps 1600
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 1 --max-iter 1600
# docker container prune -f

# --------- claude3.5 ---------

# claude3.5 + Max Steps 50
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 50
# docker container prune -f

# claude3.5 + Max Steps 100
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 100
docker container prune -f

# claude3.5 + Max Steps 200
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 200
docker container prune -f

# claude3.5 + Max Steps 400
./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 400
docker container prune -f

# claude3.5 + Max Steps 800
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 800
# docker container prune -f

# claude3.5 + Max Steps 1600
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 1600
# docker container prune -f


########### Inference-time scaling [rollouts] ###########

# o4-mini + 10 rollouts
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 60 --n-runs 10 --max-iter 100
# docker container prune -f

# claude3.5 + 10 rollouts
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 10 --max-iter 100
# docker container prune -f
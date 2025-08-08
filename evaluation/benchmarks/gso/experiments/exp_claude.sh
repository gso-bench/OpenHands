#!/bin/bash
set -eo pipefail

########### Inference-time scaling [steps] ###########

# Setup:
# L = [50, 100, 200, 400, 800]
# k = min(400/L, 1) 
# temp=0.k

# L = 50, k = 8, temp = 0.8
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-8 --commit-hash HEAD --agent CodeActAgent --num-workers 50 --n-runs 8 --max-iter 50
# docker container prune -f

# L = 100, k = 4, temp = 0.4
# until ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-4 --commit-hash HEAD --agent CodeActAgent --num-workers 50 --n-runs 4 --max-iter 100; do
#     echo "Error occurred. Retrying in 20 seconds..."
#     sleep 20
# done
# docker container prune -f

# L = 200, k = 2, temp = 0.2
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-2 --commit-hash HEAD --agent CodeActAgent --num-workers 50 --n-runs 2 --max-iter 200
# docker container prune -f

# L = 400, k = 1, temp = 0.1
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 50 --n-runs 1 --max-iter 400
# docker container prune -f

# L = 800, k = 1, temp = 0.1
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 50 --n-runs 1 --max-iter 800
# docker container prune -f


########### Inference-time scaling [rollouts] ###########

# Setup:
# K = 10
# L = 100
# temp = 0.8

# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-8 --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 10 --max-iter 100
# docker container prune -f

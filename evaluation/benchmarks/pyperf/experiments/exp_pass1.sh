#!/bin/bash
set -eo pipefail

########### metric@1 ###########

# Setup:
# L = 100
# k = 3
# temp=0.1


# o4-mini
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 80 --n-runs 3 --max-iter 100
# docker container prune -f

# o3-mini
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_o3-mini --commit-hash HEAD --agent CodeActAgent --num-workers 80 --n-runs 3 --max-iter 100
# docker container prune -f

# gpt-4o
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_gpt-4o_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 80 --n-runs 3 --max-iter 100
# docker container prune -f

# claude-3.6
# ./evaluation/benchmarks/pyperf/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 3 --max-iter 100
# docker container prune -f

# claude-3.7
# TODO

# gemini-2.5-pro
# TODO
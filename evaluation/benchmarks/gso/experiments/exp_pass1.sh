#!/bin/bash
set -eo pipefail

########### Closed Models ###########

# gpt-5
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_gpt-5 --commit-hash HEAD --agent CodeActAgent --num-workers 20 --n-runs 1 --max-iter 100
# docker container prune -f

# o3
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_o3 --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 1 --max-iter 100
# docker container prune -f

# o4-mini
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_o4-mini --commit-hash HEAD --agent CodeActAgent --num-workers 80 --n-runs 3 --max-iter 100
# docker container prune -f

# claude-3.6-sonnet
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_sonnet_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 40 --n-runs 3 --max-iter 100
# docker container prune -f

# claude-3.7-sonnet
# until ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_claude_3_7_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 5 --n-runs 3 --max-iter 100; do
#     echo "Error occurred. Retrying in 20 seconds..."
#     sleep 20
# done
# docker container prune -f

# claude-4.0-opus
# until ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_opus_vertex_0-1 --commit-hash HEAD --agent CodeActAgent --num-workers 1 --n-runs 1 --max-iter 100; do
#     echo "Error occurred. Retrying in 20 seconds..."
#     sleep 20
# done
# docker container prune -f


########### Open Models ###########

# qwen3-coder
./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_qwen3_coder --commit-hash HEAD --agent CodeActAgent --num-workers 30 --n-runs 1 --max-iter 100
docker container prune -f


# # kimi_k2_instruct
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_kimi_k2_instruct --commit-hash HEAD --agent CodeActAgent --num-workers 1 --n-runs 1 --max-iter 100
# docker container prune -f

# # glm4.5
# ./evaluation/benchmarks/gso/scripts/run_infer.sh --model-config llm.eval_glm4_5 --commit-hash HEAD --agent CodeActAgent --num-workers 1 --n-runs 1 --max-iter 100
# docker container prune -f

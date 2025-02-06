# import json

# output_path = "evaluation/evaluation_outputs/outputs/manishs__pyperf_pandas-test/CodeActAgent/gpt-4o_maxiter_100_N_v0.23.0-no-hint-run_1/output.jsonl"

# # read the jsonl file
# with open(output_path, "r") as f:
#     data = f.readlines()

# # parse the jsonl file
# data = [json.loads(d) for d in data]


# # view the entire data structure (all keys recursively)
# # pretty print only the keys
# def print_keys(data, prefix=""):
#     for k, v in data.items():
#         print(prefix + k + ":" + str(type(v)))
#         if isinstance(v, dict):
#             print_keys(v, prefix + "  ")
#         if isinstance(v, list) and len(v) > 0 and isinstance(v[0], dict):
#             print_keys(v[0], prefix + "  ")


# print_keys(data[0])

# print(data[0]["history"][0])

# # lambdas for extracting data
# get_instruction = lambda x: x["instruction"]


import json

from flask import Flask, jsonify, render_template

app = Flask(__name__)

# Global variable to store the conversations
conversations = []
current_index = 0


def load_jsonl(file_path):
    global conversations
    with open(file_path, 'r') as f:
        conversations = [json.loads(line) for line in f]


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/conversation/current')
def get_current_conversation():
    if not conversations:
        return jsonify({'error': 'No conversations loaded'})
    return jsonify(
        {
            'conversation': conversations[current_index],
            'current_index': current_index,
            'total': len(conversations),
        }
    )


@app.route('/conversation/next')
def next_conversation():
    global current_index
    if current_index < len(conversations) - 1:
        current_index += 1
    return get_current_conversation()


@app.route('/conversation/previous')
def previous_conversation():
    global current_index
    if current_index > 0:
        current_index -= 1
    return get_current_conversation()


if __name__ == '__main__':
    # Load your JSONL file here
    output_path = 'evaluation/evaluation_outputs/outputs/manishs__pyperf_pandas-test/CodeActAgent/gpt-4o_maxiter_100_N_v0.23.0-no-hint-run_1/output.jsonl'
    load_jsonl(output_path)
    app.run(debug=True, host='0.0.0.0', port=5760)

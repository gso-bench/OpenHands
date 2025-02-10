import json
import os

from flask import Flask, jsonify, render_template

app = Flask(__name__)

# Base directory for logs
LOGS_DIR = 'evaluation/evaluation_outputs/outputs'


def get_available_logs():
    """Recursively find all .jsonl files in the logs directory"""
    log_files = []
    for root, dirs, files in os.walk(LOGS_DIR):
        for file in files:
            # jsonl file with name output.jsonl
            if file.endswith('.jsonl') and file == 'output.jsonl':
                # Get relative path from LOGS_DIR
                rel_path = os.path.relpath(os.path.join(root, file), LOGS_DIR)
                log_files.append(rel_path)
    return sorted(log_files)


# Global variables to store the conversations and current log
conversations = {}
current_indices = {}
current_log = None


def load_jsonl(file_path):
    """Load a JSONL file and store its conversations"""
    full_path = os.path.join(LOGS_DIR, file_path)
    with open(full_path, 'r') as f:
        conversations[file_path] = [json.loads(line) for line in f]
    current_indices[file_path] = 0


@app.route('/')
def index():
    log_files = get_available_logs()
    return render_template('index.html', logs=log_files)


@app.route('/view/<path:log_path>')
def view_log(log_path):
    global current_log
    current_log = log_path

    # Load the log file if it hasn't been loaded yet
    if log_path not in conversations:
        load_jsonl(log_path)

    return render_template('conversation.html', log_path=log_path)


@app.route('/conversation/current/<path:log_path>')
def get_current_conversation(log_path):
    if log_path not in conversations:
        return jsonify({'error': 'Log file not loaded'})

    return jsonify(
        {
            'conversation': conversations[log_path][current_indices[log_path]],
            'current_index': current_indices[log_path],
            'total': len(conversations[log_path]),
        }
    )


@app.route('/conversation/next/<path:log_path>')
def next_conversation(log_path):
    if current_indices[log_path] < len(conversations[log_path]) - 1:
        current_indices[log_path] += 1
    return get_current_conversation(log_path)


@app.route('/conversation/previous/<path:log_path>')
def previous_conversation(log_path):
    if current_indices[log_path] > 0:
        current_indices[log_path] -= 1
    return get_current_conversation(log_path)


if __name__ == '__main__':
    # Load your JSONL file here
    # output_path = 'evaluation/evaluation_outputs/outputs/manishs__pyperf_pandas-test/CodeActAgent/gpt-4o_maxiter_100_N_v0.23.0-no-hint-run_1/output.jsonl'
    # output_path = 'evaluation/evaluation_outputs/outputs/manishs__pyperf_pandas-test/CodeActAgent/claude-3-5-sonnet-v2-20241022_maxiter_100_N_v0.23.0-no-hint-run_1/output.jsonl'
    # load_jsonl(output_path)
    app.run(debug=True, host='0.0.0.0', port=5760)

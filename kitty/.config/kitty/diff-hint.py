import inspect
import re
import shlex
import os
import subprocess

DIFF_COMMAND = 'open https://www.internalfb.com/diff/{diff}'
DIFF_REGEX = r'(D[\d]+)'

def mark(text, args, Mark, extra_cli_args, *a):
    for idx, m in enumerate(re.finditer(DIFF_REGEX, text)):
        start, end = m.span()
        mark_text = text[start:end].replace('\n', '').replace('\0', '')
        yield Mark(idx, start, end, mark_text, {"type": "diff"})

def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    matches, groupdicts = [], []

    for m, g in zip(data['match'], data['groupdicts']):
        if m:
            matches.append(m), groupdicts.append(g)

    for word, match_data in zip(matches, groupdicts):
        if "type" in match_data and match_data["type"] == "diff":
            command = DIFF_COMMAND.replace('{diff}', word)
            subprocess.call(shlex.split(command))

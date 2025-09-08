# import inspect
# import os

import re
import shlex
import subprocess

COMMAND = "open 'https://www.internalfb.com/intern/bunny/?q={paste}'"
REGEX = r"([DPT][\d]+)"


def mark(text, args, Mark, extra_cli_args, *a):
    for idx, m in enumerate(re.finditer(REGEX, text)):
        start, end = m.span()
        mark_text = text[start:end].replace("\n", "").replace("\0", "")
        yield Mark(idx, start, end, mark_text, {"type": "bunny"})


def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    matches, groupdicts = [], []

    for m, g in zip(data["match"], data["groupdicts"]):
        if m:
            matches.append(m), groupdicts.append(g)

    for word, match_data in zip(matches, groupdicts):
        if "type" in match_data and match_data["type"] == "bunny":
            command = COMMAND.replace("{paste}", word)
            subprocess.call(shlex.split(command))

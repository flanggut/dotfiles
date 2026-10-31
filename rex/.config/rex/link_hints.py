"""Shows a copy of a pane's screen with a label on each URL, and opens the URL
whose label is typed. Run by the link_hints action in link_hints.lua.

Usage: link_hints.py SCREEN_FILE ROWS COLUMNS
"""

import os
import re
import shutil
import signal
import subprocess
import sys
import termios
import tty
import unicodedata

LABEL_CHARS = "asdfghjkl"
URL = re.compile(r"(?:(?:https?|ftp|file)://|www\.)[^\s<>\"'`|\\^{}]*")
URL_CHAR = re.compile(r"[^\s<>\"'`|\\^{}]+")
TRAILING = ".,;:!?*_~"
PAIRS = {")": "(", "]": "[", "}": "{", ">": "<"}

DIM = "\x1b[0;90m"
LINK = "\x1b[0;36;4m"
LABEL = "\x1b[0;1;30;43m"
TYPED = "\x1b[0;33;43m"
RESET = "\x1b[0m"


class Hint:
    def __init__(self, url, segments):
        self.url = url
        self.segments = segments  # (row, start, end) column ranges, one per line
        self.label = ""


def trim(text):
    """Drops punctuation that ends a sentence rather than the URL."""
    while text:
        last = text[-1]
        if last in TRAILING:
            text = text[:-1]
        elif last in PAIRS and text.count(last) > text.count(PAIRS[last]):
            text = text[:-1]
        else:
            break
    return text


def find_hints(lines, columns):
    hints = []
    for row, line in enumerate(lines):
        for m in URL.finditer(line):
            segments = [(row, m.start(), m.end())]
            # A URL that runs to the right edge probably wraps onto the next line.
            r, end = row, m.end()
            while end == len(lines[r]) >= columns and r + 1 < len(lines):
                cont = URL_CHAR.match(lines[r + 1])
                if not cont:
                    break
                r, end = r + 1, cont.end()
                segments.append((r, 0, end))
            text = "".join(lines[r][s:e] for r, s, e in segments)
            cut = len(text) - len(trim(text))
            while cut:
                r, s, e = segments[-1]
                take = min(cut, e - s)
                cut -= take
                if e - take > s:
                    segments[-1] = (r, s, e - take)
                else:
                    segments.pop()
            if not segments:
                continue
            url = trim(text)
            if url.endswith("://") or url == "www.":
                continue
            if url.startswith("www."):
                url = "https://" + url
            hints.append(Hint(url, segments))
    # Skip continuation lines that were already claimed by a wrapped URL.
    claimed = set()
    result = []
    for h in hints:
        if h.segments[0][:2] in claimed:
            continue
        claimed.update(seg[:2] for seg in h.segments[1:])
        result.append(h)
    return result


def assign_labels(hints):
    length = 1
    while len(LABEL_CHARS) ** length < len(hints):
        length += 1
    for i, h in enumerate(hints):
        label = ""
        for _ in range(length):
            i, d = divmod(i, len(LABEL_CHARS))
            label = LABEL_CHARS[d] + label
        h.label = label


def width(ch):
    if unicodedata.combining(ch):
        return 0
    return 2 if unicodedata.east_asian_width(ch) in "WF" else 1


def draw(lines, hints, typed, message=None):
    cols, rows = shutil.get_terminal_size()
    styles = [[DIM] * len(line) for line in lines]
    chars = [list(line) for line in lines]
    for h in hints:
        live = h.label.startswith(typed)
        for r, s, e in h.segments:
            for c in range(s, e):
                styles[r][c] = LINK if live else DIM
        if not live:
            continue
        r, s, e = h.segments[0]
        for i, ch in enumerate(h.label):
            c = s + i
            if c >= len(chars[r]):
                chars[r].append(" ")
                styles[r].append(DIM)
            chars[r][c] = ch.upper()
            styles[r][c] = TYPED if i < len(typed) else LABEL

    out = ["\x1b[H\x1b[2J"]
    shown = rows - 1 if message else rows
    for r in range(min(len(lines), shown)):
        used, style = 0, None
        for ch, st in zip(chars[r], styles[r]):
            w = width(ch)
            if used + w > cols:
                break
            if st != style:
                out.append(st)
                style = st
            out.append(ch)
            used += w
        out.append(RESET)
        if r < shown - 1:
            out.append("\r\n")
    if message:
        out.append("\x1b[%d;1H%s%s%s" % (rows, LABEL, message[:cols], RESET))
    sys.stdout.write("".join(out))
    sys.stdout.flush()


def main():
    path, rows, columns = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    with open(path, encoding="utf-8", errors="replace") as f:
        content = f.read()
    os.remove(path)

    lines = content.split("\n")
    while lines and lines[-1] == "":
        lines.pop()
    lines = lines[-rows:]
    hints = find_hints(lines, columns)
    assign_labels(hints)
    message = None if hints else " No links on screen. Press any key. "

    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    sys.stdout.write("\x1b[?1049h\x1b[?25l")
    typed = ""
    signal.signal(signal.SIGWINCH, lambda *_: draw(lines, hints, typed, message))
    try:
        tty.setraw(fd)
        draw(lines, hints, typed, message)
        while True:
            key = os.read(fd, 32).decode("utf-8", "replace")
            if not hints or key.startswith("\x1b") or key in ("\x03", "\x07"):
                return
            if key == "\x7f":
                typed = typed[:-1]
            elif len(key) == 1 and key.lower() in LABEL_CHARS:
                attempt = typed + key.lower()
                if any(h.label.startswith(attempt) for h in hints):
                    typed = attempt
            for h in hints:
                if h.label == typed:
                    subprocess.run(["/usr/bin/open", h.url])
                    return
            draw(lines, hints, typed, message)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, saved)
        sys.stdout.write("\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()


if __name__ == "__main__":
    main()

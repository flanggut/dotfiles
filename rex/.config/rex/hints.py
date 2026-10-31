"""Shows a copy of a pane's screen with a label on each link or file path, and
acts on the one whose label is typed. Run by the actions in hints.lua.

Usage: hints.py MODE SCREEN_FILE ROWS COLUMNS CWD SESSION BLOCK

MODE is "links", to open the URL, or "paths", to type the path into BLOCK.
"""

import os
import re
import shlex
import shutil
import signal
import subprocess
import sys
import termios
import tty
import unicodedata

LABEL_CHARS = "asdfghjklqwertyuiopzxcvbnm" + "ASDFGHJKLQWERTYUIOPZXCVBNM"
URL = re.compile(r"(?:(?:https?|ftp|file)://|www\.)[^\s<>\"'`|\\^{}]*")
URL_CHAR = re.compile(r"[^\s<>\"'`|\\^{}]+")
PATH = re.compile(r"[\w.~/@+%=:-]+")
TRAILING = ".,;:!?*_~"
PAIRS = {")": "(", "]": "[", "}": "{", ">": "<"}
LINE_NUMBER = re.compile(r"(?::\d+)+:?$")
STRONG_PATH = re.compile(r"^(?:/|~/|\./|\.\./)")
# A relative path with a directory whose file has an extension, like src/foo.py.
NESTED_FILE = re.compile(r"^[^/].*/[^/]*[^/.]\.[A-Za-z][A-Za-z0-9]{0,9}$")

DIM = "\x1b[0;90m"
LINK = "\x1b[0;36;4m"
LABEL = "\x1b[0;1;30;43m"
TYPED = "\x1b[0;33;43m"
RESET = "\x1b[0m"


class Hint:
    def __init__(self, value, segments):
        self.value = value
        self.segments = segments  # (row, start, end) column ranges, one per line
        self.label = ""


def trim_url(text):
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


def accept_url(text):
    if text.endswith("://") or text == "www.":
        return None
    return "https://" + text if text.startswith("www.") else text


def trim_path(text):
    """Drops a :line:col suffix, as in compiler and grep output."""
    return LINE_NUMBER.sub("", text).rstrip(".,:")


def path_acceptor(cwd):
    def exists(path):
        return os.path.exists(os.path.join(cwd, os.path.expanduser(path)))

    def accept(text):
        if "://" in text or text in ("/", "~", ".", ".."):
            return None
        # Paths that can only be paths are kept even when they don't exist
        # here, such as ones printed on another host.
        if STRONG_PATH.match(text) and len(text) > 2 or NESTED_FILE.match(text):
            return text
        if "/" not in text and "." not in text.strip("."):
            return None
        if exists(text):
            return text
        # git diff prints a/ and b/ before each path.
        if text[:2] in ("a/", "b/") and exists(text[2:]):
            return text[2:]
        return None

    return accept


def find_hints(lines, columns, start, cont, trim, accept):
    hints = []
    claimed = set()
    for row, line in enumerate(lines):
        for m in start.finditer(line):
            if (row, m.start()) in claimed:
                continue
            segments = [(row, m.start(), m.end())]
            # A match that runs to the right edge probably wraps onto the next line.
            r, end = row, m.end()
            while end == len(lines[r]) >= columns and r + 1 < len(lines):
                more = cont.match(lines[r + 1])
                if not more:
                    break
                r, end = r + 1, more.end()
                segments.append((r, 0, end))
            text = "".join(lines[r][s:e] for r, s, e in segments)
            trimmed = trim(text)
            cut = len(text) - len(trimmed)
            while cut:
                r, s, e = segments[-1]
                take = min(cut, e - s)
                cut -= take
                if e - take > s:
                    segments[-1] = (r, s, e - take)
                else:
                    segments.pop()
            value = accept(trimmed) if segments else None
            if value is None:
                continue
            claimed.update(seg[:2] for seg in segments[1:])
            hints.append(Hint(value, segments))
    return hints


def make_labels(n, chars=LABEL_CHARS):
    """Returns n labels, none a prefix of another, as short as they can be.

    Characters are used in order, so lowercase labels come first. When there
    are more hints than characters, characters from the end of the list
    become prefixes for two-character labels, one at a time, so as many
    hints as possible keep a single character.
    """
    size = len(chars)
    if n <= size:
        return list(chars[:n])
    prefixes = min(size, -(-(n - size) // (size - 1)))
    labels = list(chars[:size - prefixes])
    left = n - len(labels)
    for i, prefix in enumerate(chars[size - prefixes:]):
        share = max(min(left, size), -(-left // (prefixes - i)))
        labels += [prefix + rest for rest in make_labels(share, chars)]
        left -= share
    return labels


def assign_labels(hints):
    for h, label in zip(hints, make_labels(len(hints))):
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
            chars[r][c] = ch
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


def quote_path(path):
    """Quotes a path for the shell, leaving a leading ~/ to expand."""
    if path.startswith("~/"):
        return "~/" + shlex.quote(path[2:]) if path[2:] else "~/"
    return shlex.quote(path)


def rex_command():
    found = shutil.which("rex")
    if found:
        return found
    return os.path.join(os.environ.get("REX_BIN_DIR", ""), "rex")


def main():
    mode, path, rows, columns, cwd, session, block = sys.argv[1:8]
    rows, columns = int(rows), int(columns)
    with open(path, encoding="utf-8", errors="replace") as f:
        content = f.read()
    os.remove(path)

    lines = content.split("\n")
    while lines and lines[-1] == "":
        lines.pop()
    lines = lines[-rows:]
    if mode == "links":
        hints = find_hints(lines, columns, URL, URL_CHAR, trim_url, accept_url)
        message = " No links on screen. Press any key. "
    else:
        hints = find_hints(lines, columns, PATH, PATH, trim_path, path_acceptor(cwd))
        message = " No file paths on screen. Press any key. "
    assign_labels(hints)
    if hints:
        message = None

    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    sys.stdout.write("\x1b[?1049h\x1b[?25l")
    typed = ""
    signal.signal(signal.SIGWINCH, lambda *_: draw(lines, hints, typed, message))
    picked = None
    try:
        tty.setraw(fd)
        draw(lines, hints, typed, message)
        while picked is None:
            key = os.read(fd, 32).decode("utf-8", "replace")
            if not hints or key.startswith("\x1b") or key in ("\x03", "\x07"):
                return
            if key == "\x7f":
                typed = typed[:-1]
            elif len(key) == 1 and key in LABEL_CHARS:
                attempt = typed + key
                if any(h.label.startswith(attempt) for h in hints):
                    typed = attempt
            picked = next((h for h in hints if h.label == typed), None)
            draw(lines, hints, typed, message)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, saved)
        sys.stdout.write("\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()

    if mode == "links":
        subprocess.run(["/usr/bin/open", picked.value])
    else:
        subprocess.run([rex_command(), "send", "-s", session, "-b", block,
                        quote_path(picked.value)])


if __name__ == "__main__":
    main()

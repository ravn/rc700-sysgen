#!/usr/bin/env python3
"""Post-process z80dasm output: collapse defb byte sequences into db strings.

Only collapses runs that contain a contiguous stretch of >= 4 printable ASCII
characters, avoiding false positives on binary data tables.
"""

import re
import sys

def longest_printable_run(bytes_list):
    """Return length of longest contiguous printable ASCII run."""
    best = 0
    cur = 0
    for b in bytes_list:
        if 0x20 <= b <= 0x7e and chr(b) != "'":
            cur += 1
            best = max(best, cur)
        else:
            cur = 0
    return best

def format_db(bytes_list):
    """Format a byte sequence as a db line with quoted string runs."""
    parts = []
    str_acc = []
    for b in bytes_list:
        if 0x20 <= b <= 0x7e and chr(b) != "'":
            str_acc.append(chr(b))
        else:
            if str_acc:
                parts.append("'" + ''.join(str_acc) + "'")
                str_acc = []
            parts.append('0%02Xh' % b)
    if str_acc:
        parts.append("'" + ''.join(str_acc) + "'")
    return '\tdb ' + ','.join(parts) + '\n'

def collapse_defb_strings(lines):
    """Find runs of defb lines and collapse those containing strings."""
    result = []
    i = 0
    while i < len(lines):
        # Collect consecutive "defb 0XXh" lines (no intervening labels)
        run = []
        j = i
        while j < len(lines):
            m = re.match(r'\tdefb 0([0-9a-f]{2})h\s*;', lines[j])
            if m:
                run.append(int(m.group(1), 16))
                j += 1
            else:
                break

        if not run:
            result.append(lines[i])
            i += 1
            continue

        # Only collapse if there's a genuine string (>= 4 consecutive printable)
        if longest_printable_run(run) >= 4:
            result.append(format_db(run))
        else:
            for k, b in enumerate(run):
                result.append(lines[i + k])

        i = j

    return result

def main():
    path = sys.argv[1]
    with open(path, 'r') as f:
        lines = f.readlines()
    lines = collapse_defb_strings(lines)
    with open(path, 'w') as f:
        f.writelines(lines)

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
# in a list, move arg to first position, preserving order

import sys


def main():
    try:
        target = sys.argv[1].lower()
    except IndexError:
        # no arg specified so short-circuit and return everything
        sys.stdout.write(sys.stdin.read())
        # exit for completeness; as stdin is now empty letting the
        # rest of the program would do nothing.
        sys.exit()

    source_list = []
    for line in map(str.strip, sys.stdin):
        source_list.append(line)

    for idx, value in enumerate(source_list):
        if target in value.lower():
            source_list.insert(0, source_list[idx])
            source_list.pop(idx+1)
            break  # stop looking

    for line in source_list:
        print(line)


if __name__ == "__main__":
    main()

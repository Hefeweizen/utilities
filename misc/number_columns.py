#!/usr/bin/env python3

# Copyright (C) 2023 Hefeweizen (https://github.com/Hefeweizen)
# Permission to copy and modify is granted under the Apace License 2.0

"""
A simple utility to number the word positions in a line.  Often with `awk` I'll
want to print a specific column, this utility numbers the columns so as to
quickly identify which you want.
"""

import argparse
import sys


def parse_args():
    p = argparse.ArgumentParser(description='tool to number columns')

    p.add_argument('-d', '--delimiter', default=' ',
                   help='Specify delimiter between records')

    p.add_argument('-n', '--num', default=1, type=int,
                   help='Specify number of lines to annotate')

    return p.parse_args()


def annotate_line(line, input_separator=' ', output_separator='|'):
    """
    """
    word_lengths = [len(word) for word in line.split(input_separator)]

    annotations = []
    for position, word_len in enumerate(word_lengths):
        annotations.append(str(position+1).center(word_len))

    return f"{output_separator.join(annotations)}\n{line}"


def main():
    args = parse_args()

    output = []
    count = 0
    for line in sys.stdin:
        output.append(annotate_line(line.rstrip(),
                                    input_separator=args.delimiter))
        count += 1
        if count >= args.num:
            break

    for line in output:
        print(line)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# in a list, move arg to first position, preserving order
#
# The description above is the effect.  The implementation
# is slightly different:  buffer until a line is found, print
# the line, print the buffer, and then just pass everything
# onward.

import sys


def main():
    # sys.argv will always have at least one element
    if len(sys.argv) > 1:
        target = sys.argv[1].lower()
        buffer = []
        for line in sys.stdin:
            if target not in line.lower():
                buffer.append(line)
            else:
                # print first item found
                sys.stdout.write(line)

                # print buffer
                for buffer_line in buffer:
                    sys.stdout.write(buffer_line)

                # cleanup
                del buffer
                break

    # pass everything forward
    sys.stdout.write(sys.stdin.read())


if __name__ == "__main__":
    main()

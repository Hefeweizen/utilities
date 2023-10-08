#!/usr/bin/env bash
#
# inspired by https://superuser.com/a/747905 which presented
# this from reading from file or stdin:
# ```
# [ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"
# cat $input
# ```


input=""

if [ $# -ge 1 ]; then
    input="$@"
else
    input=$(cat -)
fi


echo $input

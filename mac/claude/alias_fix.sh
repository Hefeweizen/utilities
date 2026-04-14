#!/opt/homebrew/bin/bash

sed -i '' -E -e "s#^(alias\ --)\ --#\1#" /Users/jmales/.claude/shell-snapshots/*.sh


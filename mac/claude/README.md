# bash shell-snapshot patch

In ~/.bashrc.d/aliases, I have `alias -- -='cd -'` which enables switching direcotries with a single stroke (+ enter).  When claude runs, it captures the current environment for its own processes.  Doing so, it tries to escape the alias for clarity, but this leads to an error:  `alias -- -- -='cd -'`.

This is my fix, it just seds any such shell-snapshot that gets created.

## Installing

```
ln -s ~/Utilities/mac/claude/alias_fix.sh ~/bin/
cp com.example.dirwatch_claude.plist ~/Library/LaunchAgents/com.example.dirwatch_claude.plist
launchctl load ~/Library/LaunchAgents/com.example.dirwatch_claude.plist
```

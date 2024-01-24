# Notes on Scripting & other cli tricks


## Table of Contents

1. [Exiting](#Exiting)


## Exiting
`set -e` exits on failure; `/bin/false` returns rc 1
Combined, the echo will never run:
```
$ cat test.sh
#!/bin/bash

# exit after failure
set -e

# does this fail?
/usr/bin/false

echo "didn't stop the script"
```

#!/opt/homebrew/bin/bash

# foo.<sha> -- use short sha as file extension
local_foo="foo.$(git rev-parse @ | cut -c 1-8)"

# add check that we're in a good dir
# i.e. there's a Chart.yaml
if [ ! -f Chart.yaml ]; then
    echo "bad location; no local chart"
    exit 1
fi

git stash push
git switch main
htf --base -a -o foo.main
git switch -
git stash pop
htf --base -a -o ${local_foo}

diff foo.main  ${local_foo}

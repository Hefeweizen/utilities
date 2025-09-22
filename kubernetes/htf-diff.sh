#!/opt/homebrew/bin/bash

compare_branch="${1:-main}"

# foo.<sha> -- use short sha as file extension
local_foo="foo.$(git rev-parse @ | cut -c 1-8)"

# add check that we're in a good dir
# i.e. there's a Chart.yaml
if [ ! -f Chart.yaml ]; then
    echo "bad location; no local chart"
    exit 1
fi

git stash push
git switch ${compare_branch}
htf --base -a -o foo.${compare_branch}
git switch -
git stash pop
htf --base -a -o ${local_foo}

diff foo.${compare_branch} ${local_foo}

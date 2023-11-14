#!/usr/bin/env bash
#

set -eou pipefail

commits=$(git log -G '^version:' --format='%h' -- charts/*/Chart.yaml)

for commit in ${commits};
do
    filenames=$(git show ${commit} --name-only | grep -E 'charts/.*/Chart.yaml$')
    for file in ${filenames};
    do
        project=$(awk -F'/' '{print $2}' <<<"${file}")
        version=$(awk '/^version:/ {print $2}' <(git show ${commit}:${file}))
        tag="${project}-v${version}"

        echo "Commit: ${commit}; Project: ${project}; File: ${file}; Tag: ${tag}"
        if git tag -l ${tag} | grep ${tag}; then
            echo "Already exists!"
        else
            git tag -a ${tag} ${commit} -m ''
        fi
        echo
    done
done

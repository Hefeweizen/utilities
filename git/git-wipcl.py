#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "GitPython",
# ]
# ///
"""
Remove any branches "-wip" branches that do not have an associated primary branch
"""


import os

import git


def unmatched_wip_branches(branches):
    unmatched = []

    for wipbr in (br for br in branches if br.endswith("-wip")):
        primarybr = wipbr.removesuffix("-wip")
        if primarybr not in branches:
            unmatched.append(wipbr)

    return unmatched


if __name__=="__main__":
    repo = git.Repo(os.getcwd(), search_parent_directories=True)

    branches = [str(br) for br in repo.branches]

    for wipbr in unmatched_wip_branches(branches):
        short_sha = repo.heads[wipbr].commit.hexsha[:10]
        git.cmd.Git(repo).branch("-d", wipbr, force=True)
        print(f" 💣 {wipbr} ({short_sha})")

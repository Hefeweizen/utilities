#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "ruamel.yaml",
#   "semver>=3,<4",
# ]
# ///

"""
desc
"""

import argparse
import re

from pathlib import Path
from typing import Optional, Tuple

from semver import Version

from ruamel.yaml import YAML

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)

BASEVERSION = re.compile(
    r"""[vV]?
        (?P<major>0|[1-9]\d*)
        (\.
        (?P<minor>0|[1-9]\d*)
        (\.
            (?P<patch>0|[1-9]\d*)
        )?
        )?
    """,
    re.VERBOSE,
)


# straight from semver3 docs:
# https://python-semver.readthedocs.io/en/latest/advanced/deal-with-invalid-versions.html
def coerce(version: str) -> Tuple[Version, Optional[str]]:
    """
    Convert an incomplete version string into a semver-compatible Version
    object

    * Tries to detect a "basic" version string (``major.minor.patch``).
    * If not enough components can be found, missing components are
        set to zero to obtain a valid semver version.

    :param str version: the version string to convert
    :return: a tuple with a :class:`Version` instance (or version ``0``
        if it's not a version) and the rest of the string which doesn't
        belong to a basic version.
    :rtype: tuple(:class:`Version` | None, str)
    """
    match = BASEVERSION.search(version)
    if not match:
        return (Version(0), version)

    ver = {
        key: 0 if value is None else value for key, value in match.groupdict().items()
    }
    ver = Version(**ver)
    rest = match.string[match.end() :]  # noqa:E203
    return ver, rest

def parse_args():
    p = argparse.ArgumentParser(description="populate repo files from list of image:tags")

    p.add_argument(
        "images",
        nargs='*',
        help='`image:tag` to add to the respective file(s); multiple can be specified.',
    )

    return p.parse_args()

def parse_image(image: str):
    return image.split(":")

def lookup_repo_file(image_name: str) -> str:
    """
    images can have '/', so sanitize those
    also, assure the file exists,
    if not, create with bare skeleton
    """
    sanitized_image_name = image_name.replace('/', '-')
    repo_file = f"repos/{sanitized_image_name}.yaml"

    enforce_file(image_name, repo_file)

    return(repo_file)


def enforce_file(image_name: str, repo_file: str):
    filename = Path(repo_file)
    if not filename.is_file():
        record = {}
        record['repo'] = image_name
        record['tags'] = []

        with open(repo_file, mode='w') as f:
            yaml.dump(record, f)


def add_tag_to_file(repo_file, tag):
    with open(repo_file, mode='r') as f:
        record = yaml.load(f)

    # print(f"{tag=} {type(tag)}")
    if tag not in record['tags']:
        tags = record['tags']
        tags.append(tag)

        tags.sort(key=lambda x: coerce(x))
        record['tags'] = tags

        # print(f"writing tag '{tag}' to file '{repo_file}'")

        with open(repo_file, mode='w') as f:
            yaml.dump(record, f)

def process_image(image: str):
    image_name, tag = parse_image(image)
    repo_file = lookup_repo_file(image_name)

    add_tag_to_file(repo_file, tag)


def main():
    args = parse_args()

    # TODO: check that running in repo root
    # if not in repo root, then file path assumptions break

    for image in args.images:
        process_image(image)

if __name__=="__main__":
    main()

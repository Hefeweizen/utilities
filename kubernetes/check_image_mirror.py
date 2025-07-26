#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "boto3",
#   "ruamel.yaml",
# ]
# ///
"""
desc
"""


import argparse

import boto3

from ruamel.yaml import YAML


yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)


def parse_args():
    p = argparse.ArgumentParser(description="Check which images are actually in the AWS ECR repositories")

    p.add_argument(
        "repositories",
        nargs='*',
        help='list of repositories to check',
    )

    return p.parse_args()


def lookup_repo_file(image_name: str) -> str:
    """
    images can have '/', so sanitize those
    """
    sanitized_image_name = image_name.replace('/', '-')
    return f"repos/{sanitized_image_name}.yaml"


def lookup_ecr_repo(image_name: str) -> str:
    """
    ECR repositories are created prepended with 'mirror/'
    """
    return f"mirror/{image_name}"


def tags_in_repo_file(repo_file: str) -> list:
    with open(repo_file, mode='r') as f:
        record = yaml.load(f)
    
    return record['tags']


def get_filtered_ecr_image_tags(repo_name: str) -> list:
    """
    Retrieves and filters ECR image tags from a specified repository,
    excluding images with 'artifactMediaType' and then sorts them.

    Args:
        repository_name (str): The name of the ECR repository.

    Returns:
        list: A sorted list of image tags that meet the criteria.
    """
    ecr_client = boto3.client('ecr')
    image_tags = []

    # ECR describe-images is paginated, so we use a paginator to get all results
    paginator = ecr_client.get_paginator('describe_images')

    for page in paginator.paginate(repositoryName=repo_name):
        for image_detail in page.get('imageDetails', []):
            # skip images with this tag.  These are
            # arch-specific images; we want the image indexes
            if "artifactMediaType" in image_detail:
                continue

            # Add all image tags for the selected image
            if 'imageTags' in image_detail and image_detail['imageTags']:
                image_tags.extend(image_detail['imageTags'])

    return sorted(list(set(image_tags)))

def main():
    args = parse_args()
    
    for repo in args.repositories:
        ecr_repo = lookup_ecr_repo(repo)
        repo_tags = get_filtered_ecr_image_tags(ecr_repo)

        repo_file = lookup_repo_file(repo)
        file_tags = tags_in_repo_file(repo_file)
        
        print(f"{repo=}")
        print(f"{repo_tags=}")
        print(f"{file_tags=}")


if __name__ == "__main__":
    main()

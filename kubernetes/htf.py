#!/usr/bin/env python3


import argparse
import subprocess
import sys

from os import getcwd, remove as rmfile
from os.path import basename, isdir, isfile, join as dir_join, split as dir_split
from shutil import rmtree


def parse_args():
    p = argparse.ArgumentParser(description="tool to number columns")

    p.add_argument(
        "-b",
        "--base",
        action="store_true",
        help='use default values from dir "environments/base"',
    )

    p.add_argument(
        "-a",
        "--api-versions",
        dest="av",
        action="store_true",
        help="use api-versions from current remote cluster",
    )

    p.add_argument(
        "-c",
        "--clean",
        action="store_true",
        help="clean-up previously fetched charts and exit",
    )

    p.add_argument(
        "-o",
        "--output",
        default="foo",
        help="the name for the output file",
    )

    p.add_argument(
        "-on",
        "--output-name",
        default="foo",
        dest="output_name",
        help="the name for the app name and namespace",
    )

    p.add_argument(
        "-f",
        "--values-file",
        dest="vfile",
        help="Provide an additional values file to be applied after the values.yaml in the local directory",
    )

    p.add_argument(
        "-n",
        "--no-chart",
        dest="update_chart",
        action="store_false",
        help="do not translate chartmuseum.chartmuseum.svc.cluster.local:8080 into chartmuseum.shared-services.triumphpay.io",
    )

    p.add_argument(
        "-d",
        "--dry-run",
        action="store_true",
        help="Don't run helm, just show what commands would be run.",
    )

    return p.parse_args()


def clean_prev_charts():
    dirs = ["charts"]
    for dir in dirs:
        if isdir(dir):
            rmtree(dir)

    files = ["Chart.lock"]
    for file in files:
        if isfile(file):
            rmfile(file)


def find_base_dir(cwd):
    dir_depth = cwd

    while dir_depth != "/":
        candidate_dir = dir_join(dir_depth + "/environments/base")
        if isdir(candidate_dir):
            return candidate_dir
        else:
            dir_depth, _ = dir_split(dir_depth)

    raise Exception("no base configuration directory found.")


def get_base_values():
    cwd = getcwd()
    base_dir = find_base_dir(cwd)
    application = basename(cwd)

    return f"--values {base_dir}/{application}.yaml"


def get_api_versions():
    try:
        result = subprocess.run(
            ["kubectl", "api-versions"], check=True, capture_output=True, text=True
        )
    except subprocess.CalledProcessError as cpe:
        print(cpe)
        sys.exit(1)

    # stdout captures the output as a line-delimited list; we want commas
    found = ",".join(result.stdout.strip().split("\n"))

    return f"--api-versions {found}"


def update_chartyaml(before, after):
    with open('Chart.yaml', 'r') as file:
        filedata = file.read()

    filedata = filedata.replace(before, after)

    with open('Chart.yaml', 'w') as file:
        file.write(filedata)


def update_chartmuseum_reference():
    update_chartyaml(
            'chartmuseum.chartmuseum.svc.cluster.local:8080',
            'chartmuseum.shared-services.triumphpay.io'
            )


def undo_chartmuseum_reference():
    update_chartyaml(
            'chartmuseum.shared-services.triumphpay.io',
            'chartmuseum.chartmuseum.svc.cluster.local:8080'
            )


def helm_dependency_build():
    try:
        subprocess.run(["helm", "dependency", "build"], check=True)
    except subprocess.CalledProcessError:
        print("`helm dependency build` failed; check chart urls")
        sys.exit(1)


def run_template(
    use_base=False,
    use_apiversions=False,
    additional_values=None,
    dry_run=False,
    output_name="foo",
    out="foo"
):
    base = get_base_values() if use_base else ""
    api_versions = get_api_versions() if use_apiversions else ""
    add_values = f"--values {additional_values} " if additional_values else ""

    helm_template_cmd = (
        "helm template "
        "--debug "
        f"--name-template {output_name} "
        f"--namespace {output_name} "
        f"{api_versions} "
        f"{base} "
        f"--values values.yaml "
        f"{add_values}"
        "."
    )

    if dry_run:
        print(f"Dry run: {helm_template_cmd}")
        return

    try:
        result = subprocess.run(
            helm_template_cmd.split(), check=True, capture_output=True, text=True
        )
    except subprocess.CalledProcessError as cpe:
        print(f"{cpe}\nCmd:\n{helm_template_cmd}\nStderr:\n{cpe.stderr}")
        sys.exit(1)

    with open(out, mode="w") as f:
        f.write(result.stdout)


def main():
    args = parse_args()

    clean_prev_charts()

    if args.clean:
        # we've done everything we wanted
        sys.exit()

    if args.update_chart:
        update_chartmuseum_reference()

    helm_dependency_build()
    run_template(
        use_base=args.base,
        use_apiversions=args.av,
        additional_values=args.vfile,
        dry_run=args.dry_run,
        output_name=args.output_name,
        out=args.output,
    )

    if args.update_chart:
        undo_chartmuseum_reference()


if __name__ == "__main__":
    main()

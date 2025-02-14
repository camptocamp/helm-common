"""Run a command in files folder."""

import argparse
import os.path
import shlex
import subprocess  # nosec
import sys


def main() -> None:
    """Run a command in files folder."""
    parser = argparse.ArgumentParser(
        description="""Generate the helm template.

    It with run:
    - helm template ...
    - on error: helm dependency update
    - helm template ... (new try)
    - on error: helm template --debug ...

    The result of helm template is written in the output file.""",
    )
    parser.add_argument(
        "--additional-template-directory",
        nargs="+",
        help="Some additional template directory",
        default=[],
    )
    parser.add_argument("--namespace", help="The Kubernetes namespace", default="default")
    parser.add_argument("--values", action="append", help="The values to be used", default=[])
    parser.add_argument("name", help="The HELM release name")
    parser.add_argument("chart", help="The chart directory")
    parser.add_argument("output_file", help="The output file")
    args = parser.parse_args()

    helm_cmd = os.environ.get("HELM", "helm")

    helm_template_cmd = [
        helm_cmd,
        "template",
        f"--namespace={args.namespace}",
        *[f"--values={value}" for value in args.values],
        args.name,
        args.chart,
    ]
    helm_template_proc = subprocess.run(  # pylint: disable=subprocess-run-check # nosec
        helm_template_cmd,
        encoding="utf-8",
        stdout=subprocess.PIPE,
        check=False,
    )
    if helm_template_proc.returncode != 0:
        for template_directory in [args.chart, *args.additional_template_directory]:
            cmd = [helm_cmd, "dependency", "update"]
            helm_dependency_update_proc = subprocess.run(  # pylint: disable=subprocess-run-check # nosec
                cmd,
                cwd=template_directory,
                check=False,
            )
            if helm_dependency_update_proc.returncode != 0:
                print(f"Error running {shlex.join(cmd)} in {template_directory}")
                sys.exit(helm_dependency_update_proc.returncode)
    helm_template_proc = subprocess.run(  # pylint: disable=subprocess-run-check # nosec
        helm_template_cmd,
        encoding="utf-8",
        stdout=subprocess.PIPE,
        check=False,
    )
    if helm_template_proc.returncode != 0:
        print(f"Error running {shlex.join(helm_template_cmd)}")
        helm_template_cmd.insert(2, "--debug")
        subprocess.run(helm_template_cmd, check=False)  # pylint: disable=subprocess-run-check # nosec
        sys.exit(helm_template_proc.returncode)

    result = helm_template_proc.stdout.split("\n")
    result = [line.rstrip() for line in result]
    with open(args.output_file, "w", encoding="utf-8") as output_file:
        output_file.write("\n".join(result))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Create a Jira ticket from a JSON file using acli.

Usage:
    python create_ticket.py ticket.json
    python create_ticket.py --inline '{"projectKey": "PLATFORM", ...}'
"""

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path


def create_ticket(json_data: dict) -> str:
    """Create a Jira ticket and return the ticket key."""
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".json", delete=False
    ) as f:
        json.dump(json_data, f, indent=2)
        temp_path = f.name

    try:
        result = subprocess.run(
            ["acli", "jira", "workitem", "create", "--from-json", temp_path],
            capture_output=True,
            text=True,
            check=True,
        )
        print(result.stdout)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error creating ticket: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    finally:
        Path(temp_path).unlink()


def main():
    parser = argparse.ArgumentParser(description="Create a Jira ticket")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("file", nargs="?", help="Path to JSON file")
    group.add_argument("--inline", help="Inline JSON string")

    args = parser.parse_args()

    if args.inline:
        data = json.loads(args.inline)
    else:
        with open(args.file) as f:
            data = json.load(f)

    create_ticket(data)


if __name__ == "__main__":
    main()

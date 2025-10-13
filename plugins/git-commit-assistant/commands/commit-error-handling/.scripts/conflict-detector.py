#!/usr/bin/env python3
"""
================================================================
Script: conflict-detector.py
Purpose: Detect and report merge conflicts
Version: 1.0.0
Usage: ./conflict-detector.py
Returns: JSON with conflict information
Exit Codes:
  0 = Success (conflicts may or may not exist)
  1 = Not a git repository
  2 = Script error
================================================================
"""

import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def run_git_command(command):
    """Run a git command and return output."""
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return -1, "", str(e)


def check_repo_validity():
    """Check if current directory is a git repository."""
    returncode, _, _ = run_git_command("git rev-parse --git-dir")
    return returncode == 0


def get_conflicted_files():
    """Get list of files with merge conflicts."""
    # Files with conflicts show up with 'U' status (unmerged)
    returncode, stdout, _ = run_git_command("git ls-files -u")

    if returncode != 0 or not stdout:
        return []

    # Extract unique filenames (git ls-files -u shows each stage)
    conflicted_files = set()
    for line in stdout.split('\n'):
        if line.strip():
            # Format: <mode> <object> <stage> <filename>
            parts = line.split('\t')
            if len(parts) > 1:
                filename = parts[1]
                conflicted_files.add(filename)

    return sorted(conflicted_files)


def check_merge_in_progress():
    """Check if a merge operation is in progress."""
    git_dir_code, git_dir, _ = run_git_command("git rev-parse --git-dir")

    if git_dir_code != 0:
        return False, None

    git_dir_path = Path(git_dir)

    # Check for various merge/rebase states
    if (git_dir_path / "MERGE_HEAD").exists():
        return True, "merge"
    elif (git_dir_path / "REBASE_HEAD").exists():
        return True, "rebase"
    elif (git_dir_path / "CHERRY_PICK_HEAD").exists():
        return True, "cherry-pick"
    elif (git_dir_path / "REVERT_HEAD").exists():
        return True, "revert"

    return False, None


def get_conflict_details(files):
    """Get detailed information about conflicts in each file."""
    details = []

    for filepath in files:
        try:
            # Count conflict markers in file
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                conflict_count = content.count('<<<<<<<')

                details.append({
                    "file": filepath,
                    "conflict_regions": conflict_count
                })
        except Exception:
            # If can't read file, just include filename
            details.append({
                "file": filepath,
                "conflict_regions": 0
            })

    return details


def main():
    """Main execution function."""
    # Check if in git repository
    if not check_repo_validity():
        result = {
            "has_conflicts": False,
            "conflict_count": 0,
            "conflicted_files": [],
            "merge_in_progress": False,
            "operation_type": None,
            "error": "not a git repository",
            "checked_at": datetime.now().isoformat()
        }
        print(json.dumps(result, indent=2))
        sys.exit(1)

    # Get conflicted files
    conflicted_files = get_conflicted_files()
    conflict_count = len(conflicted_files)
    has_conflicts = conflict_count > 0

    # Check merge status
    merge_in_progress, operation_type = check_merge_in_progress()

    # Get detailed conflict information
    conflict_details = []
    if has_conflicts:
        conflict_details = get_conflict_details(conflicted_files)

    # Build result
    result = {
        "has_conflicts": has_conflicts,
        "conflict_count": conflict_count,
        "conflicted_files": conflicted_files,
        "conflict_details": conflict_details,
        "merge_in_progress": merge_in_progress,
        "operation_type": operation_type,
        "error": "",
        "checked_at": datetime.now().isoformat()
    }

    # Output JSON
    print(json.dumps(result, indent=2))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Handle unexpected errors
        result = {
            "has_conflicts": False,
            "conflict_count": 0,
            "conflicted_files": [],
            "merge_in_progress": False,
            "operation_type": None,
            "error": f"script error: {str(e)}",
            "checked_at": datetime.now().isoformat()
        }
        print(json.dumps(result, indent=2))
        sys.exit(2)

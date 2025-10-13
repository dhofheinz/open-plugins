#!/usr/bin/env python3
# Script: atomicity-checker.py
# Purpose: Assess if changes form an atomic commit or should be split
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   git diff HEAD | ./atomicity-checker.py
#
# Returns:
#   JSON: {"atomic": true/false, "reasoning": "...", "recommendations": [...]}
#
# Exit Codes:
#   0 - Success
#   1 - No input
#   2 - Analysis error

import sys
import re
import json
from collections import defaultdict

def analyze_atomicity(diff_content):
    """
    Analyze if changes are atomic (single logical unit).

    Criteria for atomic:
    - Single type (all feat, or all fix, etc.)
    - Single scope (all in one module)
    - Logically cohesive
    - Reasonable file count (<= 10)
    """

    lines = diff_content.split('\n')

    # Track changes
    files = []
    types_detected = set()
    scopes_detected = set()
    file_changes = defaultdict(lambda: {'additions': 0, 'deletions': 0})

    current_file = None

    for line in lines:
        # Track files
        if line.startswith('+++ '):
            file_path = line[4:].strip()
            if file_path != '/dev/null' and file_path.startswith('b/'):
                file_path = file_path[2:]
                files.append(file_path)
                current_file = file_path

                # Detect type from file
                if '.test.' in file_path or '.spec.' in file_path:
                    types_detected.add('test')
                elif file_path.endswith('.md'):
                    types_detected.add('docs')
                elif 'package.json' in file_path or 'pom.xml' in file_path:
                    types_detected.add('build')
                elif '.github/workflows' in file_path or '.gitlab-ci' in file_path:
                    types_detected.add('ci')

                # Detect scope from path
                match = re.match(r'src/([^/]+)/', file_path)
                if match:
                    scopes_detected.add(match.group(1))

        # Count line changes
        if current_file:
            if line.startswith('+') and not line.startswith('+++'):
                file_changes[current_file]['additions'] += 1
            elif line.startswith('-') and not line.startswith('---'):
                file_changes[current_file]['deletions'] += 1

        # Detect types from content
        if line.startswith('+'):
            if 'export function' in line or 'export class' in line:
                types_detected.add('feat')
            elif 'fix' in line.lower() or 'error' in line.lower():
                types_detected.add('fix')
            elif 'refactor' in line.lower() or 'rename' in line.lower():
                types_detected.add('refactor')

    # Calculate metrics
    total_files = len(files)
    total_additions = sum(f['additions'] for f in file_changes.values())
    total_deletions = sum(f['deletions'] for f in file_changes.values())
    total_changes = total_additions + total_deletions

    num_types = len(types_detected)
    num_scopes = len(scopes_detected)

    # Atomicity checks
    checks = {
        'single_type': num_types <= 1,
        'single_scope': num_scopes <= 1,
        'reasonable_file_count': total_files <= 10,
        'reasonable_change_size': total_changes <= 500,
        'cohesive': num_types <= 1 and num_scopes <= 1
    }

    # Determine atomicity
    is_atomic = all([
        checks['single_type'] or num_types == 0,
        checks['single_scope'] or num_scopes == 0,
        checks['reasonable_file_count']
    ])

    # Build reasoning
    if is_atomic:
        reasoning = f"Changes are atomic: {total_files} files, "
        if num_types <= 1:
            reasoning += f"single type ({list(types_detected)[0] if types_detected else 'unknown'}), "
        if num_scopes <= 1:
            reasoning += f"single scope ({list(scopes_detected)[0] if scopes_detected else 'root'}). "
        reasoning += "Forms a cohesive logical unit."
    else:
        issues = []
        if num_types > 1:
            issues.append(f"multiple types ({', '.join(types_detected)})")
        if num_scopes > 1:
            issues.append(f"multiple scopes ({', '.join(list(scopes_detected)[:3])})")
        if total_files > 10:
            issues.append(f"many files ({total_files})")

        reasoning = f"Changes are NOT atomic: {', '.join(issues)}. Should be split into focused commits."

    # Generate recommendations if not atomic
    recommendations = []
    if not is_atomic:
        if num_types > 1:
            recommendations.append({
                'strategy': 'Split by type',
                'description': f"Create separate commits for each type: {', '.join(types_detected)}"
            })
        if num_scopes > 1:
            recommendations.append({
                'strategy': 'Split by scope',
                'description': f"Create separate commits for each module: {', '.join(list(scopes_detected)[:3])}"
            })
        if total_files > 15:
            recommendations.append({
                'strategy': 'Split by feature',
                'description': 'Break into smaller logical units (5-10 files per commit)'
            })

    return {
        'atomic': is_atomic,
        'reasoning': reasoning,
        'checks': checks,
        'metrics': {
            'total_files': total_files,
            'total_additions': total_additions,
            'total_deletions': total_deletions,
            'total_changes': total_changes,
            'types_detected': list(types_detected),
            'scopes_detected': list(scopes_detected),
            'num_types': num_types,
            'num_scopes': num_scopes
        },
        'recommendations': recommendations if not is_atomic else []
    }

def main():
    diff_content = sys.stdin.read()

    if not diff_content or not diff_content.strip():
        print(json.dumps({
            'error': 'No diff content provided',
            'atomic': None
        }))
        sys.exit(1)

    try:
        result = analyze_atomicity(diff_content)
        print(json.dumps(result, indent=2))
        sys.exit(0)
    except Exception as e:
        print(json.dumps({
            'error': str(e),
            'atomic': None
        }))
        sys.exit(2)

if __name__ == '__main__':
    main()

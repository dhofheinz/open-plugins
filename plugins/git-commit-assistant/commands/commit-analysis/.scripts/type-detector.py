#!/usr/bin/env python3
# Script: type-detector.py
# Purpose: Detect conventional commit type from git diff analysis
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   git diff HEAD | ./type-detector.py
#   ./type-detector.py < diff.txt
#
# Returns:
#   JSON: {"type": "feat", "confidence": "high", "reasoning": "..."}
#
# Exit Codes:
#   0 - Success
#   1 - No input provided
#   2 - Analysis error

import sys
import re
import json

def detect_type_from_diff(diff_content):
    """
    Detect commit type using priority-based decision tree.

    Priority order:
    1. feat - new files/functions
    2. fix - bug fixes/error handling
    3. docs - documentation only
    4. refactor - code restructuring
    5. style - formatting only
    6. test - test files only
    7. build - dependencies
    8. ci - CI/CD configs
    9. perf - performance
    10. chore - other
    """

    lines = diff_content.split('\n')

    # Indicators
    indicators = {
        'new_files': 0,
        'new_exports': 0,
        'bug_keywords': 0,
        'error_handling': 0,
        'docs_only': True,
        'test_only': True,
        'formatting_only': True,
        'build_files': 0,
        'ci_files': 0,
        'perf_keywords': 0,
        'refactor_keywords': 0
    }

    changed_files = []

    for line in lines:
        # Track changed files
        if line.startswith('+++') or line.startswith('---'):
            file_path = line[4:].strip()
            if file_path != '/dev/null':
                changed_files.append(file_path)

        # New file indicator
        if line.startswith('+++ ') and '/dev/null' not in line:
            if line.startswith('+++ b/'):
                indicators['new_files'] += 1

        # New exports (feat indicator)
        if line.startswith('+') and ('export function' in line or 'export class' in line or 'export const' in line):
            indicators['new_exports'] += 1

        # Bug fix keywords
        if line.startswith('+') and any(kw in line.lower() for kw in ['fix', 'resolve', 'correct', 'handle error']):
            indicators['bug_keywords'] += 1

        # Error handling (fix indicator)
        if line.startswith('+') and ('try {' in line or 'catch' in line or 'if (!  in line or 'throw' in line):
            indicators['error_handling'] += 1

        # Check if only docs changed
        if line.startswith('+++') and not line.endswith('.md') and not '# ' in line:
            if '/dev/null' not in line:
                indicators['docs_only'] = False

        # Check if only tests changed
        if line.startswith('+++'):
            if not ('.test.' in line or '.spec.' in line or '_test' in line):
                if '/dev/null' not in line:
                    indicators['test_only'] = False

        # Check if only formatting
        if line.startswith('+') and len(line.strip()) > 1:
            stripped = line[1:].strip()
            if stripped and not stripped.isspace():
                indicators['formatting_only'] = False

        # Build files (package.json, etc.)
        if 'package.json' in line or 'pom.xml' in line or 'build.gradle' in line:
            indicators['build_files'] += 1

        # CI files
        if '.github/workflows' in line or '.gitlab-ci' in line or 'Jenkinsfile' in line:
            indicators['ci_files'] += 1

        # Performance keywords
        if line.startswith('+') and any(kw in line.lower() for kw in ['optimize', 'cache', 'memoize', 'performance']):
            indicators['perf_keywords'] += 1

        # Refactor keywords
        if line.startswith('+') and any(kw in line.lower() for kw in ['extract', 'rename', 'simplify', 'reorganize']):
            indicators['refactor_keywords'] += 1

    # Decision tree

    # 1. Check for feat
    if indicators['new_files'] > 0 or indicators['new_exports'] > 2:
        return {
            'type': 'feat',
            'confidence': 'high' if indicators['new_files'] > 0 else 'medium',
            'reasoning': f"New files ({indicators['new_files']}) or new exports ({indicators['new_exports']}) detected. Indicates new feature.",
            'indicators': {
                'new_files': indicators['new_files'],
                'new_exports': indicators['new_exports']
            }
        }

    # 2. Check for fix
    if indicators['error_handling'] > 2 or indicators['bug_keywords'] > 1:
        return {
            'type': 'fix',
            'confidence': 'high',
            'reasoning': f"Error handling ({indicators['error_handling']}) or bug fix keywords ({indicators['bug_keywords']}) found. Indicates bug fix.",
            'indicators': {
                'error_handling': indicators['error_handling'],
                'bug_keywords': indicators['bug_keywords']
            }
        }

    # 3. Check for docs
    if indicators['docs_only']:
        return {
            'type': 'docs',
            'confidence': 'high',
            'reasoning': "Only documentation files (.md) changed. Pure documentation update.",
            'indicators': {}
        }

    # 4. Check for style
    if indicators['formatting_only']:
        return {
            'type': 'style',
            'confidence': 'high',
            'reasoning': "Only formatting/whitespace changes detected. No logic changes.",
            'indicators': {}
        }

    # 5. Check for test
    if indicators['test_only']:
        return {
            'type': 'test',
            'confidence': 'high',
            'reasoning': "Only test files changed. Test additions or updates.",
            'indicators': {}
        }

    # 6. Check for build
    if indicators['build_files'] > 0:
        return {
            'type': 'build',
            'confidence': 'high',
            'reasoning': f"Build files ({indicators['build_files']}) changed. Dependency or build system updates.",
            'indicators': {
                'build_files': indicators['build_files']
            }
        }

    # 7. Check for ci
    if indicators['ci_files'] > 0:
        return {
            'type': 'ci',
            'confidence': 'high',
            'reasoning': f"CI/CD configuration files ({indicators['ci_files']}) changed.",
            'indicators': {
                'ci_files': indicators['ci_files']
            }
        }

    # 8. Check for perf
    if indicators['perf_keywords'] > 2:
        return {
            'type': 'perf',
            'confidence': 'medium',
            'reasoning': f"Performance-related keywords ({indicators['perf_keywords']}) found.",
            'indicators': {
                'perf_keywords': indicators['perf_keywords']
            }
        }

    # 9. Check for refactor
    if indicators['refactor_keywords'] > 2:
        return {
            'type': 'refactor',
            'confidence': 'medium',
            'reasoning': f"Refactoring keywords ({indicators['refactor_keywords']}) found.",
            'indicators': {
                'refactor_keywords': indicators['refactor_keywords']
            }
        }

    # 10. Default to chore
    return {
        'type': 'chore',
        'confidence': 'low',
        'reasoning': "Changes don't match specific patterns. Defaulting to chore.",
        'indicators': {}
    }

def main():
    # Read diff from stdin
    diff_content = sys.stdin.read()

    if not diff_content or not diff_content.strip():
        print(json.dumps({
            'error': 'No diff content provided',
            'type': None,
            'confidence': None
        }))
        sys.exit(1)

    try:
        result = detect_type_from_diff(diff_content)
        print(json.dumps(result, indent=2))
        sys.exit(0)
    except Exception as e:
        print(json.dumps({
            'error': str(e),
            'type': None,
            'confidence': None
        }))
        sys.exit(2)

if __name__ == '__main__':
    main()

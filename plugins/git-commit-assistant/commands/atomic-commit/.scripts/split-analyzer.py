#!/usr/bin/env python3
"""
Split Analyzer - Determine if changes should be split

Purpose: Analyze git changes to determine if they should be split into multiple commits
Version: 1.0.0
Usage: ./split-analyzer.py [--verbose] [--threshold N]
Returns:
  Exit 0: Should split
  Exit 1: Already atomic
  Exit 2: Error occurred

Dependencies: git, python3
"""

import sys
import subprocess
import re
import json
from collections import defaultdict
from typing import List, Dict, Tuple, Optional

# Conventional commit types
COMMIT_TYPES = ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf', 'ci', 'build']

class SplitAnalyzer:
    def __init__(self, threshold: int = 10, verbose: bool = False):
        self.threshold = threshold
        self.verbose = verbose
        self.files = []
        self.types = defaultdict(list)
        self.scopes = defaultdict(list)
        self.concerns = []

    def log(self, message: str):
        """Print message if verbose mode enabled"""
        if self.verbose:
            print(f"[DEBUG] {message}", file=sys.stderr)

    def run_git_command(self, args: List[str]) -> str:
        """Execute git command and return output"""
        try:
            result = subprocess.run(
                ['git'] + args,
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            print(f"Error running git command: {e}", file=sys.stderr)
            sys.exit(2)

    def get_changed_files(self) -> List[str]:
        """Get list of changed files (staged and unstaged)"""
        # Staged files
        staged = self.run_git_command(['diff', '--cached', '--name-only'])
        # Unstaged files
        unstaged = self.run_git_command(['diff', '--name-only'])

        files = set()
        files.update(filter(None, staged.split('\n')))
        files.update(filter(None, unstaged.split('\n')))

        return list(files)

    def get_file_diff(self, file_path: str) -> str:
        """Get diff for a specific file"""
        try:
            # Try staged first
            diff = self.run_git_command(['diff', '--cached', file_path])
            if not diff:
                # Try unstaged
                diff = self.run_git_command(['diff', file_path])
            return diff
        except:
            return ""

    def detect_type_from_diff(self, file_path: str, diff: str) -> str:
        """Detect commit type from file path and diff content"""

        # Documentation files
        if any(file_path.endswith(ext) for ext in ['.md', '.txt', '.rst', '.adoc']):
            return 'docs'

        # Test files
        if any(pattern in file_path for pattern in ['test/', 'tests/', 'spec/', '__tests__', '.test.', '.spec.']):
            return 'test'

        # CI/CD files
        if any(pattern in file_path for pattern in ['.github/', '.gitlab-ci', 'jenkins', '.circleci']):
            return 'ci'

        # Build files
        if any(file_path.endswith(ext) for ext in ['package.json', 'pom.xml', 'build.gradle', 'Makefile', 'CMakeLists.txt']):
            return 'build'

        # Analyze diff content
        if not diff:
            return 'chore'

        # Look for new functionality
        added_lines = [line for line in diff.split('\n') if line.startswith('+') and not line.startswith('+++')]

        # Check for function/class additions (new features)
        if any(keyword in ' '.join(added_lines) for keyword in ['function ', 'class ', 'def ', 'const ', 'let ', 'var ']):
            if any(keyword in ' '.join(added_lines) for keyword in ['new ', 'add', 'implement', 'create']):
                return 'feat'

        # Check for bug fix patterns
        if any(keyword in ' '.join(added_lines).lower() for keyword in ['fix', 'bug', 'error', 'issue', 'null', 'undefined']):
            return 'fix'

        # Check for refactoring
        if any(keyword in ' '.join(added_lines).lower() for keyword in ['refactor', 'rename', 'move', 'extract']):
            return 'refactor'

        # Check for performance
        if any(keyword in ' '.join(added_lines).lower() for keyword in ['performance', 'optimize', 'cache', 'memoize']):
            return 'perf'

        # Check for style changes (formatting only)
        removed_lines = [line for line in diff.split('\n') if line.startswith('-') and not line.startswith('---')]
        if len(added_lines) == len(removed_lines):
            # Similar number of additions and deletions might indicate formatting
            return 'style'

        # Default to feat for new code, chore for modifications
        if len(added_lines) > len(removed_lines) * 2:
            return 'feat'

        return 'chore'

    def extract_scope_from_path(self, file_path: str) -> str:
        """Extract scope from file path"""
        parts = file_path.split('/')

        # Skip common prefixes
        skip_prefixes = ['src', 'lib', 'app', 'packages', 'tests', 'test']

        for part in parts:
            if part not in skip_prefixes and part != '.' and part != '..':
                # Remove file extension
                scope = part.split('.')[0]
                return scope

        return 'root'

    def detect_mixed_concerns(self) -> List[str]:
        """Detect mixed concerns in changes"""
        concerns = []

        # Check for feature + unrelated changes
        has_feature = 'feat' in self.types
        has_refactor = 'refactor' in self.types
        has_style = 'style' in self.types

        if has_feature and has_refactor:
            concerns.append("Feature implementation mixed with refactoring")

        if has_feature and has_style:
            concerns.append("Feature implementation mixed with style changes")

        # Check for test + implementation in separate modules
        if 'test' in self.types:
            test_scopes = set(self.scopes[scope] for scope in self.scopes if 'test' in scope)
            impl_scopes = set(self.scopes[scope] for scope in self.scopes if 'test' not in scope)

            if test_scopes != impl_scopes and len(impl_scopes) > 1:
                concerns.append("Tests for multiple unrelated implementations")

        return concerns

    def analyze(self) -> Tuple[bool, str, Dict]:
        """Analyze changes and determine if should split"""

        # Get changed files
        self.files = self.get_changed_files()
        self.log(f"Found {len(self.files)} changed files")

        if not self.files:
            return False, "No changes detected", {}

        # Analyze each file
        for file_path in self.files:
            self.log(f"Analyzing: {file_path}")

            diff = self.get_file_diff(file_path)
            file_type = self.detect_type_from_diff(file_path, diff)
            scope = self.extract_scope_from_path(file_path)

            self.types[file_type].append(file_path)
            self.scopes[scope].append(file_path)

            self.log(f"  Type: {file_type}, Scope: {scope}")

        # Check splitting criteria
        reasons = []

        # Check 1: Multiple types
        if len(self.types) > 1:
            type_list = ', '.join(self.types.keys())
            reasons.append(f"Multiple types detected: {type_list}")
            self.log(f"SPLIT REASON: Multiple types: {type_list}")

        # Check 2: Multiple scopes
        if len(self.scopes) > 1:
            scope_list = ', '.join(self.scopes.keys())
            reasons.append(f"Multiple scopes detected: {scope_list}")
            self.log(f"SPLIT REASON: Multiple scopes: {scope_list}")

        # Check 3: Too many files
        if len(self.files) > self.threshold:
            reasons.append(f"Large change: {len(self.files)} files (threshold: {self.threshold})")
            self.log(f"SPLIT REASON: Too many files: {len(self.files)} > {self.threshold}")

        # Check 4: Mixed concerns
        self.concerns = self.detect_mixed_concerns()
        if self.concerns:
            reasons.append(f"Mixed concerns: {'; '.join(self.concerns)}")
            self.log(f"SPLIT REASON: Mixed concerns detected")

        # Prepare detailed metrics
        metrics = {
            'file_count': len(self.files),
            'types_detected': list(self.types.keys()),
            'type_counts': {t: len(files) for t, files in self.types.items()},
            'scopes_detected': list(self.scopes.keys()),
            'scope_counts': {s: len(files) for s, files in self.scopes.items()},
            'concerns': self.concerns,
            'threshold': self.threshold
        }

        # Determine result
        if reasons:
            should_split = True
            reason = '; '.join(reasons)
            self.log(f"RECOMMENDATION: Should split - {reason}")
        else:
            should_split = False
            reason = "Changes are atomic - single logical unit"
            self.log(f"RECOMMENDATION: Already atomic")

        return should_split, reason, metrics

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Analyze if git changes should be split')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--threshold', type=int, default=10, help='File count threshold')
    parser.add_argument('--json', action='store_true', help='Output JSON format')

    args = parser.parse_args()

    analyzer = SplitAnalyzer(threshold=args.threshold, verbose=args.verbose)
    should_split, reason, metrics = analyzer.analyze()

    if args.json:
        # Output JSON format
        result = {
            'should_split': should_split,
            'reason': reason,
            'metrics': metrics,
            'recommendation': 'split' if should_split else 'atomic'
        }
        print(json.dumps(result, indent=2))
    else:
        # Output human-readable format
        print(f"Should split: {'YES' if should_split else 'NO'}")
        print(f"Reason: {reason}")
        print(f"\nMetrics:")
        print(f"  Files: {metrics['file_count']}")
        print(f"  Types: {', '.join(metrics['types_detected'])}")
        print(f"  Scopes: {', '.join(metrics['scopes_detected'])}")
        if metrics['concerns']:
            print(f"  Concerns: {', '.join(metrics['concerns'])}")

    # Exit code: 0 = should split, 1 = atomic
    sys.exit(0 if should_split else 1)

if __name__ == '__main__':
    main()

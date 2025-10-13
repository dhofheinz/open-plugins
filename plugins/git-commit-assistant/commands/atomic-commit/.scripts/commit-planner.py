#!/usr/bin/env python3
"""
Commit Planner - Create optimal commit sequence

Purpose: Generate optimal commit sequence from file groups
Version: 1.0.0
Usage: ./commit-planner.py [--input FILE] [--output plan|script]
Returns:
  Exit 0: Success
  Exit 1: Error
  Exit 2: Invalid parameters

Dependencies: git, python3
"""

import sys
import json
import subprocess
from collections import defaultdict, deque
from typing import List, Dict, Set, Tuple, Optional

# Type priority for ordering
TYPE_PRIORITY = {
    'feat': 1,      # Features enable other changes
    'fix': 2,       # Fixes should be applied early
    'refactor': 3,  # Restructuring before additions
    'perf': 4,      # Performance after stability
    'test': 5,      # Tests after implementation
    'docs': 6,      # Documentation last
    'style': 7,     # Style changes last
    'chore': 8,     # Housekeeping last
    'ci': 9,        # CI changes last
    'build': 10     # Build changes last
}

class CommitPlanner:
    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.commits = []
        self.dependencies = defaultdict(set)

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
            return ""

    def load_suggestions(self, input_file: Optional[str] = None) -> List[Dict]:
        """Load commit suggestions from file or stdin"""
        try:
            if input_file:
                with open(input_file, 'r') as f:
                    data = json.load(f)
            else:
                # Read from stdin
                data = json.load(sys.stdin)

            return data.get('suggestions', [])
        except Exception as e:
            print(f"Error loading suggestions: {e}", file=sys.stderr)
            sys.exit(1)

    def detect_dependencies(self, commit1: Dict, commit2: Dict) -> bool:
        """Check if commit2 depends on commit1"""

        # Test files depend on implementation files
        if commit1['type'] != 'test' and commit2['type'] == 'test':
            # Check if test scope matches implementation scope
            if commit1.get('scope') == commit2.get('scope'):
                return True

        # Docs depend on features they document
        if commit1['type'] == 'feat' and commit2['type'] == 'docs':
            # Check if docs reference the feature scope
            if commit1.get('scope') in commit2.get('subject', ''):
                return True

        # Fixes may depend on features
        if commit1['type'] == 'feat' and commit2['type'] == 'fix':
            # Check if same scope
            if commit1.get('scope') == commit2.get('scope'):
                return True

        # Check file dependencies (imports)
        files1 = set(commit1.get('files', []))
        files2 = set(commit2.get('files', []))

        # If commit2 files might import from commit1 files
        for file2 in files2:
            for file1 in files1:
                if self.has_import_dependency(file1, file2):
                    return True

        return False

    def has_import_dependency(self, source_file: str, target_file: str) -> bool:
        """Check if target_file imports from source_file"""
        try:
            # Get content of target file
            content = self.run_git_command(['show', f':{target_file}'])

            # Extract module path from source file
            source_module = source_file.replace('/', '.').replace('.py', '').replace('.js', '').replace('.ts', '')

            # Check for import statements
            if any(imp in content for imp in [f'import {source_module}', f'from {source_module}', f"require('{source_module}"]):
                return True

        except:
            pass

        return False

    def build_dependency_graph(self, commits: List[Dict]) -> Dict[int, Set[int]]:
        """Build dependency graph between commits"""
        graph = defaultdict(set)

        for i, commit1 in enumerate(commits):
            for j, commit2 in enumerate(commits):
                if i != j and self.detect_dependencies(commit1, commit2):
                    # commit2 depends on commit1
                    graph[j].add(i)
                    self.log(f"Dependency: Commit {j+1} depends on Commit {i+1}")

        return graph

    def topological_sort(self, commits: List[Dict], dependencies: Dict[int, Set[int]]) -> List[int]:
        """Perform topological sort to respect dependencies"""
        # Calculate in-degree for each node
        in_degree = defaultdict(int)
        for node in range(len(commits)):
            in_degree[node] = len(dependencies[node])

        # Queue of nodes with no dependencies
        queue = deque([node for node in range(len(commits)) if in_degree[node] == 0])
        result = []

        while queue:
            # Sort queue by priority (type priority)
            queue_list = list(queue)
            queue_list.sort(key=lambda x: TYPE_PRIORITY.get(commits[x]['type'], 99))
            queue = deque(queue_list)

            node = queue.popleft()
            result.append(node)

            # Update dependencies
            for other_node in range(len(commits)):
                if node in dependencies[other_node]:
                    dependencies[other_node].remove(node)
                    in_degree[other_node] -= 1
                    if in_degree[other_node] == 0:
                        queue.append(other_node)

        # Check for cycles
        if len(result) != len(commits):
            print("Error: Circular dependency detected", file=sys.stderr)
            sys.exit(1)

        return result

    def create_sequence(self, commits: List[Dict]) -> List[Dict]:
        """Create optimal commit sequence"""
        self.log(f"Planning sequence for {len(commits)} commits")

        # Build dependency graph
        dependencies = self.build_dependency_graph(commits)

        # Topological sort
        order = self.topological_sort(commits, dependencies)

        # Create ordered sequence
        sequence = []
        for idx, commit_idx in enumerate(order):
            commit = commits[commit_idx].copy()
            commit['order'] = idx + 1
            commit['commit_id'] = commit_idx + 1
            commit['original_id'] = commit_idx

            # Determine when can execute
            deps = dependencies[commit_idx]
            if not deps:
                commit['can_execute'] = 'now'
            else:
                dep_ids = [order.index(d) + 1 for d in deps]
                commit['can_execute'] = f"after commit {min(dep_ids)}"

            sequence.append(commit)

        return sequence

    def format_plan(self, sequence: List[Dict]) -> str:
        """Format sequence as readable plan"""
        lines = []

        lines.append("=" * 60)
        lines.append("COMMIT SEQUENCE PLAN")
        lines.append("=" * 60)
        lines.append("")
        lines.append(f"Execution Order: {len(sequence)} commits in sequence")
        lines.append("")

        for commit in sequence:
            lines.append("─" * 60)
            lines.append(f"COMMIT {commit['order']}: {commit['type']}" +
                        (f"({commit.get('scope', '')})" if commit.get('scope') else ""))
            lines.append(f"Files: {len(commit['files'])}")
            lines.append(f"Can execute: {commit['can_execute']}")
            lines.append("─" * 60)
            lines.append("")

            # Message
            lines.append("Message:")
            lines.append(f"  {commit['subject']}")
            if commit.get('body'):
                lines.append("")
                for line in commit['body'].split('\n'):
                    lines.append(f"  {line}")
            lines.append("")

            # Files to stage
            lines.append("Files to stage:")
            for file in commit['files']:
                lines.append(f"  git add {file}")
            lines.append("")

            # Commit command
            commit_msg = commit['subject']
            if commit.get('body'):
                body = commit['body'].replace('"', '\\"')
                commit_cmd = f'git commit -m "{commit_msg}" -m "{body}"'
            else:
                commit_cmd = f'git commit -m "{commit_msg}"'

            lines.append("Command:")
            lines.append(f"  {commit_cmd}")
            lines.append("")

        lines.append("=" * 60)
        lines.append(f"Total commits: {len(sequence)}")
        lines.append(f"Total files: {sum(len(c['files']) for c in sequence)}")
        lines.append("=" * 60)

        return '\n'.join(lines)

    def format_script(self, sequence: List[Dict]) -> str:
        """Format sequence as executable bash script"""
        lines = [
            "#!/bin/bash",
            "# Atomic commit sequence",
            f"# Generated: {subprocess.run(['date'], capture_output=True, text=True).stdout.strip()}",
            f"# Total commits: {len(sequence)}",
            "",
            "set -e  # Exit on error",
            "",
            'echo "🚀 Starting commit sequence..."',
            ""
        ]

        for commit in sequence:
            lines.append(f"# Commit {commit['order']}: {commit['type']}" +
                        (f"({commit.get('scope', '')})" if commit.get('scope') else ""))
            lines.append('echo ""')
            lines.append(f'echo "📝 Commit {commit["order"]}/{len(sequence)}: {commit["type"]}"')

            # Stage files
            for file in commit['files']:
                lines.append(f'git add "{file}"')

            # Commit
            commit_msg = commit['subject']
            if commit.get('body'):
                body = commit['body'].replace('"', '\\"').replace('\n', ' ')
                lines.append(f'git commit -m "{commit_msg}" -m "{body}"')
            else:
                lines.append(f'git commit -m "{commit_msg}"')

            lines.append(f'echo "✅ Commit {commit["order"]} complete"')
            lines.append("")

        lines.append('echo ""')
        lines.append('echo "🎉 All commits completed successfully!"')
        lines.append(f'echo "Total commits: {len(sequence)}"')
        lines.append(f'echo "Total files: {sum(len(c["files"]) for c in sequence)}"')

        return '\n'.join(lines)

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Create optimal commit sequence')
    parser.add_argument('--input', help='Input JSON file (default: stdin)')
    parser.add_argument('--output', choices=['plan', 'script', 'json'], default='plan',
                       help='Output format')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')

    args = parser.parse_args()

    planner = CommitPlanner(verbose=args.verbose)

    # Load suggestions
    commits = planner.load_suggestions(args.input)

    if not commits:
        print("No commit suggestions provided", file=sys.stderr)
        sys.exit(1)

    # Create sequence
    sequence = planner.create_sequence(commits)

    # Output
    if args.output == 'json':
        result = {
            'sequence': sequence,
            'summary': {
                'total_commits': len(sequence),
                'total_files': sum(len(c['files']) for c in sequence)
            }
        }
        print(json.dumps(result, indent=2))
    elif args.output == 'script':
        print(planner.format_script(sequence))
    else:  # plan
        print(planner.format_plan(sequence))

    sys.exit(0)

if __name__ == '__main__':
    main()

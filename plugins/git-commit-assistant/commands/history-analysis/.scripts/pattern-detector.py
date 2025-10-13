#!/usr/bin/env python3

"""
============================================================================
SCRIPT: pattern-detector.py
PURPOSE: Detect commit message patterns and conventions from git history
VERSION: 1.0.0
USAGE: ./pattern-detector.py --count N --branch BRANCH [--detailed]
RETURNS: JSON format with pattern detection results
EXIT CODES:
  0 - Success
  1 - Not a git repository
  2 - No commit history
  3 - Git command failed
DEPENDENCIES: git, python3
============================================================================
"""

import subprocess
import sys
import json
import re
import argparse
from collections import defaultdict
from typing import Dict, List, Tuple


def run_git_command(cmd: List[str]) -> Tuple[int, str]:
    """Execute git command and return exit code and output."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode, result.stdout.strip()
    except Exception as e:
        return 1, str(e)


def is_git_repository() -> bool:
    """Check if current directory is a git repository."""
    code, _ = run_git_command(['git', 'rev-parse', '--git-dir'])
    return code == 0


def has_commits() -> bool:
    """Check if repository has any commits."""
    code, _ = run_git_command(['git', 'log', '-1'])
    return code == 0


def get_commits(count: int, branch: str) -> List[Dict[str, str]]:
    """Fetch commit messages from git log."""
    code, output = run_git_command([
        'git', 'log',
        f'-{count}',
        branch,
        '--format=%H%n%s%n%b%n---COMMIT_SEPARATOR---'
    ])

    if code != 0:
        return []

    commits = []
    lines = output.split('\n')
    i = 0

    while i < len(lines):
        if i + 1 >= len(lines):
            break

        commit_hash = lines[i]
        subject = lines[i + 1] if i + 1 < len(lines) else ""

        # Find body (lines until separator)
        body_lines = []
        i += 2
        while i < len(lines) and lines[i] != '---COMMIT_SEPARATOR---':
            if lines[i].strip():  # Skip empty lines at start
                body_lines.append(lines[i])
            i += 1

        body = '\n'.join(body_lines).strip()

        commits.append({
            'hash': commit_hash,
            'subject': subject,
            'body': body,
            'full': subject + '\n\n' + body if body else subject
        })

        i += 1  # Skip separator

    return commits


def is_conventional_commit(subject: str) -> bool:
    """Check if commit follows conventional commits format."""
    pattern = r'^[a-z]+(\([^)]+\))?: .+'
    return bool(re.match(pattern, subject))


def has_prefix(subject: str) -> bool:
    """Check if commit has prefix format like [PREFIX]."""
    pattern = r'^\[[^\]]+\]'
    return bool(re.match(pattern, subject))


def has_tag(subject: str) -> bool:
    """Check if commit starts with tag like #tag."""
    return subject.startswith('#')


def is_imperative_mood(subject: str) -> bool:
    """
    Check if subject uses imperative mood.
    Simple heuristic: starts with common imperative verbs.
    """
    # Extract first word after type/scope if conventional
    words = subject.lower()
    if ':' in words:
        words = words.split(':', 1)[1].strip()

    # Common imperative verbs and their non-imperative forms to avoid
    imperative_verbs = [
        'add', 'fix', 'update', 'remove', 'delete', 'create', 'implement',
        'change', 'improve', 'optimize', 'refactor', 'enhance', 'correct',
        'resolve', 'merge', 'bump', 'revert', 'document', 'upgrade',
        'downgrade', 'rename', 'move', 'replace', 'extract', 'simplify'
    ]

    # Non-imperative indicators
    non_imperative = ['added', 'fixed', 'updated', 'removed', 'deleted',
                      'created', 'implemented', 'changed', 'improved',
                      'adding', 'fixing', 'updating']

    first_word = words.split()[0] if words.split() else ""

    if first_word in non_imperative:
        return False

    return first_word in imperative_verbs


def is_capitalized(subject: str) -> bool:
    """Check if subject is properly capitalized."""
    # Extract text after type/scope if conventional
    text = subject
    if ':' in text:
        text = text.split(':', 1)[1].strip()

    return text[0].isupper() if text else False


def has_no_period_end(subject: str) -> bool:
    """Check if subject doesn't end with period."""
    return not subject.endswith('.')


def has_blank_line_before_body(full_message: str) -> bool:
    """Check if there's a blank line between subject and body."""
    lines = full_message.split('\n')
    if len(lines) < 3:
        return True  # No body or only one line body

    # Check if second line is empty
    return lines[1].strip() == ''


def is_body_wrapped(body: str, max_width: int = 72) -> bool:
    """Check if body lines are wrapped at max_width."""
    if not body:
        return True

    lines = body.split('\n')
    for line in lines:
        # Allow bullet points and URLs to exceed limit
        if line.strip().startswith(('-', '*', '•', 'http://', 'https://')):
            continue
        if len(line) > max_width:
            return False

    return True


def has_footer(full_message: str) -> bool:
    """Check if commit has footer (BREAKING CHANGE, issue refs, etc.)."""
    footer_patterns = [
        r'BREAKING CHANGE:',
        r'Closes #\d+',
        r'Fixes #\d+',
        r'Refs #\d+',
        r'Co-authored-by:',
        r'Signed-off-by:'
    ]

    for pattern in footer_patterns:
        if re.search(pattern, full_message):
            return True

    return False


def references_issues(full_message: str) -> bool:
    """Check if commit references issues."""
    pattern = r'#\d+|[Cc]loses|[Ff]ixes|[Rr]efs'
    return bool(re.search(pattern, full_message))


def mentions_breaking(full_message: str) -> bool:
    """Check if commit mentions breaking changes."""
    return 'BREAKING CHANGE:' in full_message or 'BREAKING-CHANGE:' in full_message


def has_co_authors(full_message: str) -> bool:
    """Check if commit has co-authors."""
    return 'Co-authored-by:' in full_message


def is_signed_off(full_message: str) -> bool:
    """Check if commit is signed off."""
    return 'Signed-off-by:' in full_message


def includes_rationale(body: str) -> bool:
    """Check if body includes rationale (why/because/to/for)."""
    if not body:
        return False
    words = ['because', 'to ', 'for ', 'why', 'since', 'as ', 'in order to']
    body_lower = body.lower()
    return any(word in body_lower for word in words)


def mentions_impact(body: str) -> bool:
    """Check if body mentions impact."""
    if not body:
        return False
    words = ['affect', 'impact', 'change', 'improve', 'break', 'fix']
    body_lower = body.lower()
    return any(word in body_lower for word in words)


def analyze_patterns(commits: List[Dict[str, str]]) -> Dict:
    """Analyze commit patterns and return results."""
    total = len(commits)

    # Initialize counters
    patterns = {
        'format': defaultdict(int),
        'conventions': defaultdict(int),
        'content': defaultdict(int)
    }

    # Count commits with bodies (for calculations)
    commits_with_body = 0

    for commit in commits:
        subject = commit['subject']
        body = commit['body']
        full = commit['full']

        # Format patterns
        if is_conventional_commit(subject):
            patterns['format']['conventional_commits'] += 1
        elif has_prefix(subject):
            patterns['format']['prefixed'] += 1
        elif has_tag(subject):
            patterns['format']['tagged'] += 1
        else:
            patterns['format']['simple_subject'] += 1

        # Convention patterns
        if is_imperative_mood(subject):
            patterns['conventions']['imperative_mood'] += 1

        if is_capitalized(subject):
            patterns['conventions']['capitalized_subject'] += 1

        if has_no_period_end(subject):
            patterns['conventions']['no_period_end'] += 1

        if body:
            commits_with_body += 1
            if has_blank_line_before_body(full):
                patterns['conventions']['blank_line_before_body'] += 1

            if is_body_wrapped(body):
                patterns['conventions']['wrapped_body'] += 1

        if has_footer(full):
            patterns['conventions']['has_footer'] += 1

        # Content patterns
        if references_issues(full):
            patterns['content']['references_issues'] += 1

        if mentions_breaking(full):
            patterns['content']['mentions_breaking'] += 1

        if has_co_authors(full):
            patterns['content']['has_co_authors'] += 1

        if is_signed_off(full):
            patterns['content']['signed_off'] += 1

        if includes_rationale(body):
            patterns['content']['includes_rationale'] += 1

        if mentions_impact(body):
            patterns['content']['mentions_impact'] += 1

    # Calculate percentages and strength
    def calc_percentage(count, denominator=total):
        return round((count / denominator * 100), 1) if denominator > 0 else 0

    def get_strength(percentage):
        if percentage >= 95:
            return "perfect"
        elif percentage >= 80:
            return "strong"
        elif percentage >= 65:
            return "dominant"
        elif percentage >= 45:
            return "common"
        elif percentage >= 25:
            return "moderate"
        elif percentage >= 10:
            return "occasional"
        elif percentage >= 1:
            return "rare"
        else:
            return "absent"

    # Build results
    results = {
        'format': {},
        'conventions': {},
        'content': {}
    }

    for category, counters in patterns.items():
        for pattern_name, count in counters.items():
            # Use commits_with_body as denominator for body-specific patterns
            if pattern_name in ['blank_line_before_body', 'wrapped_body']:
                denominator = commits_with_body
            else:
                denominator = total

            percentage = calc_percentage(count, denominator)
            results[category][pattern_name] = {
                'count': count,
                'percentage': percentage,
                'strength': get_strength(percentage)
            }

    # Calculate consistency score
    # Weight: format(40), conventions(40), content(20)
    format_score = results['format'].get('conventional_commits', {}).get('percentage', 0)
    convention_scores = [
        results['conventions'].get('imperative_mood', {}).get('percentage', 0),
        results['conventions'].get('capitalized_subject', {}).get('percentage', 0),
        results['conventions'].get('no_period_end', {}).get('percentage', 0)
    ]
    avg_convention = sum(convention_scores) / len(convention_scores) if convention_scores else 0
    content_scores = [
        results['content'].get('references_issues', {}).get('percentage', 0),
        results['content'].get('includes_rationale', {}).get('percentage', 0)
    ]
    avg_content = sum(content_scores) / len(content_scores) if content_scores else 0

    consistency_score = int(format_score * 0.4 + avg_convention * 0.4 + avg_content * 0.2)

    # Determine dominant pattern
    format_patterns = results['format']
    dominant_pattern = max(format_patterns.items(), key=lambda x: x[1]['count'])[0] if format_patterns else "unknown"

    return {
        'commits_analyzed': total,
        'patterns': results,
        'consistency_score': consistency_score,
        'dominant_pattern': dominant_pattern
    }


def main():
    parser = argparse.ArgumentParser(description='Detect commit message patterns')
    parser.add_argument('--count', type=int, default=50, help='Number of commits to analyze')
    parser.add_argument('--branch', default='HEAD', help='Branch to analyze')
    parser.add_argument('--detailed', action='store_true', help='Include detailed breakdown')

    args = parser.parse_args()

    # Validate git repository
    if not is_git_repository():
        print(json.dumps({'error': 'Not in a git repository'}), file=sys.stderr)
        sys.exit(1)

    if not has_commits():
        print(json.dumps({'error': 'No commit history found'}), file=sys.stderr)
        sys.exit(2)

    # Fetch commits
    commits = get_commits(args.count, args.branch)
    if not commits:
        print(json.dumps({'error': 'Failed to fetch commits'}), file=sys.stderr)
        sys.exit(3)

    # Analyze patterns
    results = analyze_patterns(commits)
    results['branch'] = args.branch
    results['detailed'] = args.detailed

    # Output JSON
    print(json.dumps(results, indent=2))
    sys.exit(0)


if __name__ == '__main__':
    main()

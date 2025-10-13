#!/usr/bin/env python3
################################################################################
# Commit Reviewer Script
#
# Purpose: Analyze commit quality including message, changes, and atomicity
# Version: 1.0.0
# Usage: ./commit-reviewer.py <commit-sha>
# Returns: JSON with comprehensive quality analysis
# Exit Codes:
#   0 = Success
#   1 = Commit not found
#   2 = Script execution error
################################################################################

import sys
import json
import subprocess
import re
from typing import Dict, List, Tuple, Any

################################################################################
# Git operations
################################################################################

def git_command(args: List[str]) -> str:
    """Execute git command and return output"""
    try:
        result = subprocess.run(
            ['git'] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return ""

def commit_exists(sha: str) -> bool:
    """Check if commit exists"""
    result = git_command(['rev-parse', '--verify', sha])
    return bool(result)

def get_commit_info(sha: str) -> Dict[str, str]:
    """Get commit metadata"""
    return {
        'sha': git_command(['rev-parse', sha]),
        'author': git_command(['log', '-1', '--format=%an <%ae>', sha]),
        'date': git_command(['log', '-1', '--format=%ad', '--date=short', sha]),
        'subject': git_command(['log', '-1', '--format=%s', sha]),
        'body': git_command(['log', '-1', '--format=%b', sha]),
    }

def get_commit_stats(sha: str) -> Dict[str, int]:
    """Get commit statistics"""
    stats_raw = git_command(['show', '--stat', '--format=', sha])

    files_changed = 0
    insertions = 0
    deletions = 0
    test_files = 0
    doc_files = 0

    for line in stats_raw.split('\n'):
        if '|' in line:
            files_changed += 1
            filename = line.split('|')[0].strip()

            # Count test files
            if 'test' in filename.lower() or 'spec' in filename.lower():
                test_files += 1

            # Count doc files
            if filename.endswith('.md') or 'doc' in filename.lower():
                doc_files += 1

        # Parse summary line: "5 files changed, 234 insertions(+), 12 deletions(-)"
        if 'insertion' in line:
            match = re.search(r'(\d+) insertion', line)
            if match:
                insertions = int(match.group(1))

        if 'deletion' in line:
            match = re.search(r'(\d+) deletion', line)
            if match:
                deletions = int(match.group(1))

    return {
        'files_changed': files_changed,
        'insertions': insertions,
        'deletions': deletions,
        'test_files': test_files,
        'doc_files': doc_files,
    }

################################################################################
# Message analysis
################################################################################

def analyze_message(subject: str, body: str) -> Dict[str, Any]:
    """Analyze commit message quality"""

    # Check conventional commits format
    conventional_pattern = r'^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9\-]+\))?: .+'
    is_conventional = bool(re.match(conventional_pattern, subject, re.IGNORECASE))

    # Extract type and scope if conventional
    commit_type = None
    commit_scope = None

    if is_conventional:
        match = re.match(r'^([a-z]+)(?:\(([a-z0-9\-]+)\))?: ', subject, re.IGNORECASE)
        if match:
            commit_type = match.group(1).lower()
            commit_scope = match.group(2) if match.group(2) else None

    # Check subject length
    subject_length = len(subject)
    subject_ok = subject_length <= 50

    # Check imperative mood (basic heuristics)
    imperative_verbs = ['add', 'fix', 'update', 'remove', 'refactor', 'improve', 'implement']
    past_tense_patterns = ['added', 'fixed', 'updated', 'removed', 'refactored', 'improved', 'implemented']

    subject_lower = subject.lower()
    uses_imperative = any(subject_lower.startswith(verb) for verb in imperative_verbs)
    uses_past_tense = any(pattern in subject_lower for pattern in past_tense_patterns)

    # Check if body exists and is useful
    has_body = bool(body.strip())
    body_lines = body.strip().split('\n') if has_body else []
    body_line_count = len([line for line in body_lines if line.strip()])

    # Body quality assessment
    has_explanation = body_line_count > 2
    uses_bullets = any(line.strip().startswith(('-', '*', '•')) for line in body_lines)

    return {
        'subject': subject,
        'body': body if has_body else None,
        'subject_length': subject_length,
        'subject_ok': subject_ok,
        'has_body': has_body,
        'body_line_count': body_line_count,
        'conventional': is_conventional,
        'type': commit_type,
        'scope': commit_scope,
        'imperative': uses_imperative and not uses_past_tense,
        'explanation': has_explanation,
        'uses_bullets': uses_bullets,
    }

################################################################################
# Atomicity analysis
################################################################################

def analyze_atomicity(sha: str, stats: Dict[str, int]) -> Dict[str, Any]:
    """Analyze if commit is atomic"""

    # Get changed files
    changed_files = git_command(['show', '--name-only', '--format=', sha]).split('\n')
    changed_files = [f for f in changed_files if f.strip()]

    # Analyze file types
    file_types = set()
    scopes = set()

    for filepath in changed_files:
        # Determine file type
        if 'test' in filepath.lower() or 'spec' in filepath.lower():
            file_types.add('test')
        elif filepath.endswith('.md') or 'doc' in filepath.lower():
            file_types.add('docs')
        elif any(filepath.endswith(ext) for ext in ['.js', '.ts', '.py', '.go', '.rs', '.java']):
            file_types.add('code')
        elif any(filepath.endswith(ext) for ext in ['.json', '.yaml', '.yml', '.toml']):
            file_types.add('config')

        # Determine scope from path
        parts = filepath.split('/')
        if len(parts) > 1:
            scopes.add(parts[0])

    # Check for multiple types (excluding test + code as acceptable)
    suspicious_type_mix = False
    if 'docs' in file_types and 'code' in file_types:
        suspicious_type_mix = True
    if 'config' in file_types and len(file_types) > 2:
        suspicious_type_mix = True

    # Check for multiple scopes
    multiple_scopes = len(scopes) > 2

    # Size check (too large likely non-atomic)
    too_large = stats['files_changed'] > 15 or stats['insertions'] > 500

    # Determine atomicity
    is_atomic = not (suspicious_type_mix or multiple_scopes or too_large)

    issues = []
    if suspicious_type_mix:
        issues.append(f"Mixes {' and '.join(file_types)}")
    if multiple_scopes:
        issues.append(f"Affects multiple scopes: {', '.join(sorted(scopes))}")
    if too_large:
        issues.append(f"Large commit: {stats['files_changed']} files")

    return {
        'atomic': is_atomic,
        'file_types': sorted(file_types),
        'scopes': sorted(scopes),
        'issues': issues,
    }

################################################################################
# Quality scoring
################################################################################

def calculate_score(message: Dict[str, Any], stats: Dict[str, int], atomicity: Dict[str, Any]) -> Tuple[int, str, List[str]]:
    """Calculate overall quality score (0-100)"""

    score = 100
    issues = []

    # Message quality (40 points)
    if not message['conventional']:
        score -= 10
        issues.append("Not using conventional commits format")

    if not message['subject_ok']:
        score -= 5
        issues.append(f"Subject too long ({message['subject_length']} chars, should be ≤50)")

    if not message['imperative']:
        score -= 5
        issues.append("Subject not in imperative mood")

    if not message['has_body'] and stats['files_changed'] > 3:
        score -= 10
        issues.append("No commit body explaining changes")
    elif message['has_body'] and not message['explanation']:
        score -= 5
        issues.append("Commit body too brief")

    # Atomicity (30 points)
    if not atomicity['atomic']:
        score -= 20
        issues.extend(atomicity['issues'])

    # Test coverage (20 points)
    has_code_changes = 'code' in atomicity['file_types']
    has_test_changes = stats['test_files'] > 0

    if has_code_changes and not has_test_changes and stats['insertions'] > 100:
        score -= 15
        issues.append("No tests included for significant code changes")
    elif has_code_changes and not has_test_changes:
        score -= 5
        issues.append("No tests included")

    # Size appropriateness (10 points)
    if stats['files_changed'] > 20:
        score -= 5
        issues.append(f"Very large commit ({stats['files_changed']} files)")

    if stats['insertions'] > 1000:
        score -= 5
        issues.append(f"Very large changeset ({stats['insertions']} insertions)")

    # Determine quality level
    if score >= 90:
        quality = "excellent"
    elif score >= 70:
        quality = "good"
    elif score >= 50:
        quality = "fair"
    else:
        quality = "poor"

    return max(0, score), quality, issues

################################################################################
# Main execution
################################################################################

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: commit-reviewer.py <commit-sha>"}))
        sys.exit(2)

    commit_sha = sys.argv[1]

    # Check if git repository
    if not git_command(['rev-parse', '--git-dir']):
        print(json.dumps({"error": "Not a git repository"}))
        sys.exit(2)

    # Check if commit exists
    if not commit_exists(commit_sha):
        print(json.dumps({"error": f"Commit not found: {commit_sha}"}))
        sys.exit(1)

    # Gather commit information
    info = get_commit_info(commit_sha)
    stats = get_commit_stats(commit_sha)
    message_analysis = analyze_message(info['subject'], info['body'])
    atomicity_analysis = analyze_atomicity(commit_sha, stats)

    # Calculate quality score
    score, quality, issues = calculate_score(message_analysis, stats, atomicity_analysis)

    # Build output
    output = {
        'commit': info['sha'][:8],
        'author': info['author'],
        'date': info['date'],
        'message': {
            'subject': message_analysis['subject'],
            'body': message_analysis['body'],
            'subject_length': message_analysis['subject_length'],
            'has_body': message_analysis['has_body'],
            'conventional': message_analysis['conventional'],
            'type': message_analysis['type'],
            'scope': message_analysis['scope'],
        },
        'changes': {
            'files_changed': stats['files_changed'],
            'insertions': stats['insertions'],
            'deletions': stats['deletions'],
            'test_files': stats['test_files'],
            'doc_files': stats['doc_files'],
        },
        'quality': {
            'atomic': atomicity_analysis['atomic'],
            'message_quality': quality,
            'test_coverage': stats['test_files'] > 0,
            'issues': issues,
        },
        'score': score,
    }

    print(json.dumps(output, indent=2))
    sys.exit(0)

if __name__ == '__main__':
    main()

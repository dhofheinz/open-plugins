#!/usr/bin/env python3

"""
============================================================================
SCRIPT: convention-recommender.py
PURPOSE: Generate project-specific commit convention recommendations
VERSION: 1.0.0
USAGE: ./convention-recommender.py --count N --branch BRANCH [--priority LEVEL]
RETURNS: JSON format with prioritized recommendations
EXIT CODES:
  0 - Success
  1 - Not a git repository
  2 - No commit history
  3 - Analysis failed
DEPENDENCIES: git, python3, style-analyzer.sh, pattern-detector.py, scope-extractor.sh
============================================================================
"""

import subprocess
import sys
import json
import argparse
import os
from typing import Dict, List, Tuple


def run_script(script_path: str, args: List[str]) -> Tuple[int, str]:
    """Execute a script and return exit code and output."""
    try:
        cmd = [script_path] + args
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False,
            cwd=os.path.dirname(script_path)
        )
        return result.returncode, result.stdout.strip()
    except Exception as e:
        return 1, json.dumps({'error': str(e)})


def gather_analysis_data(count: int, branch: str, scripts_dir: str) -> Dict:
    """Gather all analysis data from other scripts."""
    data = {}

    # Run style-analyzer.sh
    style_script = os.path.join(scripts_dir, 'style-analyzer.sh')
    code, output = run_script(style_script, [str(count), branch])
    if code == 0:
        try:
            data['style'] = json.loads(output)
        except json.JSONDecodeError:
            data['style'] = {}

    # Run pattern-detector.py
    pattern_script = os.path.join(scripts_dir, 'pattern-detector.py')
    code, output = run_script(pattern_script, [
        '--count', str(count),
        '--branch', branch
    ])
    if code == 0:
        try:
            data['patterns'] = json.loads(output)
        except json.JSONDecodeError:
            data['patterns'] = {}

    # Run scope-extractor.sh
    scope_script = os.path.join(scripts_dir, 'scope-extractor.sh')
    code, output = run_script(scope_script, [
        '--count', str(count),
        '--branch', branch,
        '--min-frequency', '2'
    ])
    if code == 0:
        try:
            data['scopes'] = json.loads(output)
        except json.JSONDecodeError:
            data['scopes'] = {}

    return data


def generate_recommendations(data: Dict, priority_filter: str) -> Dict:
    """Generate prioritized recommendations based on analysis data."""
    recommendations = {
        'high_priority': [],
        'medium_priority': [],
        'low_priority': []
    }

    style = data.get('style', {}).get('project_style', {})
    patterns = data.get('patterns', {})
    scopes = data.get('scopes', {})

    # HIGH PRIORITY RECOMMENDATIONS

    # 1. Conventional commits adoption
    conv_pct = style.get('conventional_commits_percentage', 0)
    if conv_pct < 50:
        recommendations['high_priority'].append({
            'id': 1,
            'title': 'Adopt Conventional Commits Format',
            'status': 'needs_improvement',
            'current_usage': conv_pct,
            'target_usage': 80,
            'action': 'Migrate to conventional commits format: <type>(<scope>): <subject>',
            'benefit': 'Enables automated changelog, semantic versioning, and better git history',
            'priority': 'high',
            'examples': [
                'feat(auth): implement OAuth2 authentication',
                'fix(api): handle null pointer in user endpoint',
                'docs: update API documentation'
            ]
        })
    elif conv_pct < 80:
        recommendations['medium_priority'].append({
            'id': 1,
            'title': 'Increase Conventional Commits Usage',
            'status': 'moderate',
            'current_usage': conv_pct,
            'target_usage': 90,
            'action': 'Encourage team to use conventional commits consistently',
            'benefit': 'Better consistency and tooling support',
            'priority': 'medium'
        })
    else:
        recommendations['high_priority'].append({
            'id': 1,
            'title': 'Continue Using Conventional Commits',
            'status': 'good',
            'current_usage': conv_pct,
            'target_usage': 90,
            'action': 'Maintain current practice',
            'benefit': 'Already well-adopted, enables automation',
            'priority': 'high'
        })

    # 2. Subject line length
    avg_length = style.get('average_subject_length', 0)
    if avg_length > 60:
        recommendations['high_priority'].append({
            'id': 2,
            'title': 'Reduce Subject Line Length',
            'status': 'needs_improvement',
            'current_value': avg_length,
            'target_value': 50,
            'action': 'Keep subject lines under 50 characters',
            'benefit': 'Better readability in git log, GitHub UI, and terminal',
            'priority': 'high'
        })
    elif avg_length > 50:
        recommendations['medium_priority'].append({
            'id': 2,
            'title': 'Optimize Subject Line Length',
            'status': 'moderate',
            'current_value': avg_length,
            'target_value': 50,
            'action': 'Aim for concise subject lines (under 50 chars)',
            'priority': 'medium'
        })

    # 3. Imperative mood
    imperative_pct = style.get('imperative_mood_percentage', 0)
    if imperative_pct < 80:
        recommendations['high_priority'].append({
            'id': 3,
            'title': 'Use Imperative Mood Consistently',
            'status': 'needs_improvement',
            'current_usage': imperative_pct,
            'target_usage': 90,
            'action': 'Use imperative mood: "add" not "added", "fix" not "fixed"',
            'benefit': 'Clearer, more professional commit messages',
            'priority': 'high',
            'examples': [
                '✓ add user authentication',
                '✗ added user authentication',
                '✓ fix null pointer exception',
                '✗ fixed null pointer exception'
            ]
        })

    # MEDIUM PRIORITY RECOMMENDATIONS

    # 4. Body usage
    body_pct = style.get('has_body_percentage', 0)
    if body_pct < 50:
        recommendations['medium_priority'].append({
            'id': 4,
            'title': 'Increase Body Usage for Complex Changes',
            'status': 'low',
            'current_usage': body_pct,
            'target_usage': 50,
            'action': 'Add commit body for non-trivial changes (>3 files, complex logic)',
            'benefit': 'Better context for code review and future reference',
            'priority': 'medium',
            'when_to_use': [
                'Multiple files changed (>3)',
                'Complex logic modifications',
                'Breaking changes',
                'Security-related changes'
            ]
        })

    # 5. Issue references
    issue_pct = style.get('references_issues_percentage', 0)
    if issue_pct > 50:
        recommendations['medium_priority'].append({
            'id': 5,
            'title': 'Continue Issue Referencing Practice',
            'status': 'good',
            'current_usage': issue_pct,
            'action': 'Maintain consistent issue references',
            'benefit': 'Excellent traceability between commits and issues',
            'priority': 'medium'
        })
    elif issue_pct > 25:
        recommendations['medium_priority'].append({
            'id': 5,
            'title': 'Increase Issue References',
            'status': 'moderate',
            'current_usage': issue_pct,
            'target_usage': 60,
            'action': 'Reference related issues: "Closes #123", "Fixes #456", "Refs #789"',
            'benefit': 'Better traceability',
            'priority': 'medium'
        })

    # LOW PRIORITY RECOMMENDATIONS

    # 6. Scope standardization
    scope_count = scopes.get('total_scopes', 0)
    if scope_count > 0:
        top_scopes = scopes.get('scopes', [])[:5]
        scope_names = [s['name'] for s in top_scopes]
        recommendations['medium_priority'].append({
            'id': 6,
            'title': 'Use Standard Project Scopes',
            'status': 'good',
            'action': f'Use these common scopes: {", ".join(scope_names)}',
            'benefit': 'Consistent scope usage across team',
            'priority': 'medium',
            'scopes': scope_names
        })

    # 7. Co-author attribution
    recommendations['low_priority'].append({
        'id': 7,
        'title': 'Consider Co-Author Attribution',
        'status': 'optional',
        'action': 'Add co-authors for pair programming: Co-authored-by: Name <email>',
        'benefit': 'Team recognition and contribution tracking',
        'priority': 'low',
        'example': 'Co-authored-by: Jane Doe <jane@example.com>'
    })

    # 8. Breaking change documentation
    recommendations['low_priority'].append({
        'id': 8,
        'title': 'Document Breaking Changes',
        'status': 'important',
        'action': 'Use BREAKING CHANGE: footer when applicable',
        'benefit': 'Clear communication of breaking changes for semantic versioning',
        'priority': 'low',
        'example': 'BREAKING CHANGE: API now requires OAuth tokens instead of API keys'
    })

    # Filter by priority if specified
    if priority_filter and priority_filter != 'all':
        priority_key = f'{priority_filter}_priority'
        filtered = {priority_key: recommendations.get(priority_key, [])}
        return filtered

    return recommendations


def generate_style_guide(data: Dict) -> Dict:
    """Generate project-specific style guide."""
    style = data.get('style', {}).get('project_style', {})
    scopes_data = data.get('scopes', {})

    # Extract common types
    common_types = style.get('common_types', [])
    types_sorted = sorted(common_types, key=lambda x: x.get('count', 0), reverse=True)

    # Extract common scopes
    scopes = scopes_data.get('scopes', [])[:10]

    # Build style guide
    return {
        'format': '<type>(<scope>): <subject>',
        'max_subject_length': 50,
        'body_wrap': 72,
        'types': [
            {
                'name': t.get('type', 'unknown'),
                'percentage': t.get('percentage', 0),
                'description': get_type_description(t.get('type', 'unknown'))
            }
            for t in types_sorted
        ],
        'scopes': [
            {
                'name': s.get('name', 'unknown'),
                'percentage': s.get('percentage', 0),
                'description': s.get('description', 'Unknown'),
                'category': s.get('category', 'other')
            }
            for s in scopes
        ],
        'rules': [
            'Use imperative mood ("add" not "added")',
            'Capitalize first letter of subject',
            'No period at end of subject line',
            'Use lowercase for scopes',
            'Wrap body at 72 characters',
            'Separate body and footer with blank line',
            'Use bullet points in body',
            'Reference issues when applicable'
        ]
    }


def get_type_description(type_name: str) -> str:
    """Get description for commit type."""
    descriptions = {
        'feat': 'New features',
        'fix': 'Bug fixes',
        'docs': 'Documentation changes',
        'style': 'Formatting changes (no code change)',
        'refactor': 'Code restructuring',
        'perf': 'Performance improvements',
        'test': 'Test additions/updates',
        'build': 'Build system changes',
        'ci': 'CI/CD changes',
        'chore': 'Maintenance tasks',
        'revert': 'Revert previous commit'
    }
    return descriptions.get(type_name, 'Other changes')


def calculate_confidence(data: Dict) -> str:
    """Calculate confidence level of recommendations."""
    commits_analyzed = data.get('style', {}).get('project_style', {}).get('commits_analyzed', 0)

    if commits_analyzed >= 100:
        return 'high'
    elif commits_analyzed >= 50:
        return 'medium'
    elif commits_analyzed >= 20:
        return 'low'
    else:
        return 'very_low'


def main():
    parser = argparse.ArgumentParser(description='Generate convention recommendations')
    parser.add_argument('--count', type=int, default=50, help='Number of commits to analyze')
    parser.add_argument('--branch', default='HEAD', help='Branch to analyze')
    parser.add_argument('--priority', choices=['high', 'medium', 'low', 'all'], default='all',
                        help='Filter by priority level')

    args = parser.parse_args()

    # Get scripts directory
    scripts_dir = os.path.dirname(os.path.abspath(__file__))

    # Gather analysis data
    data = gather_analysis_data(args.count, args.branch, scripts_dir)

    if not data:
        print(json.dumps({'error': 'Failed to gather analysis data'}), file=sys.stderr)
        sys.exit(3)

    # Generate recommendations
    recommendations = generate_recommendations(data, args.priority)

    # Generate style guide
    style_guide = generate_style_guide(data)

    # Calculate confidence
    confidence = calculate_confidence(data)

    # Calculate consistency score
    consistency_score = data.get('patterns', {}).get('consistency_score', 0)

    # Build output
    output = {
        'commits_analyzed': data.get('style', {}).get('project_style', {}).get('commits_analyzed', 0),
        'branch': args.branch,
        'consistency_score': consistency_score,
        'confidence': confidence,
        'recommendations': recommendations,
        'style_guide': style_guide,
        'automation': {
            'commitlint': True,
            'changelog_generator': 'standard-version',
            'semantic_release': True
        }
    }

    # Output JSON
    print(json.dumps(output, indent=2))
    sys.exit(0)


if __name__ == '__main__':
    main()

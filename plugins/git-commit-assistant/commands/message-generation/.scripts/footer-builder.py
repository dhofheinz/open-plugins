#!/usr/bin/env python3
# Script: footer-builder.py
# Purpose: Build commit message footer with breaking changes and issue references
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   echo '{"breaking":"API changed","closes":"123,456"}' | ./footer-builder.py
#   cat input.json | ./footer-builder.py
#
# Returns:
#   JSON: {"footer": "...", "components": {...}, "valid": true}
#
# Exit Codes:
#   0 - Success
#   1 - Invalid input
#   2 - Processing error

import sys
import json
import re
import textwrap

def wrap_text(text, width=72, subsequent_indent=''):
    """Wrap text at specified width."""
    wrapper = textwrap.TextWrapper(
        width=width,
        subsequent_indent=subsequent_indent,
        break_long_words=False,
        break_on_hyphens=False
    )
    return wrapper.fill(text)

def format_breaking_change(description):
    """Format breaking change notice."""
    if not description:
        return None

    # Ensure BREAKING CHANGE is uppercase
    # Wrap at 72 characters with continuation indentation
    wrapped = wrap_text(
        description,
        width=72,
        subsequent_indent=''
    )

    return f"BREAKING CHANGE: {wrapped}"

def parse_issue_numbers(issue_string):
    """Parse comma-separated issue numbers into list."""
    if not issue_string:
        return []

    # Remove any # symbols
    issue_string = issue_string.replace('#', '')

    # Split by comma and clean
    issues = [num.strip() for num in issue_string.split(',') if num.strip()]

    # Validate all are numbers
    valid_issues = []
    for issue in issues:
        if issue.isdigit():
            valid_issues.append(issue)
        else:
            # Try to extract number
            match = re.search(r'\d+', issue)
            if match:
                valid_issues.append(match.group())

    return valid_issues

def format_issue_references(closes=None, fixes=None, refs=None):
    """Format issue references."""
    lines = []

    # Closes (for features/pull requests)
    if closes:
        issues = parse_issue_numbers(closes)
        if issues:
            if len(issues) == 1:
                lines.append(f"Closes #{issues[0]}")
            else:
                # Format as comma-separated list
                issue_refs = ', '.join([f"#{num}" for num in issues])
                lines.append(f"Closes {issue_refs}")

    # Fixes (for bug fixes)
    if fixes:
        issues = parse_issue_numbers(fixes)
        if issues:
            if len(issues) == 1:
                lines.append(f"Fixes #{issues[0]}")
            else:
                issue_refs = ', '.join([f"#{num}" for num in issues])
                lines.append(f"Fixes {issue_refs}")

    # Refs (for related issues)
    if refs:
        issues = parse_issue_numbers(refs)
        if issues:
            if len(issues) == 1:
                lines.append(f"Refs #{issues[0]}")
            else:
                issue_refs = ', '.join([f"#{num}" for num in issues])
                lines.append(f"Refs {issue_refs}")

    return lines

def format_metadata(reviewed=None, signed=None):
    """Format metadata like Reviewed-by and Signed-off-by."""
    lines = []

    if reviewed:
        lines.append(f"Reviewed-by: {reviewed}")

    if signed:
        # Validate email format
        if '@' in signed and '<' in signed and '>' in signed:
            lines.append(f"Signed-off-by: {signed}")
        else:
            # Try to format properly
            lines.append(f"Signed-off-by: {signed}")

    return lines

def build_footer(data):
    """
    Build commit message footer from input data.

    Args:
        data: dict with keys: breaking, closes, fixes, refs, reviewed, signed

    Returns:
        dict with footer, components, valid status
    """

    # Extract parameters
    breaking = data.get('breaking', '').strip()
    closes = data.get('closes', '').strip()
    fixes = data.get('fixes', '').strip()
    refs = data.get('refs', '').strip()
    reviewed = data.get('reviewed', '').strip()
    signed = data.get('signed', '').strip()

    # Check if any parameter provided
    has_content = any([breaking, closes, fixes, refs, reviewed, signed])

    if not has_content:
        return {
            'error': 'At least one footer component is required',
            'footer': None,
            'valid': False
        }

    # Build footer components
    footer_lines = []
    components = {
        'breaking_change': False,
        'closes_issues': 0,
        'fixes_issues': 0,
        'refs_issues': 0,
        'reviewed_by': False,
        'signed_off': False
    }

    # Breaking change (always first)
    if breaking:
        breaking_line = format_breaking_change(breaking)
        if breaking_line:
            footer_lines.append(breaking_line)
            components['breaking_change'] = True

    # Issue references
    issue_lines = format_issue_references(closes, fixes, refs)
    footer_lines.extend(issue_lines)

    # Count issues
    if closes:
        components['closes_issues'] = len(parse_issue_numbers(closes))
    if fixes:
        components['fixes_issues'] = len(parse_issue_numbers(fixes))
    if refs:
        components['refs_issues'] = len(parse_issue_numbers(refs))

    # Metadata
    metadata_lines = format_metadata(reviewed, signed)
    footer_lines.extend(metadata_lines)

    if reviewed:
        components['reviewed_by'] = True
    if signed:
        components['signed_off'] = True

    # Join all lines
    footer = '\n'.join(footer_lines)

    # Validate footer
    warnings = []

    # Check breaking change format
    if breaking and not footer.startswith('BREAKING CHANGE:'):
        warnings.append('BREAKING CHANGE must be uppercase')

    # Check issue reference format
    for line in footer_lines:
        if 'closes' in line.lower() and not line.startswith('Closes'):
            warnings.append('Use "Closes" (capitalized)')
        if 'fixes' in line.lower() and not line.startswith('Fixes'):
            warnings.append('Use "Fixes" (capitalized)')
        if 'refs' in line.lower() and not line.startswith('Refs'):
            warnings.append('Use "Refs" (capitalized)')

    # Check for proper issue number format
    if any([closes, fixes, refs]):
        # Make sure all issue numbers are valid
        all_issues = parse_issue_numbers(closes) + parse_issue_numbers(fixes) + parse_issue_numbers(refs)
        if not all_issues:
            warnings.append('No valid issue numbers found')

    # Build response
    response = {
        'footer': footer,
        'components': components,
        'line_count': len(footer_lines),
        'has_breaking': components['breaking_change'],
        'total_issues': components['closes_issues'] + components['fixes_issues'] + components['refs_issues'],
        'warnings': warnings,
        'valid': len(warnings) == 0
    }

    # Add quality score
    score = 100
    if not components['breaking_change'] and breaking:
        score -= 10
    if warnings:
        score -= len(warnings) * 5

    response['quality_score'] = max(0, score)

    return response

def main():
    """Main entry point."""

    try:
        # Read JSON input from stdin
        input_data = sys.stdin.read()

        if not input_data or not input_data.strip():
            print(json.dumps({
                'error': 'No input provided',
                'footer': None,
                'valid': False
            }))
            sys.exit(1)

        # Parse JSON
        try:
            data = json.loads(input_data)
        except json.JSONDecodeError as e:
            print(json.dumps({
                'error': f'Invalid JSON: {str(e)}',
                'footer': None,
                'valid': False
            }))
            sys.exit(1)

        # Build footer
        result = build_footer(data)

        # Output result
        print(json.dumps(result, indent=2))

        # Exit code based on result
        if 'error' in result:
            sys.exit(2)
        elif not result.get('valid', False):
            sys.exit(1)
        else:
            sys.exit(0)

    except Exception as e:
        print(json.dumps({
            'error': f'Unexpected error: {str(e)}',
            'footer': None,
            'valid': False
        }))
        sys.exit(2)

if __name__ == '__main__':
    main()

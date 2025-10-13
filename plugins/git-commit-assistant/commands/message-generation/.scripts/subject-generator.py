#!/usr/bin/env python3
# Script: subject-generator.py
# Purpose: Generate conventional commit subject line with validation
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   echo '{"type":"feat","scope":"auth","description":"add OAuth"}' | ./subject-generator.py
#   cat input.json | ./subject-generator.py
#
# Returns:
#   JSON: {"subject": "feat(auth): add OAuth", "length": 22, "warnings": [], "suggestions": []}
#
# Exit Codes:
#   0 - Success
#   1 - Invalid input
#   2 - Validation error

import sys
import json
import re

def enforce_imperative_mood(text):
    """Convert common non-imperative forms to imperative mood."""

    # Common past tense to imperative conversions
    conversions = {
        r'\badded\b': 'add',
        r'\bfixed\b': 'fix',
        r'\bupdated\b': 'update',
        r'\bremoved\b': 'remove',
        r'\bchanged\b': 'change',
        r'\bimproved\b': 'improve',
        r'\brefactored\b': 'refactor',
        r'\bimplemented\b': 'implement',
        r'\bcreated\b': 'create',
        r'\bdeleted\b': 'delete',
        r'\bmodified\b': 'modify',
        r'\boptimized\b': 'optimize',
        r'\bmoved\b': 'move',
        r'\brenamed\b': 'rename',
        r'\bcleaned\b': 'clean',
        r'\bintroduced\b': 'introduce',
    }

    # Present tense (3rd person) to imperative
    present_conversions = {
        r'\badds\b': 'add',
        r'\bfixes\b': 'fix',
        r'\bupdates\b': 'update',
        r'\bremoves\b': 'remove',
        r'\bchanges\b': 'change',
        r'\bimproves\b': 'improve',
        r'\brefactors\b': 'refactor',
        r'\bimplements\b': 'implement',
        r'\bcreates\b': 'create',
        r'\bdeletes\b': 'delete',
        r'\bmodifies\b': 'modify',
        r'\boptimizes\b': 'optimize',
        r'\bmoves\b': 'move',
        r'\brenames\b': 'rename',
        r'\bcleans\b': 'clean',
        r'\bintroduces\b': 'introduce',
    }

    original = text

    # Apply conversions
    for pattern, replacement in conversions.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)

    for pattern, replacement in present_conversions.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)

    # Track if changes were made
    changed = (original != text)

    return text, changed

def check_capitalization(text):
    """Check if description starts with lowercase (should not be capitalized)."""
    if not text:
        return True, []

    warnings = []
    if text[0].isupper():
        warnings.append({
            'type': 'capitalization',
            'message': 'Description should start with lowercase',
            'current': text,
            'suggested': text[0].lower() + text[1:]
        })
        return False, warnings

    return True, warnings

def check_period_at_end(text):
    """Check if description ends with period (should not)."""
    warnings = []
    if text.endswith('.'):
        warnings.append({
            'type': 'punctuation',
            'message': 'Subject should not end with period',
            'current': text,
            'suggested': text[:-1]
        })
        return False, warnings

    return True, warnings

def shorten_description(description, max_length, type_scope_part):
    """Attempt to shorten description to fit within max_length."""

    # Calculate available space for description
    prefix_length = len(type_scope_part) + 2  # +2 for ": "
    available_length = max_length - prefix_length

    if len(description) <= available_length:
        return description, []

    suggestions = []

    # Strategy 1: Remove filler words
    filler_words = ['a', 'an', 'the', 'some', 'very', 'really', 'just', 'quite']
    shortened = description
    for word in filler_words:
        shortened = re.sub(r'\b' + word + r'\b\s*', '', shortened, flags=re.IGNORECASE)
        shortened = shortened.strip()
        if len(shortened) <= available_length:
            suggestions.append({
                'strategy': 'remove_filler',
                'description': shortened,
                'saved': len(description) - len(shortened)
            })
            return shortened, suggestions

    # Strategy 2: Truncate with ellipsis (not recommended but possible)
    if available_length > 3:
        truncated = description[:available_length - 3] + '...'
        suggestions.append({
            'strategy': 'truncate',
            'description': truncated,
            'warning': 'Truncation loses information - consider moving details to body'
        })

    # Strategy 3: Suggest moving to body
    suggestions.append({
        'strategy': 'move_to_body',
        'description': description[:available_length],
        'remaining': description[available_length:],
        'warning': 'Move detailed information to commit body'
    })

    return description, suggestions

def generate_subject(data):
    """
    Generate commit subject line from input data.

    Args:
        data: dict with keys: type, scope (optional), description, max_length (optional)

    Returns:
        dict with subject, length, warnings, suggestions
    """

    # Extract parameters
    commit_type = data.get('type', '').strip().lower()
    scope = data.get('scope', '').strip()
    description = data.get('description', '').strip()
    max_length = int(data.get('max_length', 50))

    # Validate required fields
    if not commit_type:
        return {
            'error': 'type is required',
            'subject': None
        }

    if not description:
        return {
            'error': 'description is required',
            'subject': None
        }

    # Validate type
    valid_types = ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert']
    if commit_type not in valid_types:
        return {
            'error': f'Invalid type "{commit_type}". Valid types: {", ".join(valid_types)}',
            'subject': None
        }

    # Enforce imperative mood
    original_description = description
    description, mood_changed = enforce_imperative_mood(description)

    # Ensure lowercase after colon
    if description and description[0].isupper():
        description = description[0].lower() + description[1:]

    # Remove period at end
    if description.endswith('.'):
        description = description[:-1]

    # Build type(scope) part
    if scope:
        type_scope_part = f"{commit_type}({scope})"
    else:
        type_scope_part = commit_type

    # Build initial subject
    subject = f"{type_scope_part}: {description}"
    subject_length = len(subject)

    # Collect warnings and suggestions
    warnings = []
    suggestions = []

    # Check mood change
    if mood_changed:
        warnings.append({
            'type': 'mood',
            'message': 'Changed to imperative mood',
            'original': original_description,
            'corrected': description
        })

    # Check length
    if subject_length > max_length:
        warnings.append({
            'type': 'length',
            'message': f'Subject exceeds {max_length} characters ({subject_length} chars)',
            'length': subject_length,
            'max': max_length,
            'excess': subject_length - max_length
        })

        # Try to shorten
        shortened_desc, shorten_suggestions = shorten_description(description, max_length, type_scope_part)
        if shorten_suggestions:
            suggestions.extend(shorten_suggestions)

            # If we successfully shortened, update subject
            if len(shortened_desc) < len(description):
                alternative_subject = f"{type_scope_part}: {shortened_desc}"
                if len(alternative_subject) <= max_length:
                    suggestions.append({
                        'type': 'shortened_subject',
                        'subject': alternative_subject,
                        'saved': subject_length - len(alternative_subject)
                    })

    # Warning if close to limit
    elif subject_length > 45 and max_length == 50:
        suggestions.append({
            'type': 'near_limit',
            'message': f'Subject is close to {max_length} character limit ({subject_length} chars)'
        })

    # Check for common issues
    if ' and ' in description or ' & ' in description:
        suggestions.append({
            'type': 'multiple_changes',
            'message': 'Subject mentions multiple changes - consider splitting into multiple commits or using bullet points in body'
        })

    # Check for filler words
    filler_pattern = r'\b(just|very|really|quite|some)\b'
    if re.search(filler_pattern, description, re.IGNORECASE):
        cleaned = re.sub(filler_pattern, '', description, flags=re.IGNORECASE)
        cleaned = re.sub(r'\s+', ' ', cleaned).strip()
        suggestions.append({
            'type': 'filler_words',
            'message': 'Remove filler words for clarity',
            'current': description,
            'suggested': cleaned
        })

    # Build response
    response = {
        'subject': subject,
        'length': subject_length,
        'max_length': max_length,
        'type': commit_type,
        'scope': scope if scope else None,
        'description': description,
        'valid': subject_length <= max_length and subject_length <= 72,  # 72 is hard limit
        'warnings': warnings,
        'suggestions': suggestions
    }

    # Add quality score
    score = 100
    if subject_length > max_length:
        score -= 20
    if subject_length > 72:
        score -= 30  # Major penalty for exceeding hard limit
    if mood_changed:
        score -= 5
    if len(warnings) > 0:
        score -= len(warnings) * 3

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
                'subject': None
            }))
            sys.exit(1)

        # Parse JSON
        try:
            data = json.loads(input_data)
        except json.JSONDecodeError as e:
            print(json.dumps({
                'error': f'Invalid JSON: {str(e)}',
                'subject': None
            }))
            sys.exit(1)

        # Generate subject
        result = generate_subject(data)

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
            'subject': None
        }))
        sys.exit(2)

if __name__ == '__main__':
    main()

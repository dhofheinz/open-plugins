#!/usr/bin/env python3
"""
Script: generate-metadata.py
Purpose: Generate plugin.json metadata from parameters
Version: 1.0.0
Last Modified: 2025-10-13

Usage:
    ./generate-metadata.py --name <name> --author <author> --description <desc> --license <license>

Returns:
    0 - Success, JSON written to stdout
    1 - Validation error
    2 - Missing required arguments

Dependencies:
    - python3 (3.7+)
    - json module (standard library)
"""

import json
import sys
import argparse
import re
from datetime import datetime

# OpenPlugins standard categories
VALID_CATEGORIES = [
    "development", "testing", "deployment", "documentation",
    "security", "database", "monitoring", "productivity",
    "quality", "collaboration"
]

VALID_LICENSES = ["MIT", "Apache-2.0", "GPL-3.0", "BSD-3-Clause", "ISC", "LGPL-3.0"]

def parse_author(author_string):
    """Parse author string into name and email components."""
    # Pattern: "Name <email>" or "Name" or "Name (email)"
    email_pattern = r'<([^>]+)>'
    paren_pattern = r'\(([^\)]+)\)'

    name = author_string
    email = None

    # Check for <email> format
    email_match = re.search(email_pattern, author_string)
    if email_match:
        email = email_match.group(1)
        name = author_string[:email_match.start()].strip()
    else:
        # Check for (email) format
        paren_match = re.search(paren_pattern, author_string)
        if paren_match:
            email = paren_match.group(1)
            name = author_string[:paren_match.start()].strip()

    result = {"name": name}
    if email:
        result["email"] = email

    return result

def generate_keywords(name, description, category):
    """Generate relevant keywords from name, description, and category."""
    keywords = []

    # Add category
    keywords.append(category)

    # Extract keywords from name
    name_parts = name.split('-')
    for part in name_parts:
        if len(part) > 3 and part not in ['plugin', 'claude', 'code']:
            keywords.append(part)

    # Extract keywords from description (simple approach)
    desc_words = re.findall(r'\b[a-z]{4,}\b', description.lower())
    common_words = {'with', 'from', 'this', 'that', 'have', 'will', 'your', 'for'}
    for word in desc_words[:3]:  # Take first 3 meaningful words
        if word not in common_words and word not in keywords:
            keywords.append(word)

    # Ensure 3-7 keywords
    return keywords[:7]

def validate_name(name):
    """Validate plugin name format."""
    pattern = r'^[a-z][a-z0-9-]*[a-z0-9]$|^[a-z]$'
    if not re.match(pattern, name):
        return False, "Plugin name must be lowercase with hyphens only"
    if '--' in name:
        return False, "Plugin name cannot contain consecutive hyphens"
    if len(name) < 3 or len(name) > 50:
        return False, "Plugin name must be 3-50 characters"
    return True, None

def validate_description(description):
    """Validate description length and content."""
    length = len(description)
    if length < 50:
        return False, f"Description too short ({length} chars, minimum 50)"
    if length > 200:
        return False, f"Description too long ({length} chars, maximum 200)"
    return True, None

def generate_metadata(args):
    """Generate complete plugin.json metadata."""

    # Validate name
    valid, error = validate_name(args.name)
    if not valid:
        print(f"ERROR: {error}", file=sys.stderr)
        return None

    # Validate description
    valid, error = validate_description(args.description)
    if not valid:
        print(f"ERROR: {error}", file=sys.stderr)
        return None

    # Validate license
    if args.license not in VALID_LICENSES:
        print(f"ERROR: Invalid license. Must be one of: {', '.join(VALID_LICENSES)}", file=sys.stderr)
        return None

    # Validate category
    if args.category not in VALID_CATEGORIES:
        print(f"ERROR: Invalid category. Must be one of: {', '.join(VALID_CATEGORIES)}", file=sys.stderr)
        return None

    # Parse author
    author = parse_author(args.author)

    # Generate or use provided keywords
    if args.keywords:
        keywords = [k.strip() for k in args.keywords.split(',')]
    else:
        keywords = generate_keywords(args.name, args.description, args.category)

    # Build metadata object
    metadata = {
        "name": args.name,
        "version": args.version,
        "description": args.description,
        "author": author,
        "license": args.license
    }

    # Add optional fields if provided
    if args.repository:
        metadata["repository"] = {
            "type": "git",
            "url": args.repository
        }
    elif args.github_username:
        metadata["repository"] = {
            "type": "git",
            "url": f"https://github.com/{args.github_username}/{args.name}"
        }
        metadata["homepage"] = f"https://github.com/{args.github_username}/{args.name}"

    if args.homepage:
        metadata["homepage"] = args.homepage

    if keywords:
        metadata["keywords"] = keywords

    if args.category:
        metadata["category"] = args.category

    return metadata

def main():
    parser = argparse.ArgumentParser(
        description='Generate plugin.json metadata',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # Required arguments
    parser.add_argument('--name', required=True, help='Plugin name (lowercase-hyphen)')
    parser.add_argument('--author', required=True, help='Author name or "Name <email>"')
    parser.add_argument('--description', required=True, help='Plugin description (50-200 chars)')
    parser.add_argument('--license', required=True, help='License type (MIT, Apache-2.0, etc.)')

    # Optional arguments
    parser.add_argument('--version', default='1.0.0', help='Initial version (default: 1.0.0)')
    parser.add_argument('--category', default='development', help='Plugin category')
    parser.add_argument('--keywords', help='Comma-separated keywords')
    parser.add_argument('--repository', help='Repository URL')
    parser.add_argument('--homepage', help='Homepage URL')
    parser.add_argument('--github-username', help='GitHub username (auto-generates repo URL)')
    parser.add_argument('--output', help='Output file path (default: stdout)')
    parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON')

    args = parser.parse_args()

    # Generate metadata
    metadata = generate_metadata(args)
    if metadata is None:
        return 1

    # Format JSON
    if args.pretty:
        json_output = json.dumps(metadata, indent=2, ensure_ascii=False)
    else:
        json_output = json.dumps(metadata, ensure_ascii=False)

    # Output
    if args.output:
        try:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(json_output)
            print(f"✅ Metadata written to {args.output}", file=sys.stderr)
        except IOError as e:
            print(f"ERROR: Could not write to {args.output}: {e}", file=sys.stderr)
            return 1
    else:
        print(json_output)

    return 0

if __name__ == '__main__':
    sys.exit(main())

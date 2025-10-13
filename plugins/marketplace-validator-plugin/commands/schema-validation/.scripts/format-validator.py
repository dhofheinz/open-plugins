#!/usr/bin/env python3

# ============================================================================
# Format Validator Script
# ============================================================================
# Purpose: Validate format compliance for semver, URLs, emails, naming
# Version: 1.0.0
# Usage: ./format-validator.py --file <path> --type <plugin|marketplace> [--strict]
# Returns: 0=all valid, 1=format violations, 2=error
# ============================================================================

import json
import sys
import argparse
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional


# ====================
# Color Support
# ====================

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'

    @classmethod
    def disable(cls):
        """Disable colors for non-TTY output"""
        cls.RED = cls.GREEN = cls.YELLOW = cls.BLUE = cls.CYAN = cls.BOLD = cls.NC = ''


if not sys.stdout.isatty():
    Colors.disable()


# ====================
# Format Patterns
# ====================

# Semantic versioning: X.Y.Z
SEMVER_PATTERN = re.compile(r'^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$')

# Lowercase-hyphen naming: plugin-name
LOWERCASE_HYPHEN_PATTERN = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')

# Email: RFC 5322 simplified
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

# URL: http or https
URL_PATTERN = re.compile(r'^https?://')

# HTTPS only
HTTPS_PATTERN = re.compile(r'^https://')

# SPDX License Identifiers (common ones)
SPDX_LICENSES = [
    'MIT', 'Apache-2.0', 'GPL-3.0', 'GPL-2.0', 'LGPL-3.0', 'LGPL-2.1',
    'BSD-2-Clause', 'BSD-3-Clause', 'ISC', 'MPL-2.0', 'AGPL-3.0',
    'Unlicense', 'CC0-1.0', 'Proprietary'
]

# Approved categories (10 standard)
APPROVED_CATEGORIES = [
    'development', 'testing', 'deployment', 'documentation', 'security',
    'database', 'monitoring', 'productivity', 'quality', 'collaboration'
]


# ====================
# Validation Functions
# ====================

class FormatValidator:
    """Format validation logic"""

    def __init__(self, strict_https: bool = False):
        self.strict_https = strict_https
        self.errors: List[Tuple[str, str, str]] = []
        self.warnings: List[Tuple[str, str]] = []
        self.passed: List[Tuple[str, str]] = []

    def validate_semver(self, field: str, value: str) -> bool:
        """Validate semantic versioning"""
        if not value:
            return True  # Skip empty (handled by required fields check)

        if SEMVER_PATTERN.match(value):
            self.passed.append((field, f'"{value}" (semver)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must use semantic versioning (X.Y.Z)\n'
                '     Pattern: MAJOR.MINOR.PATCH\n'
                '     Example: 1.0.0, 2.1.5'
            )
            self.errors.append(error)
            return False

    def validate_lowercase_hyphen(self, field: str, value: str) -> bool:
        """Validate lowercase-hyphen naming"""
        if not value:
            return True

        if LOWERCASE_HYPHEN_PATTERN.match(value):
            self.passed.append((field, f'"{value}" (lowercase-hyphen)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must use lowercase-hyphen format\n'
                '     Pattern: ^[a-z0-9]+(-[a-z0-9]+)*$\n'
                '     Example: my-plugin, test-tool, plugin123'
            )
            self.errors.append(error)
            return False

    def validate_email(self, field: str, value: str) -> bool:
        """Validate email address"""
        if not value:
            return True

        if EMAIL_PATTERN.match(value):
            self.passed.append((field, f'"{value}" (valid email)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must be valid email address\n'
                '     Pattern: user@domain.tld\n'
                '     Example: developer@example.com'
            )
            self.errors.append(error)
            return False

    def validate_url(self, field: str, value: str) -> bool:
        """Validate URL format"""
        if not value:
            return True

        if self.strict_https and not HTTPS_PATTERN.match(value):
            error = (
                field,
                f'"{value}"',
                'Invalid: HTTPS required in strict mode\n'
                f'     Current: {value}\n'
                f'     Required: {value.replace("http://", "https://", 1)}'
            )
            self.errors.append(error)
            return False
        elif URL_PATTERN.match(value):
            if value.startswith('http://'):
                self.warnings.append((
                    field,
                    f'"{value}" - Consider using HTTPS for security'
                ))
            self.passed.append((field, f'"{value}" (valid URL)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must be valid URL\n'
                '     Pattern: https://domain.tld/path\n'
                '     Example: https://github.com/user/repo'
            )
            self.errors.append(error)
            return False

    def validate_license(self, field: str, value: str) -> bool:
        """Validate SPDX license identifier"""
        if not value:
            return True

        if value in SPDX_LICENSES:
            self.passed.append((field, f'"{value}" (SPDX identifier)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must be SPDX license identifier\n'
                '     Common: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause, ISC\n'
                '     See: https://spdx.org/licenses/'
            )
            self.errors.append(error)
            return False

    def validate_category(self, field: str, value: str) -> bool:
        """Validate category against approved list"""
        if not value:
            return True

        if value in APPROVED_CATEGORIES:
            self.passed.append((field, f'"{value}" (approved category)'))
            return True
        else:
            error = (
                field,
                f'"{value}"',
                'Invalid: Must be one of 10 approved categories\n'
                '     Valid: development, testing, deployment, documentation,\n'
                '            security, database, monitoring, productivity,\n'
                '            quality, collaboration'
            )
            self.errors.append(error)
            return False

    def validate_description_length(self, field: str, value: str) -> bool:
        """Validate description length (50-200 chars recommended)"""
        if not value:
            return True

        length = len(value)
        if 50 <= length <= 200:
            self.passed.append((field, f'Valid length ({length} chars)'))
            return True
        elif length < 50:
            self.warnings.append((
                field,
                f'Short description ({length} chars) - consider 50-200 characters for clarity'
            ))
            return True
        else:
            self.warnings.append((
                field,
                f'Long description ({length} chars) - consider keeping under 200 characters'
            ))
            return True


# ====================
# Plugin Validation
# ====================

def validate_plugin_formats(data: Dict, validator: FormatValidator) -> int:
    """Validate plugin format compliance"""
    print(f"{Colors.CYAN}Format Checks:{Colors.NC}\n")

    # name: lowercase-hyphen
    if 'name' in data:
        validator.validate_lowercase_hyphen('name', data['name'])

    # version: semver
    if 'version' in data:
        validator.validate_semver('version', data['version'])

    # description: length check
    if 'description' in data:
        validator.validate_description_length('description', data['description'])

    # license: SPDX
    if 'license' in data:
        validator.validate_license('license', data['license'])

    # homepage: URL
    if 'homepage' in data:
        validator.validate_url('homepage', data['homepage'])

    # repository: URL or object
    if 'repository' in data:
        repo = data['repository']
        if isinstance(repo, str):
            validator.validate_url('repository', repo)
        elif isinstance(repo, dict) and 'url' in repo:
            validator.validate_url('repository.url', repo['url'])

    # category: approved list
    if 'category' in data:
        validator.validate_category('category', data['category'])

    # author: email if object
    if 'author' in data:
        author = data['author']
        if isinstance(author, dict) and 'email' in author:
            validator.validate_email('author.email', author['email'])

    return 0 if not validator.errors else 1


# ====================
# Marketplace Validation
# ====================

def validate_marketplace_formats(data: Dict, validator: FormatValidator) -> int:
    """Validate marketplace format compliance"""
    print(f"{Colors.CYAN}Format Checks:{Colors.NC}\n")

    # name: lowercase-hyphen
    if 'name' in data:
        validator.validate_lowercase_hyphen('name', data['name'])

    # owner.email: email
    if 'owner' in data and isinstance(data['owner'], dict):
        if 'email' in data['owner']:
            validator.validate_email('owner.email', data['owner']['email'])

    # version: semver (if present)
    if 'version' in data:
        validator.validate_semver('version', data['version'])

    # metadata fields
    if 'metadata' in data and isinstance(data['metadata'], dict):
        metadata = data['metadata']

        if 'description' in metadata:
            validator.validate_description_length('metadata.description', metadata['description'])

        if 'homepage' in metadata:
            validator.validate_url('metadata.homepage', metadata['homepage'])

        if 'repository' in metadata:
            validator.validate_url('metadata.repository', metadata['repository'])

    return 0 if not validator.errors else 1


# ====================
# Output Formatting
# ====================

def print_results(validator: FormatValidator):
    """Print validation results"""
    print()

    # Passed checks
    if validator.passed:
        for field, msg in validator.passed:
            print(f"  {Colors.GREEN}✅ {field}: {msg}{Colors.NC}")

    # Errors
    if validator.errors:
        print()
        for field, value, msg in validator.errors:
            print(f"  {Colors.RED}❌ {field}: {value}{Colors.NC}")
            for line in msg.split('\n'):
                print(f"     {line}")
            print()

    # Warnings
    if validator.warnings:
        print()
        for field, msg in validator.warnings:
            print(f"  {Colors.YELLOW}⚠️  {field}: {msg}{Colors.NC}")

    # Summary
    print()
    print(f"{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")

    total = len(validator.passed) + len(validator.errors)
    passed_count = len(validator.passed)

    if validator.errors:
        print(f"{Colors.RED}Failed: {len(validator.errors)}{Colors.NC}")
        if validator.warnings:
            print(f"{Colors.YELLOW}Warnings: {len(validator.warnings)}{Colors.NC}")
        print(f"Status: {Colors.RED}FAIL{Colors.NC}")
    else:
        print(f"Passed: {passed_count}/{total}")
        if validator.warnings:
            print(f"{Colors.YELLOW}Warnings: {len(validator.warnings)}{Colors.NC}")
        print(f"Status: {Colors.GREEN}PASS{Colors.NC}")


# ====================
# Main Logic
# ====================

def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description='Validate format compliance for plugin and marketplace configurations',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        '--file',
        type=str,
        required=True,
        help='Path to configuration file (plugin.json or marketplace.json)'
    )

    parser.add_argument(
        '--type',
        type=str,
        choices=['plugin', 'marketplace'],
        required=True,
        help='Configuration type'
    )

    parser.add_argument(
        '--strict',
        action='store_true',
        help='Enforce HTTPS for all URLs'
    )

    args = parser.parse_args()

    # Load configuration file
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"{Colors.RED}❌ File not found: {args.file}{Colors.NC}", file=sys.stderr)
        return 2
    except json.JSONDecodeError as e:
        print(f"{Colors.RED}❌ Invalid JSON: {e}{Colors.NC}", file=sys.stderr)
        print(f"{Colors.BLUE}ℹ️  Run JSON validation first{Colors.NC}", file=sys.stderr)
        return 2

    # Print header
    print(f"{Colors.BOLD}{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    print(f"{Colors.BOLD}Format Validation{Colors.NC}")
    print(f"{Colors.BOLD}{Colors.BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
    print(f"Target: {args.file}")
    print(f"Type: {args.type}")
    if args.strict:
        print(f"Strict HTTPS: {Colors.GREEN}Enforced{Colors.NC}")
    print()

    # Create validator
    validator = FormatValidator(strict_https=args.strict)

    # Validate based on type
    if args.type == 'plugin':
        result = validate_plugin_formats(data, validator)
    else:
        result = validate_marketplace_formats(data, validator)

    # Print results
    print_results(validator)

    return result


if __name__ == '__main__':
    sys.exit(main())

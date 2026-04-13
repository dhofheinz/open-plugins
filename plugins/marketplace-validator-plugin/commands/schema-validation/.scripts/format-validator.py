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

# userConfig field types (from plugin.json schema)
USERCONFIG_TYPES = ['string', 'number', 'boolean', 'directory', 'file']

# Valid plugin source object types (marketplace plugin entry .source)
SOURCE_OBJECT_TYPES = ['github', 'url', 'git-subdir', 'npm']

# Required fields per source object type
SOURCE_OBJECT_REQUIRED_FIELDS = {
    'github': ['repo'],
    'url': ['url'],
    'git-subdir': ['url', 'path'],
    'npm': ['package'],
}

# Reserved marketplace names (cannot be used by third-party marketplaces)
RESERVED_MARKETPLACE_NAMES = [
    'claude-code-marketplace', 'claude-code-plugins', 'claude-plugins-official',
    'anthropic-marketplace', 'anthropic-plugins', 'agent-skills',
    'knowledge-work-plugins', 'life-sciences'
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

    def validate_repository(self, field: str, value) -> bool:
        """Validate repository field — must be a string URL per current schema.

        The legacy {type, url} object form is rejected by the live Claude Code
        validator and is now rejected here as well.
        """
        if value is None or value == '':
            return True

        if isinstance(value, str):
            return self.validate_url(field, value)

        if isinstance(value, dict):
            error = (
                field,
                f'{type(value).__name__} {value!r}',
                'Invalid: repository must be a string URL (legacy object form\n'
                '     {"type": "git", "url": "..."} is rejected by the current\n'
                '     Claude Code validator)\n'
                '     Fix: "repository": "https://github.com/user/repo"'
            )
            self.errors.append(error)
            return False

        error = (
            field,
            f'{type(value).__name__}',
            'Invalid: repository must be a string URL'
        )
        self.errors.append(error)
        return False

    def validate_userconfig(self, field: str, value) -> bool:
        """Validate userConfig entries.

        Each entry must have:
        - type: one of string|number|boolean|directory|file
        - title: non-empty string
        Optional: description, default, sensitive, required, enum.
        """
        if value is None:
            return True
        if not isinstance(value, dict):
            self.errors.append((
                field,
                f'{type(value).__name__}',
                'Invalid: userConfig must be an object mapping keys to field definitions'
            ))
            return False

        ok = True
        allowed_keys = {'type', 'title', 'description', 'default', 'sensitive', 'required', 'enum'}
        for key, entry in value.items():
            subfield = f'{field}.{key}'
            if not isinstance(entry, dict):
                self.errors.append((
                    subfield,
                    f'{type(entry).__name__}',
                    'Invalid: each userConfig entry must be an object with at\n'
                    '     minimum {type, title}'
                ))
                ok = False
                continue

            # Required: type
            entry_type = entry.get('type')
            if entry_type is None:
                self.errors.append((
                    subfield + '.type',
                    '(missing)',
                    'Invalid: missing required field "type"\n'
                    f'     Valid: {", ".join(USERCONFIG_TYPES)}'
                ))
                ok = False
            elif entry_type not in USERCONFIG_TYPES:
                self.errors.append((
                    subfield + '.type',
                    f'"{entry_type}"',
                    f'Invalid: type must be one of {", ".join(USERCONFIG_TYPES)}'
                ))
                ok = False

            # Required: title
            entry_title = entry.get('title')
            if not isinstance(entry_title, str) or not entry_title.strip():
                self.errors.append((
                    subfield + '.title',
                    f'{entry_title!r}' if entry_title is not None else '(missing)',
                    'Invalid: missing or empty required field "title" (non-empty string)'
                ))
                ok = False

            # Optional: sensitive must be bool
            if 'sensitive' in entry and not isinstance(entry['sensitive'], bool):
                self.warnings.append((
                    subfield + '.sensitive',
                    f'{entry["sensitive"]!r} - should be boolean'
                ))

            # Optional: enum must be list
            if 'enum' in entry and not isinstance(entry['enum'], list):
                self.warnings.append((
                    subfield + '.enum',
                    f'{type(entry["enum"]).__name__} - should be an array of allowed values'
                ))

            # Unknown keys
            unknown = set(entry.keys()) - allowed_keys
            if unknown:
                self.warnings.append((
                    subfield,
                    f'Unknown field(s): {", ".join(sorted(unknown))} '
                    f'(recognized: {", ".join(sorted(allowed_keys))})'
                ))

            if ok:
                self.passed.append((subfield, f'type={entry_type}, title set'))

        return ok

    def validate_source(self, field: str, value) -> bool:
        """Validate marketplace plugin entry source.

        Accepts:
        - Relative path string starting with "./"
        - Object: {source: "github", repo, ref?, sha?}
        - Object: {source: "url", url, ref?, sha?}
        - Object: {source: "git-subdir", url, path, ref?, sha?}
        - Object: {source: "npm", package, version?, registry?}
        """
        if value is None:
            return True

        if isinstance(value, str):
            if value.startswith('./'):
                self.passed.append((field, f'"{value}" (relative path)'))
                return True
            # Legacy shorthand strings no longer documented — warn loudly.
            if value.startswith('github:'):
                self.warnings.append((
                    field,
                    f'"{value}" - legacy github: shorthand; migrate to '
                    '{"source": "github", "repo": "owner/repo"}'
                ))
                return True
            if re.match(r'^https?://', value):
                self.warnings.append((
                    field,
                    f'"{value}" - legacy URL string; migrate to '
                    '{"source": "url", "url": "..."} or {"source": "github", "repo": "..."}'
                ))
                return True
            self.errors.append((
                field,
                f'"{value}"',
                'Invalid source string: relative paths must start with "./".\n'
                '     Use object form for git/npm sources: {"source": "github", "repo": "owner/repo"}'
            ))
            return False

        if isinstance(value, dict):
            src_type = value.get('source')
            if src_type not in SOURCE_OBJECT_TYPES:
                self.errors.append((
                    field + '.source',
                    f'"{src_type}"' if src_type else '(missing)',
                    f'Invalid: source.source must be one of {", ".join(SOURCE_OBJECT_TYPES)}'
                ))
                return False
            required = SOURCE_OBJECT_REQUIRED_FIELDS[src_type]
            missing = [f for f in required if not value.get(f)]
            if missing:
                self.errors.append((
                    field,
                    f'source={src_type}',
                    f'Invalid: {src_type} source missing required field(s): {", ".join(missing)}'
                ))
                return False
            self.passed.append((field, f'{src_type} source'))
            return True

        self.errors.append((
            field,
            f'{type(value).__name__}',
            'Invalid: source must be a relative path string ("./...") or an object'
        ))
        return False


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

    # repository: string URL (legacy {type, url} object is rejected)
    if 'repository' in data:
        validator.validate_repository('repository', data['repository'])

    # category: approved list
    if 'category' in data:
        validator.validate_category('category', data['category'])

    # author: email if object
    if 'author' in data:
        author = data['author']
        if isinstance(author, dict) and 'email' in author:
            validator.validate_email('author.email', author['email'])

    # userConfig: validate each entry's schema
    if 'userConfig' in data:
        validator.validate_userconfig('userConfig', data['userConfig'])

    return 0 if not validator.errors else 1


# ====================
# Marketplace Validation
# ====================

def validate_marketplace_formats(data: Dict, validator: FormatValidator) -> int:
    """Validate marketplace format compliance"""
    print(f"{Colors.CYAN}Format Checks:{Colors.NC}\n")

    # name: lowercase-hyphen + reserved-name check
    if 'name' in data:
        validator.validate_lowercase_hyphen('name', data['name'])
        if data['name'] in RESERVED_MARKETPLACE_NAMES:
            validator.errors.append((
                'name',
                f'"{data["name"]}"',
                'Invalid: this name is reserved for official Anthropic use.\n'
                f'     Reserved: {", ".join(RESERVED_MARKETPLACE_NAMES)}'
            ))

    # owner.email: email (optional — only validate format if present)
    if 'owner' in data and isinstance(data['owner'], dict):
        if data['owner'].get('email'):
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

    # plugin entries: validate each source + common format fields
    if 'plugins' in data and isinstance(data['plugins'], list):
        for idx, entry in enumerate(data['plugins']):
            if not isinstance(entry, dict):
                validator.errors.append((
                    f'plugins[{idx}]',
                    f'{type(entry).__name__}',
                    'Invalid: plugin entry must be an object'
                ))
                continue
            prefix = f'plugins[{idx}]'
            entry_name = entry.get('name')
            if entry_name:
                prefix = f'plugins[{idx}:{entry_name}]'
                validator.validate_lowercase_hyphen(f'{prefix}.name', entry_name)
            if 'source' in entry:
                validator.validate_source(f'{prefix}.source', entry['source'])
            if 'version' in entry:
                validator.validate_semver(f'{prefix}.version', entry['version'])
            if 'description' in entry:
                validator.validate_description_length(f'{prefix}.description', entry['description'])
            if 'license' in entry:
                validator.validate_license(f'{prefix}.license', entry['license'])
            if 'category' in entry:
                validator.validate_category(f'{prefix}.category', entry['category'])
            if 'homepage' in entry:
                validator.validate_url(f'{prefix}.homepage', entry['homepage'])
            if 'repository' in entry:
                validator.validate_repository(f'{prefix}.repository', entry['repository'])
            if isinstance(entry.get('author'), dict) and entry['author'].get('email'):
                validator.validate_email(f'{prefix}.author.email', entry['author']['email'])

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

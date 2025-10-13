#!/usr/bin/env python3

"""
============================================================================
Semantic Version Validator
============================================================================
Purpose: Validate version strings against Semantic Versioning 2.0.0
Version: 1.0.0
Usage: ./semver-checker.py <version> [--strict]
Returns: 0=valid, 1=invalid, 2=missing params, 3=strict mode violation
============================================================================
"""

import re
import sys
from typing import Tuple, Optional, Dict, List

# Semantic versioning patterns
STRICT_SEMVER_PATTERN = r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$'
FULL_SEMVER_PATTERN = r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'


def usage():
    """Print usage information"""
    print("""Usage: semver-checker.py <version> [--strict]

Validate version string against Semantic Versioning 2.0.0 specification.

Arguments:
  version     Version string to validate (required)
  --strict    Enforce strict MAJOR.MINOR.PATCH format (no pre-release/build)

Pattern (strict): MAJOR.MINOR.PATCH (e.g., 1.2.3)
Pattern (full):   MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Valid examples:
  - 1.0.0 (strict)
  - 1.2.3 (strict)
  - 1.0.0-alpha.1 (full)
  - 1.2.3+build.20241013 (full)

Invalid examples:
  - 1.0 (missing PATCH)
  - v1.0.0 (has prefix)
  - 1.2.x (placeholder)

Exit codes:
  0 - Valid semantic version
  1 - Invalid format
  2 - Missing required parameters
  3 - Strict mode violation (valid semver, but has pre-release/build)

Reference: https://semver.org/
""")
    sys.exit(2)


def parse_semver(version: str) -> Optional[Dict[str, any]]:
    """
    Parse semantic version string into components

    Returns:
        Dict with major, minor, patch, prerelease, build
        None if invalid format
    """
    match = re.match(FULL_SEMVER_PATTERN, version)
    if not match:
        return None

    major, minor, patch, prerelease, build = match.groups()

    return {
        'major': int(major),
        'minor': int(minor),
        'patch': int(patch),
        'prerelease': prerelease or None,
        'build': build or None,
        'is_strict': prerelease is None and build is None
    }


def find_issues(version: str) -> List[str]:
    """Find specific issues with version format"""
    issues = []

    # Check for common mistakes
    if version.startswith('v') or version.startswith('V'):
        issues.append("Starts with 'v' prefix (remove it)")

    # Check for missing components
    parts = version.split('.')
    if len(parts) < 3:
        issues.append(f"Missing components (has {len(parts)}, needs 3: MAJOR.MINOR.PATCH)")
    elif len(parts) > 3:
        # Check if extra parts are pre-release or build
        if '-' not in version and '+' not in version:
            issues.append(f"Too many components (has {len(parts)}, expected 3)")

    # Check for placeholders
    if 'x' in version.lower() or '*' in version:
        issues.append("Contains placeholder values (x or *)")

    # Check for non-numeric base version
    base_version = version.split('-')[0].split('+')[0]
    base_parts = base_version.split('.')
    for i, part in enumerate(base_parts):
        if not part.isdigit():
            component = ['MAJOR', 'MINOR', 'PATCH'][i] if i < 3 else 'component'
            issues.append(f"{component} is not numeric: '{part}'")

    # Check for leading zeros
    for i, part in enumerate(base_parts[:3]):
        if len(part) > 1 and part.startswith('0'):
            component = ['MAJOR', 'MINOR', 'PATCH'][i]
            issues.append(f"{component} has leading zero: '{part}'")

    # Check for non-standard identifiers
    if version in ['latest', 'stable', 'dev', 'master', 'main']:
        issues.append("Using non-numeric identifier (not a version)")

    return issues


def validate_version(version: str, strict: bool = False) -> Tuple[bool, int, str]:
    """
    Validate semantic version

    Returns:
        (is_valid, exit_code, message)
    """
    if not version or version.strip() == '':
        return False, 2, "ERROR: Version cannot be empty"

    # Parse the version
    parsed = parse_semver(version)

    if parsed is None:
        # Invalid format
        issues = find_issues(version)
        message = "❌ FAIL: Invalid semantic version format\n\n"
        message += f"Version: {version}\n"
        message += "Valid: No\n\n"
        message += "Issues Found:\n"
        if issues:
            for issue in issues:
                message += f"  - {issue}\n"
        else:
            message += "  - Does not match semantic versioning pattern\n"
        message += "\nRequired Format: MAJOR.MINOR.PATCH\n"
        message += "\nExamples:\n"
        message += "  - 1.0.0 (initial release)\n"
        message += "  - 1.2.3 (standard version)\n"
        message += "  - 2.0.0-beta.1 (pre-release)\n"
        message += "\nReference: https://semver.org/"
        return False, 1, message

    # Check strict mode
    if strict and not parsed['is_strict']:
        message = "⚠️  WARNING: Valid semver, but not strict format\n\n"
        message += f"Version: {version}\n"
        message += "Format: Valid semver with "
        if parsed['prerelease']:
            message += "pre-release"
        if parsed['build']:
            message += " and " if parsed['prerelease'] else ""
            message += "build metadata"
        message += "\n\n"
        message += "Note: OpenPlugins recommends strict MAJOR.MINOR.PATCH format\n"
        message += "without pre-release or build metadata for marketplace submissions.\n\n"
        message += f"Recommended: {parsed['major']}.{parsed['minor']}.{parsed['patch']} (for stable release)\n\n"
        message += "Quality Score Impact: +5 points (valid, but consider strict format)"
        return True, 3, message

    # Valid version
    message = "✅ PASS: Valid semantic version\n\n"
    message += f"Version: {version}\n"
    message += "Format: "
    if parsed['is_strict']:
        message += "MAJOR.MINOR.PATCH (strict)\n"
    else:
        message += "MAJOR.MINOR.PATCH"
        if parsed['prerelease']:
            message += "-PRERELEASE"
        if parsed['build']:
            message += "+BUILD"
        message += "\n"
    message += "Valid: Yes\n\n"
    message += "Components:\n"
    message += f"  - MAJOR: {parsed['major']}"
    if parsed['major'] > 0:
        message += " (breaking changes)"
    message += "\n"
    message += f"  - MINOR: {parsed['minor']}"
    if parsed['minor'] > 0:
        message += " (new features)"
    message += "\n"
    message += f"  - PATCH: {parsed['patch']}"
    if parsed['patch'] > 0:
        message += " (bug fixes)"
    message += "\n"

    if parsed['prerelease']:
        message += f"  - Pre-release: {parsed['prerelease']}\n"
    if parsed['build']:
        message += f"  - Build: {parsed['build']}\n"

    message += "\n"

    if parsed['prerelease']:
        message += "Note: Pre-release versions indicate unstable releases.\n"
        message += "Remove pre-release identifier for stable marketplace submission.\n\n"

    message += "Quality Score Impact: +5 points\n\n"
    message += "The version follows Semantic Versioning 2.0.0 specification."

    return True, 0, message


def main():
    """Main entry point"""
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        usage()

    version = sys.argv[1]
    strict = '--strict' in sys.argv

    is_valid, exit_code, message = validate_version(version, strict)

    print(message)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()

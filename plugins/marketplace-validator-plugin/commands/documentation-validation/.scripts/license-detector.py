#!/usr/bin/env python3

# ============================================================================
# License Detector
# ============================================================================
# Purpose: Detect and validate LICENSE file content
# Version: 1.0.0
# Usage: ./license-detector.py <path> [--expected LICENSE] [--json]
# Returns: 0=success, 1=error, JSON output to stdout
# ============================================================================

import sys
import os
import re
import json
import argparse
from pathlib import Path
from typing import Dict, Optional, Tuple

# OSI-approved license patterns
LICENSE_PATTERNS = {
    "MIT": {
        "pattern": r"Permission is hereby granted, free of charge",
        "confidence": 95,
        "osi_approved": True,
        "full_name": "MIT License"
    },
    "Apache-2.0": {
        "pattern": r"Licensed under the Apache License, Version 2\.0",
        "confidence": 95,
        "osi_approved": True,
        "full_name": "Apache License 2.0"
    },
    "GPL-3.0": {
        "pattern": r"GNU GENERAL PUBLIC LICENSE.*Version 3",
        "confidence": 95,
        "osi_approved": True,
        "full_name": "GNU General Public License v3.0"
    },
    "GPL-2.0": {
        "pattern": r"GNU GENERAL PUBLIC LICENSE.*Version 2",
        "confidence": 95,
        "osi_approved": True,
        "full_name": "GNU General Public License v2.0"
    },
    "BSD-3-Clause": {
        "pattern": r"Redistribution and use in source and binary forms.*3\.",
        "confidence": 85,
        "osi_approved": True,
        "full_name": "BSD 3-Clause License"
    },
    "BSD-2-Clause": {
        "pattern": r"Redistribution and use in source and binary forms",
        "confidence": 80,
        "osi_approved": True,
        "full_name": "BSD 2-Clause License"
    },
    "ISC": {
        "pattern": r"Permission to use, copy, modify, and/or distribute",
        "confidence": 90,
        "osi_approved": True,
        "full_name": "ISC License"
    },
    "MPL-2.0": {
        "pattern": r"Mozilla Public License Version 2\.0",
        "confidence": 95,
        "osi_approved": True,
        "full_name": "Mozilla Public License 2.0"
    }
}

# License name variations/aliases
LICENSE_ALIASES = {
    "MIT License": "MIT",
    "MIT license": "MIT",
    "Apache License 2.0": "Apache-2.0",
    "Apache 2.0": "Apache-2.0",
    "Apache-2": "Apache-2.0",
    "GNU GPL v3": "GPL-3.0",
    "GPLv3": "GPL-3.0",
    "GNU GPL v2": "GPL-2.0",
    "GPLv2": "GPL-2.0",
    "BSD 3-Clause": "BSD-3-Clause",
    "BSD 2-Clause": "BSD-2-Clause",
}

def find_license_file(path: str) -> Optional[str]:
    """Find LICENSE file in path."""
    path_obj = Path(path)

    # Check if path is directly to LICENSE
    if path_obj.is_file() and 'license' in path_obj.name.lower():
        return str(path_obj)

    # Search for LICENSE in directory
    if path_obj.is_dir():
        for filename in ['LICENSE', 'LICENSE.txt', 'LICENSE.md', 'COPYING', 'COPYING.txt', 'LICENCE']:
            license_path = path_obj / filename
            if license_path.exists():
                return str(license_path)

    return None

def read_plugin_manifest(path: str) -> Optional[str]:
    """Read license from plugin.json."""
    path_obj = Path(path)

    if path_obj.is_file():
        path_obj = path_obj.parent

    manifest_path = path_obj / '.claude-plugin' / 'plugin.json'

    if not manifest_path.exists():
        return None

    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
            return manifest.get('license')
    except Exception:
        return None

def detect_license(content: str) -> Tuple[Optional[str], int, bool]:
    """
    Detect license type from content.
    Returns: (license_type, confidence, is_complete)
    """
    content_normalized = ' '.join(content.split())  # Normalize whitespace

    best_match = None
    best_confidence = 0

    # Check for license text patterns
    for license_id, license_info in LICENSE_PATTERNS.items():
        pattern = license_info["pattern"]
        if re.search(pattern, content, re.IGNORECASE | re.DOTALL):
            confidence = license_info["confidence"]
            if confidence > best_confidence:
                best_match = license_id
                best_confidence = confidence

    # Check if it's just a name without full text
    is_complete = True
    if best_match and len(content.strip()) < 200:  # Very short content
        is_complete = False

    # If no pattern match, check for just license names
    if not best_match:
        for alias, license_id in LICENSE_ALIASES.items():
            if re.search(r'\b' + re.escape(alias) + r'\b', content, re.IGNORECASE):
                best_match = license_id
                best_confidence = 50  # Lower confidence for name-only
                is_complete = False
                break

    return best_match, best_confidence, is_complete

def normalize_license_name(license_name: str) -> str:
    """Normalize license name for comparison."""
    if not license_name:
        return ""

    # Check if it's already a standard ID
    if license_name in LICENSE_PATTERNS:
        return license_name

    # Check aliases
    if license_name in LICENSE_ALIASES:
        return LICENSE_ALIASES[license_name]

    # Normalize common variations
    normalized = license_name.strip()
    normalized = re.sub(r'\s+', ' ', normalized)

    # Try fuzzy matching
    for alias, license_id in LICENSE_ALIASES.items():
        if normalized.lower() == alias.lower():
            return license_id

    return license_name

def licenses_match(detected: str, expected: str) -> Tuple[bool, str]:
    """
    Check if detected license matches expected.
    Returns: (matches, match_type)
    """
    detected_norm = normalize_license_name(detected)
    expected_norm = normalize_license_name(expected)

    if detected_norm == expected_norm:
        return True, "exact"

    # Check if they're aliases of the same license
    if detected_norm in LICENSE_PATTERNS and expected_norm in LICENSE_PATTERNS:
        if LICENSE_PATTERNS[detected_norm]["full_name"] == LICENSE_PATTERNS[expected_norm]["full_name"]:
            return True, "alias"

    # Fuzzy match
    if detected_norm.lower().replace('-', '').replace(' ', '') == expected_norm.lower().replace('-', '').replace(' ', ''):
        return True, "fuzzy"

    return False, "mismatch"

def main():
    parser = argparse.ArgumentParser(description='Detect and validate LICENSE file')
    parser.add_argument('path', help='Path to LICENSE file or directory containing it')
    parser.add_argument('--expected', help='Expected license type (from plugin.json)', default=None)
    parser.add_argument('--strict', action='store_true', help='Strict validation (requires full text)')
    parser.add_argument('--json', action='store_true', help='Output JSON format')

    args = parser.parse_args()

    # Find LICENSE file
    license_path = find_license_file(args.path)

    if not license_path:
        result = {
            "error": "LICENSE file not found",
            "path": args.path,
            "present": False,
            "score": 0,
            "status": "fail",
            "issues": ["LICENSE file not found in specified path"]
        }
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print("❌ CRITICAL: LICENSE file not found")
            print(f"Path: {args.path}")
            print("LICENSE file is required for plugin submission.")
        return 1

    # Read LICENSE content
    try:
        with open(license_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        result = {
            "error": f"Failed to read LICENSE: {str(e)}",
            "path": license_path,
            "present": True,
            "score": 0,
            "status": "fail"
        }
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"❌ ERROR: Failed to read LICENSE: {e}")
        return 1

    # Detect license
    detected_license, confidence, is_complete = detect_license(content)

    # Read expected license from plugin.json if not provided
    if not args.expected:
        args.expected = read_plugin_manifest(args.path)

    # Check consistency
    matches_manifest = True
    match_type = None
    if args.expected:
        matches_manifest, match_type = licenses_match(detected_license or "", args.expected)

    # Determine if OSI approved
    is_osi_approved = False
    if detected_license and detected_license in LICENSE_PATTERNS:
        is_osi_approved = LICENSE_PATTERNS[detected_license]["osi_approved"]

    # Build issues list
    issues = []
    score = 100

    if not detected_license:
        issues.append("Unable to identify license type")
        score -= 50
    elif not is_complete:
        issues.append("LICENSE contains only license name, not full text")
        score -= 20 if args.strict else 10

    if not is_osi_approved and detected_license:
        issues.append("License is not OSI-approved")
        score -= 30

    if args.expected and not matches_manifest:
        issues.append(f"LICENSE ({detected_license or 'unknown'}) does not match plugin.json ({args.expected})")
        score -= 20

    score = max(0, score)

    # Determine status
    if score >= 80:
        status = "pass"
    elif score >= 60:
        status = "warning"
    else:
        status = "fail"

    # Build result
    result = {
        "present": True,
        "path": license_path,
        "detected_license": detected_license,
        "confidence": confidence,
        "is_complete": is_complete,
        "is_osi_approved": is_osi_approved,
        "manifest_license": args.expected,
        "matches_manifest": matches_manifest,
        "match_type": match_type,
        "score": score,
        "status": status,
        "issues": issues
    }

    # Output
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        # Human-readable output
        print(f"\nLICENSE Validation Results")
        print("=" * 50)
        print(f"File: {license_path}")
        print(f"Detected: {detected_license or 'Unknown'} (confidence: {confidence}%)")
        print(f"Score: {score}/100")
        print(f"\nOSI Approved: {'✓ Yes' if is_osi_approved else '✗ No'}")
        print(f"Complete Text: {'✓ Yes' if is_complete else '⚠ No (name only)'}")

        if args.expected:
            print(f"\nConsistency Check:")
            print(f"  plugin.json: {args.expected}")
            print(f"  LICENSE file: {detected_license or 'Unknown'}")
            print(f"  Match: {'✓ Yes' if matches_manifest else '✗ No'}")

        if issues:
            print(f"\nIssues Found: {len(issues)}")
            for issue in issues:
                print(f"  • {issue}")

        print(f"\nOverall: {'✓ PASS' if status == 'pass' else '⚠ WARNING' if status == 'warning' else '✗ FAIL'}")
        print()

    return 0 if status != "fail" else 1

if __name__ == "__main__":
    sys.exit(main())

#!/bin/bash
# Script: validate-semver.sh
# Purpose: Validate semantic versioning format
# Version: 1.0.0
#
# Usage: ./validate-semver.sh <version>
# Returns: 0 - Valid semver, 1 - Invalid format

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "ERROR: Version required"
    exit 2
fi

# Semantic versioning pattern: MAJOR.MINOR.PATCH with optional pre-release and build metadata
SEMVER_PATTERN='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

if echo "$VERSION" | grep -Eq "$SEMVER_PATTERN"; then
    echo "✅ Valid semantic version: $VERSION"
    exit 0
else
    echo "❌ Invalid semantic version: $VERSION"
    echo ""
    echo "Semantic versioning format: MAJOR.MINOR.PATCH"
    echo "  - MAJOR: Breaking changes"
    echo "  - MINOR: New features (backwards compatible)"
    echo "  - PATCH: Bug fixes"
    echo ""
    echo "Valid examples:"
    echo "  - 1.0.0"
    echo "  - 2.1.3"
    echo "  - 1.0.0-alpha"
    echo "  - 1.0.0-beta.1"
    echo "  - 1.0.0+20250113"
    exit 1
fi

## Operation: Validate Versioning

Validate version strings against Semantic Versioning 2.0.0 specification.

### Parameters from $ARGUMENTS

- **version**: Version string to validate (required)
- **strict**: Enforce strict semver (no pre-release/build metadata) (optional, default: false)

### Semantic Versioning Standard

**Base Pattern**: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

**Strict Format**: `^[0-9]+\.[0-9]+\.[0-9]+$`

**Extended Format** (with pre-release and build metadata):
- Pre-release: `1.2.3-alpha.1`, `2.0.0-beta.2`, `1.0.0-rc.1`
- Build metadata: `1.2.3+20241013`, `1.0.0+build.1`
- Combined: `1.2.3-alpha.1+build.20241013`

### Valid Examples

**Strict Semver** (OpenPlugins recommended):
- `1.0.0` - Initial release
- `1.2.3` - Standard version
- `2.5.13` - Double-digit components
- `0.1.0` - Pre-1.0 development

**Extended Semver** (allowed):
- `1.0.0-alpha` - Alpha release
- `1.0.0-beta.2` - Beta release
- `1.0.0-rc.1` - Release candidate
- `1.2.3+20241013` - With build metadata

### Invalid Examples

- `1.0` - Missing PATCH
- `v1.0.0` - Leading 'v' prefix
- `1.0.0.0` - Too many components
- `1.2.x` - Placeholder values
- `latest` - Non-numeric
- `1.0.0-SNAPSHOT` - Non-standard identifier

### Workflow

1. **Extract Version from Arguments**
   ```
   Parse $ARGUMENTS to extract version parameter
   If version not provided, return error
   ```

2. **Execute Semantic Version Checker**
   ```bash
   Execute .scripts/semver-checker.py "$version" "$strict"

   Exit codes:
   - 0: Valid semantic version
   - 1: Invalid format
   - 2: Missing required parameters
   - 3: Strict mode violation (valid semver, but has pre-release/build)
   ```

3. **Parse Version Components**
   ```
   Extract components:
   - MAJOR: Breaking changes
   - MINOR: Backward-compatible features
   - PATCH: Backward-compatible fixes
   - Pre-release: Optional identifier (alpha, beta, rc)
   - Build metadata: Optional metadata
   ```

4. **Return Validation Report**
   ```
   Format results:
   - Status: PASS/FAIL/WARNING
   - Version: <provided-version>
   - Valid: yes/no
   - Components: MAJOR.MINOR.PATCH breakdown
   - Pre-release: <identifier> (if present)
   - Build: <metadata> (if present)
   - Score impact: +5 points (if valid)
   ```

### Examples

```bash
# Valid strict semver
/best-practices versioning version:1.2.3
# Result: PASS - Valid semantic version (1.2.3)

# Valid with pre-release
/best-practices versioning version:1.0.0-alpha.1
# Result: PASS - Valid semantic version with pre-release

# Invalid format
/best-practices versioning version:1.0
# Result: FAIL - Missing PATCH component

# Strict mode with pre-release
/best-practices versioning version:1.0.0-beta strict:true
# Result: WARNING - Valid semver but not strict format

# Invalid prefix
/best-practices versioning version:v1.2.3
# Result: FAIL - Contains 'v' prefix (use 1.2.3)
```

### Error Handling

**Missing version parameter**:
```
ERROR: Missing required parameter 'version'

Usage: /best-practices versioning version:<semver>

Example: /best-practices versioning version:1.2.3
```

**Invalid format**:
```
ERROR: Invalid semantic version format

The version must follow MAJOR.MINOR.PATCH format.

Examples:
- 1.0.0 (initial release)
- 1.2.3 (standard version)
- 2.0.0-beta.1 (pre-release)
```

### Output Format

**Success (Valid Semver)**:
```
✅ Semantic Versioning: PASS

Version: 1.2.3
Format: MAJOR.MINOR.PATCH
Valid: Yes

Components:
- MAJOR: 1 (breaking changes)
- MINOR: 2 (new features)
- PATCH: 3 (bug fixes)

Quality Score Impact: +5 points

The version follows Semantic Versioning 2.0.0 specification.
```

**Success with Pre-release**:
```
✅ Semantic Versioning: PASS

Version: 1.0.0-beta.2
Format: MAJOR.MINOR.PATCH-PRERELEASE
Valid: Yes

Components:
- MAJOR: 1
- MINOR: 0
- PATCH: 0
- Pre-release: beta.2

Quality Score Impact: +5 points

Note: Pre-release versions indicate unstable releases.
```

**Failure (Invalid Format)**:
```
❌ Semantic Versioning: FAIL

Version: 1.0
Format: Invalid
Valid: No

Issues Found:
1. Missing PATCH component
2. Expected format: MAJOR.MINOR.PATCH

Suggested Correction: 1.0.0

Quality Score Impact: 0 points (fix to gain +5)

Fix to comply with Semantic Versioning 2.0.0 specification.
Reference: https://semver.org/
```

**Warning (Strict Mode)**:
```
⚠️  Semantic Versioning: WARNING

Version: 1.0.0-alpha.1
Format: Valid semver, but not strict
Valid: Yes (with pre-release)

Note: OpenPlugins recommends strict MAJOR.MINOR.PATCH format
without pre-release or build metadata for marketplace submissions.

Recommended: 1.0.0 (for stable release)

Quality Score Impact: +5 points (valid, but consider strict format)
```

### Versioning Guidelines

**When to increment**:

**MAJOR** (X.0.0):
- Breaking API changes
- Incompatible changes
- Major rewrites

**MINOR** (x.Y.0):
- New features (backward-compatible)
- Deprecations
- Significant improvements

**PATCH** (x.y.Z):
- Bug fixes
- Security patches
- Minor improvements

**Initial Development**:
- Start with `0.1.0`
- Increment MINOR for features
- First stable release: `1.0.0`

**Pre-release Identifiers**:
- `alpha` - Early testing
- `beta` - Feature complete, testing
- `rc` - Release candidate

### Compliance Criteria

**PASS Requirements**:
- Three numeric components (MAJOR.MINOR.PATCH)
- Each component is non-negative integer
- Components separated by dots
- Optional pre-release identifier (hyphen-separated)
- Optional build metadata (plus-separated)
- No leading zeros (except single 0)

**FAIL Indicators**:
- Missing components (1.0)
- Too many components (1.0.0.0)
- Non-numeric components (1.x.0)
- Leading 'v' prefix
- Invalid separators
- Leading zeros (01.02.03)

**Request**: $ARGUMENTS

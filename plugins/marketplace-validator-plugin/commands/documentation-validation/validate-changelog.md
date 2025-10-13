## Operation: Validate CHANGELOG Format

Validate CHANGELOG.md format compliance with "Keep a Changelog" standard.

### Parameters from $ARGUMENTS

- **file**: Path to CHANGELOG file (optional, default: CHANGELOG.md)
- **format**: Expected format (optional, default: keepachangelog)
- **strict**: Enable strict validation (optional, default: false)
- **require-unreleased**: Require [Unreleased] section (optional, default: true)

### CHANGELOG Requirements

**Keep a Changelog Format** (https://keepachangelog.com/):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- New features not yet released

## [1.0.0] - 2025-01-15
### Added
- Initial release feature
### Changed
- Modified behavior
### Fixed
- Bug fixes
```

**Required Elements**:
1. **Title**: "Changelog" or "Change Log"
2. **Version Headers**: `## [X.Y.Z] - YYYY-MM-DD` format
3. **Change Categories**: Added, Changed, Deprecated, Removed, Fixed, Security
4. **Unreleased Section**: `## [Unreleased]` for upcoming changes
5. **Chronological Order**: Newest versions first

**Valid Change Categories**:
- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

### Workflow

1. **Locate CHANGELOG File**
   ```
   Check for CHANGELOG.md in plugin root
   Also check: CHANGELOG, CHANGELOG.txt, changelog.md, HISTORY.md
   If not found, report as missing (WARNING, not CRITICAL)
   ```

2. **Execute CHANGELOG Validator**
   ```bash
   Execute .scripts/changelog-validator.sh with parameters:
   - File path to CHANGELOG
   - Expected format (keepachangelog)
   - Strict mode flag
   - Require unreleased flag

   Script returns:
   - has_title: Boolean
   - has_unreleased: Boolean
   - version_headers: Array of version entries
   - categories_used: Array of change categories
   - issues: Array of format violations
   - compliance_score: 0-100
   ```

3. **Validate Version Headers**
   ```
   For each version header:
   - Check format: ## [X.Y.Z] - YYYY-MM-DD
   - Validate semantic version (X.Y.Z)
   - Validate date format (YYYY-MM-DD)
   - Check chronological order (newest first)

   Common violations:
   - Missing brackets: ## 1.0.0 - 2025-01-15 (should be [1.0.0])
   - Wrong date format: ## [1.0.0] - 01/15/2025
   - Invalid semver: ## [1.0] - 2025-01-15
   ```

4. **Validate Change Categories**
   ```
   For each version section:
   - Check for valid category headers (### Added, ### Fixed, etc.)
   - Warn if no categories used
   - Recommend appropriate categories

   Invalid category examples:
   - "### New Features" (should be "### Added")
   - "### Bugs" (should be "### Fixed")
   - "### Updates" (should be "### Changed")
   ```

5. **Calculate Compliance Score**
   ```
   score = 100
   score -= (!has_title) ? 10 : 0
   score -= (!has_unreleased) ? 15 : 0
   score -= (invalid_version_headers × 10)
   score -= (invalid_categories × 5)
   score -= (wrong_date_format × 5)
   score = max(0, score)
   ```

6. **Format Output**
   ```
   Display:
   - ✅/⚠️/❌ File presence
   - ✅/❌ Format compliance
   - ✅/⚠️ Version headers
   - ✅/⚠️ Change categories
   - Compliance score
   - Specific violations
   - Improvement recommendations
   ```

### Examples

```bash
# Validate default CHANGELOG.md
/documentation-validation changelog file:CHANGELOG.md

# Validate with custom path
/documentation-validation changelog file:./HISTORY.md

# Strict validation (all elements required)
/documentation-validation changelog file:CHANGELOG.md strict:true

# Don't require Unreleased section
/documentation-validation changelog file:CHANGELOG.md require-unreleased:false

# Part of full documentation check
/documentation-validation full-docs path:.
```

### Error Handling

**Error: CHANGELOG not found**
```
⚠️ WARNING: CHANGELOG.md not found in <path>

Remediation:
1. Create CHANGELOG.md in plugin root directory
2. Use "Keep a Changelog" format (https://keepachangelog.com/)
3. Include [Unreleased] section for upcoming changes
4. Document version history with proper headers

Example:
# Changelog

## [Unreleased]
### Added
- Features in development

## [1.0.0] - 2025-01-15
### Added
- Initial release

Note: CHANGELOG is recommended but not required for initial submission.
It becomes important for version updates.
```

**Error: Invalid version header format**
```
❌ ERROR: Invalid version header format detected

Invalid headers found:
- Line 10: "## 1.0.0 - 2025-01-15" (missing brackets)
- Line 25: "## [1.0] - 01/15/2025" (invalid semver and date format)

Correct format:
## [X.Y.Z] - YYYY-MM-DD

Examples:
- ## [1.0.0] - 2025-01-15
- ## [2.1.3] - 2024-12-20
- ## [0.1.0] - 2024-11-05

Remediation:
1. Add brackets around version numbers: [1.0.0]
2. Use semantic versioning: MAJOR.MINOR.PATCH
3. Use ISO date format: YYYY-MM-DD
```

**Error: Missing Unreleased section**
```
⚠️ WARNING: Missing [Unreleased] section

The Keep a Changelog format recommends an [Unreleased] section for tracking
upcoming changes before they're officially released.

Add to top of CHANGELOG (after title):

## [Unreleased]
### Added
- Features in development
### Changed
- Planned changes
```

**Error: Invalid change categories**
```
⚠️ WARNING: Non-standard change categories detected

Invalid categories found:
- "### New Features" (should be "### Added")
- "### Bug Fixes" (should be "### Fixed")
- "### Updates" (should be "### Changed")

Valid categories:
- Added: New features
- Changed: Changes in existing functionality
- Deprecated: Soon-to-be removed features
- Removed: Removed features
- Fixed: Bug fixes
- Security: Security vulnerability fixes

Remediation:
Replace non-standard categories with Keep a Changelog categories.
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CHANGELOG VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: ✅ CHANGELOG.md found

Format: Keep a Changelog
Compliance: <0-100>% ✅/⚠️/❌

Structure:
✅ Title present
✅ [Unreleased] section present
✅ Version headers formatted correctly
✅ Change categories valid

Version Entries: <count>
- [1.0.0] - 2025-01-15 ✅
- [0.2.0] - 2024-12-20 ✅
- [0.1.0] - 2024-11-05 ✅

Change Categories Used:
✅ Added (3 versions)
✅ Changed (2 versions)
✅ Fixed (3 versions)

Issues Found: <N>

Violations:
<List specific issues if any>

Recommendations:
1. Add Security category for vulnerability fixes
2. Expand [Unreleased] section with upcoming features
3. Add links to version comparison (optional)

Overall: <PASS|WARNINGS|FAIL>
```

### Integration

This operation is invoked by:
- `/documentation-validation changelog file:CHANGELOG.md` (direct)
- `/documentation-validation full-docs path:.` (as part of complete validation)
- `/validation-orchestrator comprehensive path:.` (via orchestrator)

Results contribute to documentation quality score:
- Present and compliant: +10 points
- Present but non-compliant: +5 points
- Missing: 0 points (warning but not blocking)

**Request**: $ARGUMENTS

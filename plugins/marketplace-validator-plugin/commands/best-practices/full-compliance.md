## Operation: Full Standards Compliance

Execute comprehensive OpenPlugins and Claude Code best practices validation with complete compliance reporting.

### Parameters from $ARGUMENTS

- **path**: Path to plugin or marketplace directory (required)
- **fix**: Auto-suggest corrections for all issues (optional, default: true)
- **format**: Output format (text|json|markdown) (optional, default: text)

### Complete Standards Check

This operation validates all four best practice categories:

1. **Naming Convention** - Lowercase-hyphen format
2. **Semantic Versioning** - MAJOR.MINOR.PATCH format
3. **Category Assignment** - One of 10 approved categories
4. **Keyword Quality** - 3-7 relevant, non-generic keywords

### Workflow

1. **Detect Target Type**
   ```
   Parse $ARGUMENTS to extract path parameter
   Detect if path is plugin or marketplace:
   - Plugin: Has plugin.json
   - Marketplace: Has .claude-plugin/marketplace.json
   ```

2. **Load Metadata**
   ```
   IF plugin:
     Read plugin.json
     Extract: name, version, keywords, category
   ELSE IF marketplace:
     Read .claude-plugin/marketplace.json
     Extract marketplace metadata
     Validate each plugin entry
   ELSE:
     Return error: Invalid target
   ```

3. **Execute All Validations**
   ```
   Run in parallel or sequence:

   A. Naming Validation
      Execute check-naming.md with name parameter
      Store result

   B. Version Validation
      Execute validate-versioning.md with version parameter
      Store result

   C. Category Validation
      Execute check-categories.md with category parameter
      Store result

   D. Keyword Validation
      Execute validate-keywords.md with keywords parameter
      Store result
   ```

4. **Aggregate Results**
   ```
   Collect all validation results:
   - Individual pass/fail status
   - Specific issues found
   - Suggested corrections
   - Score impact for each

   Calculate overall compliance:
   - Total score: Sum of individual scores
   - Pass count: Number of passing validations
   - Fail count: Number of failing validations
   - Compliance percentage: (pass / total) × 100
   ```

5. **Generate Compliance Report**
   ```
   Create comprehensive report:
   - Executive summary
   - Individual validation details
   - Issue prioritization
   - Suggested fixes
   - Compliance score
   - Publication readiness
   ```

6. **Return Results**
   ```
   Format according to output format:
   - text: Human-readable console output
   - json: Machine-parseable JSON
   - markdown: Documentation-ready markdown
   ```

### Examples

```bash
# Full compliance check on current directory
/best-practices full-standards path:.

# Check specific plugin with JSON output
/best-practices full-standards path:./my-plugin format:json

# Check with auto-fix suggestions
/best-practices full-standards path:. fix:true

# Marketplace validation
/best-practices full-standards path:./marketplace
```

### Error Handling

**Missing path parameter**:
```
ERROR: Missing required parameter 'path'

Usage: /best-practices full-standards path:<directory>

Examples:
  /best-practices full-standards path:.
  /best-practices full-standards path:./my-plugin
```

**Invalid path**:
```
ERROR: Invalid path or not a plugin/marketplace

Path: <provided-path>

The path must contain either:
- plugin.json (for plugins)
- .claude-plugin/marketplace.json (for marketplaces)

Check the path and try again.
```

**Missing metadata file**:
```
ERROR: Metadata file not found

Expected one of:
- plugin.json
- .claude-plugin/marketplace.json

This does not appear to be a valid Claude Code plugin or marketplace.
```

### Output Format

**Text Format (Complete Compliance)**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPENPLUGINS BEST PRACTICES COMPLIANCE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: code-formatter-plugin
Type: Plugin
Date: 2024-10-13

Overall Compliance: 100% ✅
Status: PUBLICATION READY

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Naming Convention: ✅ PASS
   Name: code-formatter
   Format: lowercase-hyphen
   Score: +5 points

   The name follows OpenPlugins naming conventions perfectly.

2. Semantic Versioning: ✅ PASS
   Version: 1.2.3
   Format: MAJOR.MINOR.PATCH
   Score: +5 points

   Valid semantic version compliant with semver 2.0.0.

3. Category Assignment: ✅ PASS
   Category: quality
   Description: Linting, formatting, code review
   Score: +5 points

   Category is approved and appropriate for this plugin.

4. Keyword Quality: ✅ PASS
   Keywords: formatting, javascript, eslint, code-quality, automation
   Count: 5 (optimal)
   Quality: 10/10
   Score: +10 points

   Excellent keyword selection with balanced mix.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPLIANCE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Validations Passed: 4/4 (100%)
Quality Score: 25/25 points

Scoring Breakdown:
✅ Naming Convention:     +5 points
✅ Semantic Versioning:   +5 points
✅ Category Assignment:   +5 points
✅ Keyword Quality:      +10 points
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Score:             25/25 points

Publication Status: ✅ READY FOR SUBMISSION

This plugin meets all OpenPlugins best practice standards
and is ready for marketplace submission!

Next Steps:
1. Submit to OpenPlugins marketplace
2. Follow contribution guidelines in CONTRIBUTING.md
3. Open pull request with plugin entry
```

**Text Format (Partial Compliance)**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPENPLUGINS BEST PRACTICES COMPLIANCE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: Test_Runner
Type: Plugin
Date: 2024-10-13

Overall Compliance: 50% ⚠️
Status: NEEDS IMPROVEMENT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Naming Convention: ❌ FAIL
   Name: Test_Runner
   Format: Invalid
   Score: 0 points

   Issues Found:
   - Contains uppercase characters: T, R
   - Contains underscore instead of hyphen

   ✏️  Suggested Fix: test-runner

   Impact: +5 points (if fixed)

2. Semantic Versioning: ✅ PASS
   Version: 1.0.0
   Format: MAJOR.MINOR.PATCH
   Score: +5 points

   Valid semantic version compliant with semver 2.0.0.

3. Category Assignment: ❌ FAIL
   Category: test-tools
   Valid: No
   Score: 0 points

   This category is not in the approved list.

   ✏️  Suggested Fix: testing

   Description: Test generation, coverage, quality assurance

   Impact: +5 points (if fixed)

4. Keyword Quality: ⚠️  WARNING
   Keywords: plugin, tool, awesome
   Count: 3 (minimum met)
   Quality: 2/10
   Score: 2 points

   Issues Found:
   - Generic terms: plugin, tool
   - Marketing terms: awesome
   - No functional keywords

   ✏️  Suggested Fix: testing, automation, pytest, unit-testing, tdd

   Impact: +8 points (if improved to excellent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPLIANCE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Validations Passed: 1/4 (25%)
Quality Score: 7/25 points

Scoring Breakdown:
❌ Naming Convention:     0/5 points
✅ Semantic Versioning:   5/5 points
❌ Category Assignment:   0/5 points
⚠️  Keyword Quality:     2/10 points
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Score:             7/25 points

Publication Status: ⚠️  NOT READY - NEEDS FIXES

Priority Fixes Required:
1. [P0] Fix naming convention: Test_Runner → test-runner
2. [P0] Fix category: test-tools → testing
3. [P1] Improve keywords: Remove generic terms, add functional keywords

After Fixes (Estimated Score):
✅ Naming Convention:     +5 points
✅ Semantic Versioning:   +5 points
✅ Category Assignment:   +5 points
✅ Keyword Quality:      +10 points
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Potential Score:         25/25 points

Next Steps:
1. Apply suggested fixes above
2. Re-run validation: /best-practices full-standards path:.
3. Ensure score reaches 25/25 before submission
```

**JSON Format**:
```json
{
  "target": "code-formatter",
  "type": "plugin",
  "timestamp": "2024-10-13T10:00:00Z",
  "compliance": {
    "overall": 100,
    "status": "READY",
    "passed": 4,
    "failed": 0,
    "warnings": 0
  },
  "validations": {
    "naming": {
      "status": "pass",
      "name": "code-formatter",
      "format": "lowercase-hyphen",
      "score": 5,
      "issues": []
    },
    "versioning": {
      "status": "pass",
      "version": "1.2.3",
      "format": "MAJOR.MINOR.PATCH",
      "score": 5,
      "issues": []
    },
    "category": {
      "status": "pass",
      "category": "quality",
      "valid": true,
      "score": 5,
      "issues": []
    },
    "keywords": {
      "status": "pass",
      "keywords": ["formatting", "javascript", "eslint", "code-quality", "automation"],
      "count": 5,
      "quality": 10,
      "score": 10,
      "issues": []
    }
  },
  "score": {
    "total": 25,
    "maximum": 25,
    "percentage": 100,
    "breakdown": {
      "naming": 5,
      "versioning": 5,
      "category": 5,
      "keywords": 10
    }
  },
  "publication_ready": true,
  "next_steps": [
    "Submit to OpenPlugins marketplace",
    "Follow contribution guidelines",
    "Open pull request"
  ]
}
```

**Markdown Format** (for documentation):
```markdown
# OpenPlugins Best Practices Compliance Report

**Target**: code-formatter
**Type**: Plugin
**Date**: 2024-10-13
**Status**: ✅ PUBLICATION READY

## Overall Compliance

- **Score**: 25/25 points (100%)
- **Validations Passed**: 4/4
- **Publication Ready**: Yes

## Validation Results

### 1. Naming Convention ✅

- **Status**: PASS
- **Name**: code-formatter
- **Format**: lowercase-hyphen
- **Score**: +5 points

The name follows OpenPlugins naming conventions perfectly.

### 2. Semantic Versioning ✅

- **Status**: PASS
- **Version**: 1.2.3
- **Format**: MAJOR.MINOR.PATCH
- **Score**: +5 points

Valid semantic version compliant with semver 2.0.0.

### 3. Category Assignment ✅

- **Status**: PASS
- **Category**: quality
- **Description**: Linting, formatting, code review
- **Score**: +5 points

Category is approved and appropriate for this plugin.

### 4. Keyword Quality ✅

- **Status**: PASS
- **Keywords**: formatting, javascript, eslint, code-quality, automation
- **Count**: 5 (optimal)
- **Quality**: 10/10
- **Score**: +10 points

Excellent keyword selection with balanced mix.

## Score Breakdown

| Validation | Score | Status |
|------------|-------|--------|
| Naming Convention | 5/5 | ✅ Pass |
| Semantic Versioning | 5/5 | ✅ Pass |
| Category Assignment | 5/5 | ✅ Pass |
| Keyword Quality | 10/10 | ✅ Pass |
| **Total** | **25/25** | **✅ Ready** |

## Next Steps

1. Submit to OpenPlugins marketplace
2. Follow contribution guidelines in CONTRIBUTING.md
3. Open pull request with plugin entry

---

*Report generated by marketplace-validator-plugin v1.0.0*
```

### Compliance Scoring

**Total Score Breakdown**:
- Naming Convention: 5 points
- Semantic Versioning: 5 points
- Category Assignment: 5 points
- Keyword Quality: 10 points
- **Maximum Total**: 25 points

**Publication Readiness**:
- **25/25 points (100%)**: ✅ READY - Perfect compliance
- **20-24 points (80-96%)**: ✅ READY - Minor improvements optional
- **15-19 points (60-76%)**: ⚠️  NEEDS WORK - Address issues before submission
- **10-14 points (40-56%)**: ❌ NOT READY - Significant fixes required
- **0-9 points (0-36%)**: ❌ NOT READY - Major compliance issues

### Integration with Quality Analysis

This operation feeds into the overall quality scoring system:

```
Best Practices Score (25 points max)
    ↓
Quality Analysis (calculate-score)
    ↓
Overall Quality Score (100 points total)
    ↓
Publication Readiness Determination
```

### Best Practices Workflow

For complete plugin validation:

```bash
# 1. Run full standards compliance
/best-practices full-standards path:.

# 2. If issues found, fix them, then re-run
# ... apply fixes ...
/best-practices full-standards path:.

# 3. Once compliant, run comprehensive validation
/validation-orchestrator comprehensive path:.

# 4. Review quality report
# Quality score includes best practices (25 points)
```

**Request**: $ARGUMENTS

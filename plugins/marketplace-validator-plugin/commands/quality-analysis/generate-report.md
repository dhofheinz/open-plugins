## Operation: Generate Quality Report

Generate comprehensive quality report in multiple formats (markdown, JSON, HTML) with detailed findings and recommendations.

### Parameters from $ARGUMENTS

Extract these parameters from `$ARGUMENTS`:

- **path**: Target path to analyze (required)
- **format**: Output format - markdown|json|html (default: markdown)
- **output**: Output file path (optional, defaults to stdout)
- **context**: Path to validation context JSON file with prior results (optional)

### Report Structure

**1. Executive Summary**
- Overall quality score and star rating
- Publication readiness determination
- Key findings at-a-glance
- Critical blockers (if any)

**2. Validation Layers**
- Schema validation results (pass/fail with details)
- Security scan results (vulnerabilities found)
- Documentation quality assessment
- Best practices compliance check

**3. Issues Breakdown**
- Priority 0 (Critical): Must fix before publication
- Priority 1 (Important): Should fix for quality
- Priority 2 (Recommended): Nice to have improvements

**4. Improvement Roadmap**
- Prioritized action items with effort estimates
- Expected score improvement per fix
- Timeline to reach publication-ready (90+ score)

**5. Detailed Findings**
- Full validation output from each layer
- Code examples and fix suggestions
- References to best practices documentation

### Workflow

1. **Load Validation Context**
   ```
   IF context parameter provided:
     Read validation results from context file
   ELSE:
     Use current validation state

   Extract:
   - Quality score
   - Validation layer results
   - Issue lists
   - Target metadata
   ```

2. **Generate Report Sections**
   ```python
   Execute .scripts/report-generator.py with:
   - Path to target
   - Format (markdown|json|html)
   - Validation context data
   - Output destination

   Script generates:
   - Executive summary
   - Validation layer breakdown
   - Prioritized issues
   - Improvement suggestions
   - Detailed findings
   ```

3. **Format Output**
   ```
   IF output parameter specified:
     Write report to file
     Display confirmation with file path
   ELSE:
     Print report to stdout
   ```

4. **Display Summary**
   ```
   Show brief summary:
   - Report generated successfully
   - Format used
   - Output location (if file)
   - Key metrics (score, issues)
   ```

### Examples

```bash
# Generate markdown report to stdout
/quality-analysis report path:. format:markdown

# Generate JSON report to file
/quality-analysis report path:. format:json output:quality-report.json

# Generate HTML report with context
/quality-analysis report path:. format:html context:"@validation-results.json" output:report.html

# Quick markdown report from validation results
/quality-analysis report path:. context:"@comprehensive-validation.json"
```

### Error Handling

- **Missing path**: Request target path
- **Invalid format**: List supported formats (markdown, json, html)
- **Context file not found**: Continue with limited data, warn user
- **Invalid JSON context**: Show parsing error, suggest validation
- **Write permission denied**: Show error, suggest alternative output location
- **Python not available**: Fallback to basic text report

### Output Format

**Markdown Report**:
```markdown
# Quality Assessment Report

Generated: 2025-10-13 14:30:00
Target: /path/to/plugin
Type: Claude Code Plugin

## Executive Summary

**Quality Score**: 85/100 ⭐⭐⭐⭐ (Good)
**Publication Ready**: With Minor Changes
**Critical Issues**: 0
**Total Issues**: 8

Your plugin is nearly ready for publication! Address 3 important issues to reach excellent status.

## Validation Results

### Schema Validation ✅ PASS
- All required fields present
- Valid JSON syntax
- Correct semver format

### Security Scan ✅ PASS
- No secrets exposed
- All URLs use HTTPS
- File permissions correct

### Documentation ⚠️ WARNINGS (3 issues)
- Missing CHANGELOG.md (-10 pts)
- README could use 2 more examples (-5 pts)
- No architecture documentation

### Best Practices ✅ PASS
- Naming convention correct
- Keywords appropriate (5/7)
- Category properly set

## Issues Breakdown

### Priority 0 (Critical): 0 issues
None - excellent!

### Priority 1 (Important): 3 issues

#### 1. Add CHANGELOG.md [+10 pts]
Missing version history and change documentation.

**Impact**: -10 quality score
**Effort**: Low (15 minutes)
**Fix**: Create CHANGELOG.md following Keep a Changelog format
```bash
# Create changelog
cat > CHANGELOG.md <<EOF
# Changelog
## [1.0.0] - 2025-10-13
### Added
- Initial release
EOF
```

#### 2. Expand README examples [+5 pts]
README has only 1 example, recommend 3-5 examples.

**Impact**: Poor user onboarding, -5 score
**Effort**: Medium (30 minutes)
**Fix**: Add 2-4 more usage examples showing different scenarios

#### 3. Add 2 more keywords [+3 pts]
Current: 5 keywords. Optimal: 7 keywords.

**Impact**: Reduced discoverability
**Effort**: Low (5 minutes)
**Fix**: Add relevant keywords to plugin.json

### Priority 2 (Recommended): 5 issues
[Details of nice-to-have improvements...]

## Improvement Roadmap

### Path to Excellent (90+)

Current: 85/100
Target: 90/100
Gap: 5 points

**Quick Wins** (Total: +8 pts, 20 minutes)
1. Add CHANGELOG.md → +10 pts (15 min)
2. Add 2 keywords → +3 pts (5 min)

**This Week** (Total: +5 pts, 30 minutes)
3. Expand README examples → +5 pts (30 min)

**After completion**: 98/100 ⭐⭐⭐⭐⭐ (Excellent)

## Detailed Findings

[Complete validation output from all layers...]

---
Report generated by marketplace-validator-plugin v1.0.0
```

**JSON Report**:
```json
{
  "metadata": {
    "generated": "2025-10-13T14:30:00Z",
    "target": "/path/to/plugin",
    "type": "plugin",
    "validator_version": "1.0.0"
  },
  "executive_summary": {
    "score": 85,
    "rating": "Good",
    "stars": "⭐⭐⭐⭐",
    "publication_ready": "With Minor Changes",
    "critical_issues": 0,
    "total_issues": 8
  },
  "validation_layers": {
    "schema": {"status": "pass", "issues": []},
    "security": {"status": "pass", "issues": []},
    "documentation": {"status": "warnings", "issues": [...]},
    "best_practices": {"status": "pass", "issues": []}
  },
  "issues": {
    "p0": [],
    "p1": [...],
    "p2": [...]
  },
  "improvement_roadmap": {
    "current_score": 85,
    "target_score": 90,
    "gap": 5,
    "recommendations": [...]
  }
}
```

**HTML Report**:
```html
<!DOCTYPE html>
<html>
<head>
  <title>Quality Assessment Report</title>
  <style>
    /* Styled, responsive HTML report */
  </style>
</head>
<body>
  <!-- Executive summary card -->
  <!-- Validation layer status badges -->
  <!-- Interactive issue accordion -->
  <!-- Improvement roadmap timeline -->
</body>
</html>
```

### Integration Notes

This operation is invoked by:
- `full-analysis.md` as final step to consolidate results
- `validation-orchestrator` for comprehensive reporting
- Direct user invocation for custom reports

The report aggregates data from:
- `calculate-score.md` output
- `prioritize-issues.md` categorization
- `suggest-improvements.md` recommendations
- All validation layer results

**Request**: $ARGUMENTS

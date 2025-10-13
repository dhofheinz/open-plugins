## Operation: Prioritize Issues

Categorize and prioritize validation issues by severity and impact using P0/P1/P2 tier system.

### Parameters from $ARGUMENTS

Extract these parameters from `$ARGUMENTS`:

- **issues**: Path to JSON file with issues or inline JSON string (required)
- **criteria**: Prioritization criteria - severity|impact|effort (default: severity)

### Prioritization Tiers

**Priority 0 (P0) - Critical - Must Fix**
- Invalid JSON syntax (blocks parsing)
- Missing required fields (name, version, description, author, license)
- Security vulnerabilities (exposed secrets, dangerous patterns)
- Format violations (invalid semver, malformed URLs)
- Blocks: Publication and installation

**Priority 1 (P1) - Important - Should Fix**
- Missing recommended fields (repository, homepage, keywords)
- Documentation gaps (incomplete README, missing CHANGELOG)
- Convention violations (naming, structure)
- Performance issues (slow scripts, inefficient patterns)
- Impact: Reduces quality score significantly

**Priority 2 (P2) - Recommended - Nice to Have**
- Additional keywords for discoverability
- Enhanced examples and documentation
- Expanded test coverage
- Quality improvements and polish
- Impact: Minor quality score boost

### Workflow

1. **Parse Issue Data**
   ```
   IF issues parameter starts with "@":
     Read JSON from file (remove @ prefix)
   ELSE IF issues is valid JSON:
     Parse inline JSON
   ELSE:
     Error: Invalid issues format
   ```

2. **Categorize Issues**
   ```bash
   Execute .scripts/issue-prioritizer.sh with issues data
   Categorize each issue based on:
   - Severity (critical, important, recommended)
   - Impact on publication readiness
   - Blocking status
   - Effort to fix
   ```

3. **Sort and Format**
   ```
   Group issues by priority (P0, P1, P2)
   Sort within each priority by impact
   Format with appropriate icons:
   - P0: ❌ (red X - blocking)
   - P1: ⚠️  (warning - should fix)
   - P2: 💡 (lightbulb - suggestion)
   ```

4. **Generate Summary**
   ```
   Count issues per priority
   Calculate total fix effort
   Estimate score improvement potential
   ```

### Examples

```bash
# Prioritize from validation results file
/quality-analysis prioritize issues:"@validation-results.json"

# Prioritize inline JSON
/quality-analysis prioritize issues:'{"errors": [{"type": "missing_field", "field": "license"}]}'

# Prioritize with impact criteria
/quality-analysis prioritize issues:"@results.json" criteria:impact
```

### Error Handling

- **Missing issues parameter**: Request issues data
- **Invalid JSON format**: Show JSON parsing error with line number
- **Empty issues array**: Return "No issues found" message
- **File not found**: Show file path and suggest correct path
- **Script execution error**: Fallback to basic categorization

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ISSUE PRIORITIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Issues: <count>
Estimated Fix Time: <time>

Priority 0 (Critical - Must Fix): <count>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Missing required field: license
   Impact: Blocks publication
   Effort: Low (5 minutes)
   Fix: Add "license": "MIT" to plugin.json

❌ Invalid JSON syntax at line 23
   Impact: Blocks parsing
   Effort: Low (2 minutes)
   Fix: Remove trailing comma

Priority 1 (Important - Should Fix): <count>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  Missing CHANGELOG.md
   Impact: -10 quality score
   Effort: Low (15 minutes)
   Fix: Create CHANGELOG.md following Keep a Changelog format

⚠️  README missing usage examples
   Impact: Poor user experience, -5 score
   Effort: Medium (30 minutes)
   Fix: Add 3-5 usage examples to README

Priority 2 (Recommended - Nice to Have): <count>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Add 2 more keywords for discoverability
   Impact: +3 quality score
   Effort: Low (5 minutes)
   Fix: Add relevant keywords to plugin.json

💡 Expand documentation with architecture diagram
   Impact: Better understanding, +2 score
   Effort: Medium (45 minutes)
   Fix: Create docs/ARCHITECTURE.md with diagram

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary:
- Fix P0 issues first (blocking)
- Address P1 issues for quality (30-60 min)
- Consider P2 improvements for excellence
- Total potential score gain: +20 points
```

### Issue Data Schema

Expected JSON structure:
```json
{
  "errors": [
    {
      "type": "missing_field|invalid_format|security",
      "severity": "critical|important|recommended",
      "field": "field_name",
      "message": "Description",
      "location": "file:line",
      "fix": "How to fix",
      "effort": "low|medium|high",
      "score_impact": 20
    }
  ],
  "warnings": [...],
  "recommendations": [...]
}
```

### Integration Notes

This operation is invoked by:
- `full-analysis.md` after score calculation
- `validation-orchestrator` for issue triage
- Direct user invocation for issue planning

**Request**: $ARGUMENTS

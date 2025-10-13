## Operation: Full Documentation Validation

Execute comprehensive documentation validation workflow covering all documentation aspects.

### Parameters from $ARGUMENTS

- **path**: Target plugin/marketplace path (required)
- **detailed**: Include detailed sub-reports (optional, default: true)
- **fix-suggestions**: Generate actionable improvement suggestions (optional, default: true)
- **format**: Output format (text|json|markdown) (optional, default: text)

### Full Documentation Workflow

This operation orchestrates all documentation validation sub-operations to provide
a complete documentation quality assessment.

### Workflow

1. **Initialize Validation Context**
   ```
   Create validation context:
   - Target path
   - Timestamp
   - Validation mode: comprehensive
   - Results storage structure

   Prepare for aggregating results from:
   - README validation
   - CHANGELOG validation
   - LICENSE validation
   - Examples validation
   ```

2. **Execute README Validation**
   ```
   Invoke: check-readme.md operation
   Parameters:
   - path: <target-path>
   - sections: default required sections
   - min-length: 500

   Capture results:
   - README present: Boolean
   - Sections found: Array
   - Sections missing: Array
   - Length: Integer
   - Score: 0-100
   - Issues: Array
   ```

3. **Execute CHANGELOG Validation**
   ```
   Invoke: validate-changelog.md operation
   Parameters:
   - file: CHANGELOG.md
   - format: keepachangelog
   - require-unreleased: true

   Capture results:
   - CHANGELOG present: Boolean
   - Format compliance: 0-100%
   - Version entries: Array
   - Issues: Array
   - Score: 0-100
   ```

4. **Execute LICENSE Validation**
   ```
   Invoke: check-license.md operation
   Parameters:
   - path: <target-path>
   - check-consistency: true

   Capture results:
   - LICENSE present: Boolean
   - License type: String
   - OSI approved: Boolean
   - Consistent with manifest: Boolean
   - Issues: Array
   - Score: 0-100
   ```

5. **Execute Examples Validation**
   ```
   Invoke: validate-examples.md operation
   Parameters:
   - path: <target-path>
   - no-placeholders: true
   - recursive: true

   Capture results:
   - Files checked: Integer
   - Examples found: Integer
   - Placeholders detected: Integer
   - Quality score: 0-100
   - Issues: Array
   ```

6. **Aggregate Results**
   ```
   Calculate overall documentation score:

   weights = {
     readme: 40%,      # Most important
     examples: 30%,    # Critical for usability
     license: 20%,     # Required for submission
     changelog: 10%    # Recommended but not critical
   }

   overall_score = (
     readme_score × 0.40 +
     examples_score × 0.30 +
     license_score × 0.20 +
     changelog_score × 0.10
   )

   Round to integer: 0-100
   ```

7. **Categorize Issues by Priority**
   ```
   CRITICAL (P0 - Blocking):
   - README.md missing
   - LICENSE file missing
   - README < 200 characters
   - Non-OSI-approved license
   - License mismatch with manifest

   IMPORTANT (P1 - Should Fix):
   - README missing 2+ required sections
   - README < 500 characters
   - No examples in README
   - 5+ placeholder patterns
   - CHANGELOG has format errors

   RECOMMENDED (P2 - Nice to Have):
   - CHANGELOG missing
   - README missing optional sections
   - < 3 examples
   - Minor placeholder patterns
   ```

8. **Generate Improvement Roadmap**
   ```
   Create prioritized action plan:

   For each issue:
   - Identify impact on overall score
   - Estimate effort (Low/Medium/High)
   - Calculate score improvement
   - Generate specific remediation steps

   Sort by: Priority → Score Impact → Effort

   Example:
   1. [P0] Add LICENSE file → +20 pts → 15 min
   2. [P1] Expand README to 500+ chars → +10 pts → 30 min
   3. [P1] Add 2 usage examples → +15 pts → 20 min
   4. [P2] Create CHANGELOG.md → +10 pts → 15 min
   ```

9. **Determine Publication Readiness**
   ```
   Publication readiness determination:

   READY (90-100):
   - All critical requirements met
   - High-quality documentation
   - No blocking issues
   - Immediate submission recommended

   READY WITH MINOR IMPROVEMENTS (75-89):
   - Critical requirements met
   - Some recommended improvements
   - Can submit, but improvements increase quality
   - Suggested: Address P1 issues before submission

   NEEDS WORK (60-74):
   - Critical requirements met
   - Several important issues
   - Should address P1 issues before submission
   - Documentation needs expansion

   NOT READY (<60):
   - Critical issues present
   - Insufficient documentation quality
   - Must address P0 and P1 issues
   - Submission will be rejected
   ```

10. **Format Output**
    ```
    Based on format parameter:
    - text: Human-readable report
    - json: Structured JSON for automation
    - markdown: Formatted markdown report
    ```

### Examples

```bash
# Full documentation validation with defaults
/documentation-validation full-docs path:.

# With detailed sub-reports
/documentation-validation full-docs path:. detailed:true

# JSON output for automation
/documentation-validation full-docs path:. format:json

# Without fix suggestions (faster)
/documentation-validation full-docs path:. fix-suggestions:false

# Validate specific plugin
/documentation-validation full-docs path:/path/to/plugin
```

### Error Handling

**Error: Multiple critical issues**
```
❌ CRITICAL: Multiple blocking documentation issues

Documentation Score: <score>/100 ⚠️

BLOCKING ISSUES (<count>):
1. README.md not found
   → Create README.md with required sections
   → Minimum 500 characters
   → Include Overview, Installation, Usage, Examples, License

2. LICENSE file not found
   → Create LICENSE file with OSI-approved license
   → MIT License recommended
   → Must match plugin.json license field

3. License mismatch
   → plugin.json declares "Apache-2.0"
   → LICENSE file contains "MIT"
   → Update one to match the other

IMPORTANT ISSUES (<count>):
- README missing Examples section
- No code examples found
- CHANGELOG.md recommended

YOUR NEXT STEPS:
1. Add LICENSE file (CRITICAL - 15 minutes)
2. Create comprehensive README.md (CRITICAL - 30 minutes)
3. Add 3 usage examples (IMPORTANT - 20 minutes)

After addressing critical issues, revalidate with:
/documentation-validation full-docs path:.
```

**Error: Documentation too sparse**
```
⚠️ WARNING: Documentation exists but is too sparse

Documentation Score: 65/100 ⚠️

Your documentation meets minimum requirements but needs expansion
for professional quality.

AREAS NEEDING IMPROVEMENT:
1. README is only 342 characters (minimum: 500)
   → Expand installation instructions
   → Add more detailed usage examples
   → Include troubleshooting section

2. Only 1 example found (recommended: 3+)
   → Add basic usage example
   → Add advanced example
   → Add configuration example

3. CHANGELOG missing
   → Create CHANGELOG.md
   → Use Keep a Changelog format
   → Document version 1.0.0 features

IMPACT:
Current: 65/100 (Fair)
After improvements: ~85/100 (Good)

Time investment: ~45 minutes
Quality improvement: +20 points
```

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPREHENSIVE DOCUMENTATION VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: <path>
Type: <marketplace|plugin>
Timestamp: <YYYY-MM-DD HH:MM:SS>

OVERALL DOCUMENTATION SCORE: <0-100>/100 <⭐⭐⭐⭐⭐>
Rating: <Excellent|Good|Fair|Needs Improvement|Poor>
Publication Ready: <Yes|Yes with improvements|Needs work|No>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPONENT SCORES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

README (Weight: 40%)
  Score: <0-100>/100 ✅
  Status: ✅ Complete and comprehensive
  Sections: <N>/5 required sections found
  Length: <N> characters (minimum: 500) ✅
  Issues: None

EXAMPLES (Weight: 30%)
  Score: <0-100>/100 ⚠️
  Status: ⚠️ Could be improved
  Examples found: <N> (recommended: 3+)
  Placeholders: <N> detected
  Issues: <N> placeholder patterns found

LICENSE (Weight: 20%)
  Score: <0-100>/100 ✅
  Status: ✅ Valid and consistent
  Type: MIT License
  OSI Approved: ✅ Yes
  Consistency: ✅ Matches plugin.json
  Issues: None

CHANGELOG (Weight: 10%)
  Score: <0-100>/100 ⚠️
  Status: ⚠️ Missing (recommended but not required)
  Format: N/A
  Versions: 0
  Issues: CHANGELOG.md not found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ISSUES SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Critical (P0 - Blocking): <count>
Important (P1 - Should Fix): <count>
Recommended (P2 - Nice to Have): <count>

CRITICAL ISSUES:
[None - Ready for submission] ✅

IMPORTANT ISSUES:
⚠️ 1. Add 2 more usage examples to README
     Impact: +15 points
     Effort: Low (20 minutes)

⚠️ 2. Replace 3 placeholder patterns in examples
     Impact: +10 points
     Effort: Low (10 minutes)

RECOMMENDATIONS:
💡 1. Create CHANGELOG.md for version tracking
     Impact: +10 points
     Effort: Low (15 minutes)

💡 2. Add troubleshooting section to README
     Impact: +5 points
     Effort: Low (15 minutes)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPROVEMENT ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Score: <score>/100
Target Score: 90/100 (Excellent - Publication Ready)
Gap: <gap> points

RECOMMENDED ACTIONS (to reach 90+):

1. [+15 pts] Add usage examples
   Priority: High
   Effort: 20 minutes
   Description:
   - Add 2 more concrete usage examples to README
   - Include basic, intermediate, and advanced scenarios
   - Use real plugin commands and parameters

2. [+10 pts] Clean up placeholder patterns
   Priority: Medium
   Effort: 10 minutes
   Description:
   - Replace "YOUR_VALUE" patterns with concrete examples
   - Complete or remove TODO markers
   - Use template syntax (${VAR}) for user-provided values

3. [+10 pts] Create CHANGELOG.md
   Priority: Medium
   Effort: 15 minutes
   Description:
   - Use Keep a Changelog format
   - Document version 1.0.0 initial release
   - Add [Unreleased] section for future changes

AFTER IMPROVEMENTS:
Projected Score: ~90/100 ⭐⭐⭐⭐⭐
Time Investment: ~45 minutes
Status: Excellent - Ready for submission

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PUBLICATION READINESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: ✅ READY WITH MINOR IMPROVEMENTS

Your plugin documentation meets all critical requirements and is ready
for submission to OpenPlugins marketplace. The recommended improvements
above will increase quality score and provide better user experience.

✅ Strengths:
- Comprehensive README with all required sections
- Valid OSI-approved license (MIT)
- License consistent with plugin.json
- Good documentation structure

⚠️ Improvement Opportunities:
- Add more usage examples for better user onboarding
- Create CHANGELOG for version tracking
- Clean up minor placeholder patterns

NEXT STEPS:
1. (Optional) Address recommended improvements (~45 min)
2. Run validation again to verify improvements
3. Submit to OpenPlugins marketplace

Command to revalidate:
/documentation-validation full-docs path:.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Integration

This operation is the primary entry point for complete documentation validation:

**Invoked by**:
- `/documentation-validation full-docs path:.` (direct invocation)
- `/validation-orchestrator comprehensive path:.` (as part of full plugin validation)
- marketplace-validator agent (automatic documentation assessment)

**Invokes sub-operations**:
- `/documentation-validation readme path:.`
- `/documentation-validation changelog file:CHANGELOG.md`
- `/documentation-validation license path:.`
- `/documentation-validation examples path:.`

**Feeds results to**:
- `/quality-analysis full-analysis` (for overall quality scoring)
- `/quality-analysis generate-report` (for report generation)

### JSON Output Format

When `format:json` is specified:

```json
{
  "validation_type": "full-documentation",
  "target_path": "/path/to/plugin",
  "timestamp": "2025-01-15T10:30:00Z",
  "overall_score": 85,
  "rating": "Good",
  "publication_ready": "yes_with_improvements",
  "components": {
    "readme": {
      "score": 90,
      "status": "pass",
      "present": true,
      "sections_found": 5,
      "sections_missing": 0,
      "length": 1234,
      "issues": []
    },
    "changelog": {
      "score": 70,
      "status": "warning",
      "present": true,
      "compliance": 70,
      "issues": ["Invalid version header format"]
    },
    "license": {
      "score": 100,
      "status": "pass",
      "present": true,
      "type": "MIT",
      "osi_approved": true,
      "consistent": true,
      "issues": []
    },
    "examples": {
      "score": 75,
      "status": "warning",
      "examples_found": 2,
      "placeholders_detected": 3,
      "issues": ["Placeholder patterns detected"]
    }
  },
  "issues": {
    "critical": [],
    "important": [
      {
        "component": "examples",
        "message": "Add 2 more usage examples",
        "impact": 15,
        "effort": "low"
      }
    ],
    "recommended": [
      {
        "component": "readme",
        "message": "Add troubleshooting section",
        "impact": 5,
        "effort": "low"
      }
    ]
  },
  "improvement_roadmap": [
    {
      "action": "Add usage examples",
      "points": 15,
      "priority": "high",
      "effort": "20 minutes"
    }
  ],
  "projected_score_after_improvements": 95
}
```

**Request**: $ARGUMENTS

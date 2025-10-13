## Operation: Full Quality Analysis

Execute comprehensive quality analysis orchestrating all sub-operations to generate complete assessment.

### Parameters from $ARGUMENTS

Extract these parameters from `$ARGUMENTS`:

- **path**: Target path to analyze (required)
- **context**: Path to validation context JSON file with prior results (optional)
- **format**: Report output format - markdown|json|html (default: markdown)
- **output**: Output file path for report (optional)

### Full Analysis Workflow

This operation orchestrates all quality-analysis sub-operations to provide a complete quality assessment.

**1. Load Validation Context**
```
IF context parameter provided:
  Read validation results from JSON file
  Extract:
  - Errors count
  - Warnings count
  - Missing fields count
  - Validation layer results
  - Detailed issue list
ELSE:
  Use default values:
  - errors: 0
  - warnings: 0
  - missing: 0
```

**2. Calculate Base Score**
```
Read calculate-score.md operation instructions
Execute scoring with validation results:

python3 .scripts/scoring-algorithm.py \
  --errors $errors \
  --warnings $warnings \
  --missing $missing \
  --format json

Capture:
- Quality score (0-100)
- Rating (Excellent/Good/Fair/Needs Improvement/Poor)
- Star rating (⭐⭐⭐⭐⭐)
- Publication readiness status
```

**3. Prioritize All Issues**
```
Read prioritize-issues.md operation instructions

IF context has issues:
  Write issues to temporary JSON file
  Execute issue prioritization:

  bash .scripts/issue-prioritizer.sh $temp_issues_file

  Capture:
  - P0 (Critical) issues with details
  - P1 (Important) issues with details
  - P2 (Recommended) issues with details
ELSE:
  Skip (no issues to prioritize)
```

**4. Generate Improvement Suggestions**
```
Read suggest-improvements.md operation instructions
Generate actionable recommendations:

Target score: 90 (publication-ready)
Current score: $calculated_score

Generate suggestions for:
- Quick wins (< 30 min, high impact)
- This week improvements (< 2 hours)
- Long-term enhancements

Include:
- Score impact per suggestion
- Effort estimates
- Priority assignment
- Detailed fix instructions
```

**5. Generate Comprehensive Report**
```
Read generate-report.md operation instructions
Execute report generation:

python3 .scripts/report-generator.py \
  --path $path \
  --format $format \
  --context $aggregated_context \
  --output $output

Report includes:
- Executive summary
- Quality score and rating
- Validation layer breakdown
- Prioritized issues (P0/P1/P2)
- Improvement recommendations
- Detailed findings
```

**6. Aggregate and Display Results**
```
Combine all outputs into unified assessment:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPREHENSIVE QUALITY ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: <path>
Type: <marketplace|plugin>
Analyzed: <timestamp>

QUALITY SCORE: <0-100>/100 <⭐⭐⭐⭐⭐>
Rating: <rating>
Publication Ready: <Yes|No|With Changes>

CRITICAL ISSUES: <P0 count>
IMPORTANT ISSUES: <P1 count>
RECOMMENDATIONS: <P2 count>

[Executive Summary - 2-3 sentences on readiness]

[If not publication-ready, show top 3 quick wins]

[Report file location if output specified]
```

### Workflow Steps

1. **Initialize Analysis**
   ```
   Validate path exists
   Load validation context if provided
   Set up temporary files for intermediate results
   ```

2. **Execute Operations Sequentially**
   ```
   Step 1: Calculate Score
   └─→ Invoke scoring-algorithm.py
       └─→ Store result in context

   Step 2: Prioritize Issues (if issues exist)
   └─→ Invoke issue-prioritizer.sh
       └─→ Store categorized issues in context

   Step 3: Generate Suggestions
   └─→ Analyze score gap
       └─→ Create actionable recommendations
           └─→ Store in context

   Step 4: Generate Report
   └─→ Invoke report-generator.py
       └─→ Aggregate all context data
           └─→ Format in requested format
               └─→ Output to file or stdout
   ```

3. **Present Summary**
   ```
   Display high-level results
   Show publication readiness
   Highlight critical blockers (if any)
   Show top quick wins
   Provide next steps
   ```

### Examples

```bash
# Full analysis with validation context
/quality-analysis full-analysis path:. context:"@validation-results.json"

# Full analysis generating HTML report
/quality-analysis full-analysis path:. format:html output:quality-report.html

# Full analysis with JSON output
/quality-analysis full-analysis path:. context:"@results.json" format:json output:analysis.json

# Basic full analysis (no prior context)
/quality-analysis full-analysis path:.
```

### Error Handling

- **Missing path**: Request target path parameter
- **Invalid context file**: Continue with limited data, show warning
- **Script execution failures**: Show which operation failed, provide fallback
- **Output write errors**: Fall back to stdout with warning
- **No issues found**: Congratulate on perfect quality, skip issue operations

### Output Format

**Terminal Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPREHENSIVE QUALITY ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: /path/to/plugin
Type: Claude Code Plugin
Analyzed: 2025-10-13 14:30:00

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUALITY SCORE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

85/100 ⭐⭐⭐⭐ (Good)
Publication Ready: With Minor Changes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ISSUES SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Critical (P0):   0 ✅
Important (P1):  3 ⚠️
Recommended (P2): 5 💡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXECUTIVE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your plugin is nearly ready for publication! No critical blockers
found. Address 3 important issues to reach excellent status (90+).
Quality foundation is solid with good documentation and security.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOP QUICK WINS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [+10 pts] Add CHANGELOG.md (15 minutes)
   Impact: Improves version tracking
   Fix: Create CHANGELOG.md with version history

2. [+3 pts] Add 2 more keywords (5 minutes)
   Impact: Better discoverability
   Fix: Add relevant keywords to plugin.json

3. [+2 pts] Add repository URL (2 minutes)
   Impact: Professional appearance
   Fix: Add repository field to plugin.json

After Quick Wins: 100/100 ⭐⭐⭐⭐⭐ (Excellent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DETAILED REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Full report saved to: quality-report.md

Next Steps:
1. Review detailed report for all findings
2. Implement quick wins (22 minutes total)
3. Re-run validation to verify improvements
4. Submit to OpenPlugins marketplace

Questions? Consult: docs.claude.com/plugins
```

### Integration Notes

This operation is the **primary entry point** for complete quality assessment.

**Invoked by**:
- `validation-orchestrator` after comprehensive validation
- `marketplace-validator` agent for submission readiness
- Direct user invocation for full assessment

**Orchestrates**:
- `calculate-score.md` - Quality scoring
- `prioritize-issues.md` - Issue categorization
- `suggest-improvements.md` - Actionable recommendations
- `generate-report.md` - Comprehensive reporting

**Data Flow**:
```
Validation Results
       ↓
Calculate Score → score, rating, stars
       ↓
Prioritize Issues → P0/P1/P2 categorization
       ↓
Suggest Improvements → actionable recommendations
       ↓
Generate Report → formatted comprehensive report
       ↓
Display Summary → user-friendly terminal output
```

### Performance

- **Execution Time**: 2-5 seconds (depending on issue count)
- **I/O Operations**: Minimal (uses temporary files for large datasets)
- **Memory Usage**: Low (streaming JSON processing)
- **Parallelization**: Sequential (each step depends on previous)

### Quality Assurance

**Validation Steps**:
1. Verify all scripts are executable
2. Check Python 3.6+ availability
3. Validate JSON context format
4. Verify write permissions for output
5. Ensure scoring algorithm consistency

**Testing**:
```bash
# Test with perfect plugin
/quality-analysis full-analysis path:./test-fixtures/perfect-plugin

# Test with issues
/quality-analysis full-analysis path:./test-fixtures/needs-work

# Test report formats
/quality-analysis full-analysis path:. format:json
/quality-analysis full-analysis path:. format:html
/quality-analysis full-analysis path:. format:markdown
```

**Request**: $ARGUMENTS

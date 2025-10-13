## Operation: Calculate Quality Score

Calculate comprehensive quality score (0-100) based on validation results with star rating.

### Parameters from $ARGUMENTS

Extract these parameters from `$ARGUMENTS`:

- **path**: Target path to analyze (required)
- **errors**: Critical error count (default: 0)
- **warnings**: Warning count (default: 0)
- **missing**: Missing recommended fields count (default: 0)

### Scoring Algorithm

Execute the quality scoring algorithm using `.scripts/scoring-algorithm.py`:

**Algorithm**:
```
score = 100
score -= (errors × 20)        # Critical errors: -20 points each
score -= (warnings × 10)      # Warnings: -10 points each
score -= (missing × 5)        # Missing recommended: -5 points each
score = max(0, score)         # Floor at 0
```

**Rating Thresholds**:
- **90-100**: Excellent ⭐⭐⭐⭐⭐ (publication-ready)
- **75-89**: Good ⭐⭐⭐⭐ (ready with minor improvements)
- **60-74**: Fair ⭐⭐⭐ (needs work)
- **40-59**: Needs Improvement ⭐⭐ (substantial work needed)
- **0-39**: Poor ⭐ (major overhaul required)

### Workflow

1. **Parse Arguments**
   ```
   Extract path, errors, warnings, missing from $ARGUMENTS
   Validate that path exists
   Set defaults for missing parameters
   ```

2. **Calculate Score**
   ```bash
   Invoke Bash tool to execute:
   python3 .claude/commands/quality-analysis/.scripts/scoring-algorithm.py \
     --errors $errors \
     --warnings $warnings \
     --missing $missing
   ```

3. **Format Output**
   ```
   Display results in user-friendly format with:
   - Numeric score (0-100)
   - Rating (Excellent/Good/Fair/Needs Improvement/Poor)
   - Star rating (⭐⭐⭐⭐⭐)
   - Publication readiness status
   ```

### Examples

```bash
# Calculate score with validation results
/quality-analysis score path:. errors:2 warnings:5 missing:3

# Calculate perfect score
/quality-analysis score path:. errors:0 warnings:0 missing:0

# Calculate score with only errors
/quality-analysis score path:. errors:3
```

### Error Handling

- **Missing path**: Request path parameter
- **Invalid counts**: Negative numbers default to 0
- **Script not found**: Provide clear error message with remediation
- **Python not available**: Fallback to bash calculation

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUALITY SCORE CALCULATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: <path>

Score: <0-100>/100
Rating: <Excellent|Good|Fair|Needs Improvement|Poor>
Stars: <⭐⭐⭐⭐⭐>

Breakdown:
  Base Score:        100
  Critical Errors:   -<errors × 20>
  Warnings:          -<warnings × 10>
  Missing Fields:    -<missing × 5>
  ─────────────────────
  Final Score:       <score>/100

Publication Ready: <Yes|With Minor Changes|Needs Work|Not Ready>
```

### Integration Notes

This operation is typically invoked by:
- `full-analysis.md` as first step
- `validation-orchestrator` after comprehensive validation
- Direct user invocation for score-only calculation

**Request**: $ARGUMENTS

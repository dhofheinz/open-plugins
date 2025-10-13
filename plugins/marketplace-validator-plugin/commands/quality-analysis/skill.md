---
description: Deep quality analysis with scoring, recommendations, and actionable reports
---

You are the Quality Analysis coordinator, responsible for comprehensive quality assessment and scoring.

## Your Mission

Parse `$ARGUMENTS` to determine the requested quality analysis operation and route to the appropriate sub-command.

## Available Operations

Parse the first word of `$ARGUMENTS` to determine which operation to execute:

- **score** → Read `.claude/commands/quality-analysis/calculate-score.md`
- **report** → Read `.claude/commands/quality-analysis/generate-report.md`
- **prioritize** → Read `.claude/commands/quality-analysis/prioritize-issues.md`
- **improve** → Read `.claude/commands/quality-analysis/suggest-improvements.md`
- **full-analysis** → Read `.claude/commands/quality-analysis/full-analysis.md`

## Argument Format

```
/quality-analysis <operation> [parameters]
```

### Examples

```bash
# Calculate quality score
/quality-analysis score path:. errors:2 warnings:5 missing:3

# Generate comprehensive report
/quality-analysis report path:. format:markdown

# Prioritize issues by severity
/quality-analysis prioritize issues:"@validation-results.json"

# Get improvement suggestions
/quality-analysis improve path:. score:65

# Run full quality analysis
/quality-analysis full-analysis path:. context:"@validation-context.json"
```

## Quality Scoring System

This skill implements the OpenPlugins quality scoring system:
- **90-100**: Excellent ⭐⭐⭐⭐⭐ (publication-ready)
- **75-89**: Good ⭐⭐⭐⭐ (ready with minor improvements)
- **60-74**: Fair ⭐⭐⭐ (needs work)
- **40-59**: Needs Improvement ⭐⭐
- **0-39**: Poor ⭐ (substantial work needed)

## Error Handling

If the operation is not recognized:
1. List all available operations
2. Show example usage
3. Suggest closest match

## Base Directory

Base directory for this skill: `.claude/commands/quality-analysis/`

## Your Task

1. Parse `$ARGUMENTS` to extract operation and parameters
2. Read the corresponding operation file
3. Execute quality analysis with provided parameters
4. Return actionable results with clear recommendations

**Current Request**: $ARGUMENTS

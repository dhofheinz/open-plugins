---
description: Analyze git changes to understand nature, scope, and commit type for intelligent message generation
---

# Commit Analysis Skill - Change Analysis and Type Detection

Intelligent analysis of git changes to determine commit type, scope, and atomicity for semantic commit message generation.

## Operations

- **analyze** - Full analysis (type, scope, atomicity)
- **detect-type** - Determine commit type (feat, fix, docs, etc.)
- **identify-scope** - Identify affected module/component
- **assess-atomicity** - Check if changes should be split
- **file-stats** - Get file change statistics

## Router Logic

Parse $ARGUMENTS to determine which operation to perform:

1. Extract operation from first word of $ARGUMENTS
2. Extract remaining arguments as operation parameters
3. Route to appropriate instruction file:
   - "analyze" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis/analyze-changes.md`
   - "detect-type" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis/detect-type.md`
   - "identify-scope" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis/identify-scope.md`
   - "assess-atomicity" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis/assess-atomicity.md`
   - "file-stats" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis/file-stats.md`

4. Execute instructions with parameters
5. Return structured analysis results

## Error Handling

- If operation is unknown, list available operations
- If parameters are missing, show required format
- If not a git repository, return clear error message
- If no changes to analyze, inform user

## Usage Examples

```bash
# Full analysis of current changes
/commit-analysis analyze

# Detect commit type only
/commit-analysis detect-type

# Identify affected scope
/commit-analysis identify-scope

# Check if changes should be split
/commit-analysis assess-atomicity

# Get file statistics
/commit-analysis file-stats
```

---

**Base directory:** `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-analysis`

**Current request:** $ARGUMENTS

Parse operation and route to appropriate instruction file.

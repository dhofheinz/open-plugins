---
description: Enforce git commit best practices and workflow guidance
---

# Commit Best Practices Skill Router

You are orchestrating commit best practices validation and workflow guidance operations.

## Parse Request

Examine `$ARGUMENTS` to determine the operation and parameters:

**Format**: `<operation> [parameters]`

## Available Operations

1. **check-pre-commit** - Validate repository state before committing
   - Runs tests, lint checks, detects debug code
   - Validates no TODOs, no merge markers
   - Format: `check-pre-commit [quick:true|false]`

2. **review-commit** - Review most recent commit quality
   - Analyzes commit message and changes
   - Checks atomicity and completeness
   - Format: `review-commit [commit:HEAD|<sha>]`

3. **amend-guidance** - Guide safe commit amending
   - Checks if safe to amend (not pushed, same author)
   - Provides amend instructions
   - Format: `amend-guidance [force:true|false]`

4. **revert-guidance** - Help with commit reverts
   - Generates proper revert commit message
   - Provides revert instructions
   - Format: `revert-guidance commit:<sha>`

5. **workflow-tips** - Complete git workflow guidance
   - Best practices overview
   - Branch management tips
   - Format: `workflow-tips [focus:commit|branch|merge]`

## Routing Logic

```
Parse first word from $ARGUMENTS:
  "check-pre-commit" → Read commands/commit-best-practices/check-pre-commit.md
  "review-commit"    → Read commands/commit-best-practices/review-commit.md
  "amend-guidance"   → Read commands/commit-best-practices/amend-guidance.md
  "revert-guidance"  → Read commands/commit-best-practices/revert-guidance.md
  "workflow-tips"    → Read commands/commit-best-practices/workflow-tips.md
  (unknown)          → Show error and list available operations
```

## Base Directory

**Location**: `.claude/commands/commit-best-practices/`

## Error Handling

If operation is not recognized:
```
ERROR: Unknown operation: <operation>

Available operations:
  - check-pre-commit [quick:true|false]
  - review-commit [commit:HEAD|<sha>]
  - amend-guidance [force:true|false]
  - revert-guidance commit:<sha>
  - workflow-tips [focus:commit|branch|merge]

Example: /commit-best-practices check-pre-commit quick:true
```

## Request Context

**User Request**: `$ARGUMENTS`

Now route to the appropriate operation file and execute its instructions with the provided parameters.

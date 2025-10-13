---
description: Handle git errors and edge cases gracefully
---

# Git Commit Error Handling

You are a git error diagnosis and resolution specialist. Your role is to detect, diagnose, and provide clear guidance for resolving common git issues that prevent successful commits.

## Operation Router

Parse the operation from $ARGUMENTS and route to the appropriate handler:

**Available Operations:**

1. **handle-no-repo** - Not a git repository error
   - Usage: `handle-no-repo`
   - Detects and resolves "not a git repository" errors

2. **handle-no-changes** - Working tree clean error
   - Usage: `handle-no-changes`
   - Handles "nothing to commit, working tree clean" errors

3. **handle-conflicts** - Merge conflicts present
   - Usage: `handle-conflicts`
   - Detects and guides resolution of merge conflicts

4. **handle-detached-head** - Detached HEAD state
   - Usage: `handle-detached-head`
   - Handles detached HEAD state and provides solutions

5. **diagnose-issues** - Comprehensive git issue diagnosis
   - Usage: `diagnose-issues`
   - Runs all checks and provides complete diagnosis

## Routing Logic

```
Extract first word from $ARGUMENTS as operation

IF operation = "handle-no-repo":
    Read .claude/commands/commit-error-handling/handle-no-repo.md
    Execute instructions

ELSE IF operation = "handle-no-changes":
    Read .claude/commands/commit-error-handling/handle-no-changes.md
    Execute instructions

ELSE IF operation = "handle-conflicts":
    Read .claude/commands/commit-error-handling/handle-conflicts.md
    Execute instructions

ELSE IF operation = "handle-detached-head":
    Read .claude/commands/commit-error-handling/handle-detached-head.md
    Execute instructions

ELSE IF operation = "diagnose-issues":
    Read .claude/commands/commit-error-handling/diagnose-issues.md
    Execute instructions

ELSE:
    Show error:
    "Unknown operation: {operation}

    Available operations:
    - handle-no-repo
    - handle-no-changes
    - handle-conflicts
    - handle-detached-head
    - diagnose-issues

    Usage: /commit-error-handling <operation>"
```

## Error Handling Philosophy

1. **Detect Early** - Identify issues before attempting operations
2. **Clear Messages** - Explain what's wrong in plain language
3. **Actionable Solutions** - Provide specific commands to fix
4. **Safe Guidance** - Never suggest destructive operations without warnings
5. **Educational** - Help users understand the underlying issue

## Integration Points

This skill is typically invoked:
- **Before commit operations** - Validate repository state
- **On commit failures** - Diagnose why commit failed
- **Interactive guidance** - Help users resolve git issues
- **Agent workflows** - Automated error detection and recovery

## Base Directory

All operation files are located in: `.claude/commands/commit-error-handling/`

## Request

Process: $ARGUMENTS

---
description: Guide splitting large commits into atomic, focused commits
---

# Atomic Commit Skill

Help users create atomic commits - one logical change per commit.

## Available Operations

- **analyze** → Determine if changes should be split
- **group** → Group related files together
- **suggest** → Recommend commit breakdown
- **sequence** → Generate commit sequence plan
- **interactive** → Interactive splitting guidance

## Usage Examples

```bash
# Analyze if splitting needed
/atomic-commit analyze

# Group files by type and scope
/atomic-commit group strategy:type

# Suggest commit breakdown
/atomic-commit suggest

# Create commit sequence
/atomic-commit sequence groups:"feat:5,fix:2,docs:1"

# Interactive splitting
/atomic-commit interactive
```

## Atomic Commit Principles

**One logical change per commit:**
- ✅ Single type (all feat, or all fix)
- ✅ Single scope (all auth, or all api)
- ✅ Reasonable size (≤10 files)
- ✅ Logically cohesive
- ✅ Can be reverted independently

## Router Logic

Parse $ARGUMENTS to determine operation:

1. Extract first word as operation name
2. Parse remaining parameters as key:value pairs
3. Route to appropriate operation file
4. Handle errors gracefully

**Available operations:**
- `analyze` → Read `commands/atomic-commit/analyze-splitting.md`
- `group` → Read `commands/atomic-commit/group-files.md`
- `suggest` → Read `commands/atomic-commit/suggest-commits.md`
- `sequence` → Read `commands/atomic-commit/create-sequence.md`
- `interactive` → Read `commands/atomic-commit/interactive-split.md`

**Error Handling:**
- Unknown operation → List available operations with examples
- No changes detected → Prompt user to make changes first
- Already atomic → Confirm no split needed

**Base directory**: `commands/atomic-commit/`
**Current request**: $ARGUMENTS

### Processing Steps

1. Parse operation from $ARGUMENTS
2. Validate operation exists
3. Extract parameters
4. Read corresponding operation file
5. Execute operation with parameters
6. Return results with actionable guidance

### Example Flows

**Quick analysis:**
```
/atomic-commit analyze
→ Analyzes current changes
→ Returns split recommendation with reasoning
```

**Interactive workflow:**
```
/atomic-commit interactive
→ Guides step-by-step through splitting
→ Shows groupings, suggests commits, creates plan
```

**Custom grouping:**
```
/atomic-commit group strategy:scope
→ Groups files by module/scope
→ Returns groupings for review
```

---
description: Assess if changes are atomic (single logical change) or should be split into multiple commits
---

# Operation: Assess Atomicity

Determine if changes form an atomic commit (single logical change) or should be split into multiple focused commits.

## Parameters from $ARGUMENTS

No parameters required. Analyzes all current changes.

## Workflow

### Step 1: Gather Change Data

```bash
git status --short
git diff HEAD --stat
git diff HEAD
```

### Step 2: Run Atomicity Analysis

Execute atomicity checker script:

```bash
git diff HEAD | .scripts/atomicity-checker.py
```

The script analyzes:
- Number of files changed
- Types of changes (feat, fix, docs, etc.)
- Scopes affected
- Interdependencies
- Logical cohesion

### Step 3: Atomicity Criteria

**Atomic Commit** (single commit appropriate):
- All changes serve ONE logical purpose
- All files relate to the same feature/fix
- Changes are interdependent
- Same type throughout (all feat, or all fix)
- Same scope throughout (all auth, or all api)
- Can be reverted as a complete unit
- Tests pass after commit

**Non-Atomic** (should split):
- Multiple distinct types (feat + fix + docs)
- Multiple unrelated scopes (auth + api + ui)
- Mixing concerns (feature + refactoring + bug fix)
- Too many files (10+ unrelated files)
- Multiple stories being told

### Step 4: Splitting Recommendations

If non-atomic, suggest how to split:

**By Type:**
```
Split into commits by change type:
  1. feat(auth): OAuth implementation (5 files)
  2. test(auth): OAuth tests (2 files)
  3. docs: authentication guide (1 file)
```

**By Scope:**
```
Split into commits by module:
  1. feat(auth): authentication system (6 files)
  2. feat(api): user API endpoints (4 files)
  3. feat(ui): login components (3 files)
```

**By Feature:**
```
Split into commits by logical unit:
  1. feat(payments): Stripe integration (8 files)
  2. feat(payments): PayPal integration (6 files)
  3. test(payments): payment tests (4 files)
```

### Step 5: Format Atomicity Assessment

```
ATOMICITY ASSESSMENT
═══════════════════════════════════════════════

STATUS: <ATOMIC | SHOULD SPLIT>

ANALYSIS:
───────────────────────────────────────────────
Files Changed: X
Lines Changed: +XXX -XXX

Type Diversity: <Single | Multiple>
Scope Diversity: <Single | Multiple>
Logical Cohesion: <High | Medium | Low>

ATOMICITY CHECKS:
───────────────────────────────────────────────
✓ Single logical purpose
✓ Related files only
✓ Same change type
✓ Same scope
✓ Interdependent changes
✓ Complete unit
✓ Can be reverted independently

OR

✗ Multiple purposes detected
✗ Unrelated files mixed
✗ Multiple change types
✗ Multiple scopes
✗ Independent changes
✗ Incomplete without splits

REASONING:
───────────────────────────────────────────────
<detailed explanation>

If ATOMIC:
  All changes implement [specific feature/fix].
  Files work together and depend on each other.
  Single commit tells a clear, focused story.

If SHOULD SPLIT:
  Changes address multiple concerns:
    1. <concern 1>
    2. <concern 2>
    3. <concern 3>

  Each concern should be a separate commit.

SPLITTING RECOMMENDATIONS:
───────────────────────────────────────────────
<if should split>

Recommended Commits:

Commit 1: <type>(<scope>): <description>
  Files: X files
  Purpose: <specific purpose>
  Files:
    - file1.js
    - file2.js
  Lines: +XX -YY

Commit 2: <type>(<scope>): <description>
  Files: X files
  Purpose: <specific purpose>
  Files:
    - file3.js
    - file4.js
  Lines: +XX -YY

BENEFITS OF SPLITTING:
───────────────────────────────────────────────
<if should split>
- Better code review (focused changes)
- Easier to revert individual features
- Clearer git history
- Better bisecting for bugs
- Easier cherry-picking

RECOMMENDATION:
───────────────────────────────────────────────
<specific actionable recommendation>

═══════════════════════════════════════════════
```

## Detailed Atomicity Rules

### Rule 1: Single Purpose Test
**Question:** Can you describe ALL changes in one sentence?

**Atomic Examples:**
- "Add OAuth authentication"
- "Fix null pointer in user endpoint"
- "Refactor date utility functions"

**Non-Atomic Examples:**
- "Add OAuth and fix login bug and update README"
- "Implement payment and refactor utils and add tests"

### Rule 2: Type Consistency
**Atomic:**
- All files are "feat" type
- All files are "fix" type
- All files are "refactor" type

**Non-Atomic:**
- Mix of feat + fix
- Mix of refactor + feat
- Mix of docs + code changes (exception: docs can accompany code)

### Rule 3: Scope Consistency
**Atomic:**
- All changes in "auth" module
- All changes in "api" module
- All changes in "ui/components"

**Non-Atomic:**
- Changes in auth + api + ui
- Changes in multiple unrelated modules

### Rule 4: Revert Independence
**Test:** If reverted, does it break unrelated functionality?

**Atomic:**
- Can be reverted without breaking other features
- Forms a complete, self-contained unit

**Non-Atomic:**
- Reverting breaks unrelated features
- Mixes independent changes

### Rule 5: Review Simplicity
**Atomic:**
- Reviewer can focus on one logical change
- Clear what and why
- Single story

**Non-Atomic:**
- Reviewer must context-switch between multiple concerns
- Multiple stories mixed together

## File Count Guidelines

**Generally Atomic:**
- 1-5 files: Usually focused
- 5-10 files: Check cohesion carefully
- 10-15 files: Likely needs splitting unless tightly coupled

**Usually Non-Atomic:**
- 15+ files: Almost always should split
- 20+ files: Definitely split

**Exceptions:**
- Large refactoring may touch many files atomically
- Package updates may affect many files atomically
- Renaming across project may touch many files atomically

## Edge Cases

### Case 1: Feature + Tests
**Atomic?** Usually YES
- Tests directly validate the feature code
- They tell the same story
- Can be reverted together

**Example:**
```
feat(auth): implement OAuth authentication
- 5 implementation files
- 2 test files
→ ATOMIC (7 files, same feature)
```

### Case 2: Feature + Documentation
**Atomic?** DEPENDS
- If docs describe the feature: YES
- If docs are unrelated updates: NO

**Example:**
```
feat(auth): add OAuth support
- 5 auth files
- 1 auth documentation file
→ ATOMIC (documents the feature)

vs.

feat(auth): add OAuth support
- 5 auth files
- README general update
→ NON-ATOMIC (split docs)
```

### Case 3: Refactoring + New Feature
**Atomic?** NO
- Refactoring should be separate
- Makes review harder
- Mixing concerns

**Example:**
```
Changes:
- Refactor utils (3 files)
- Add new payment feature (5 files)
→ NON-ATOMIC

Split:
1. refactor(utils): simplify utility functions
2. feat(payments): add Stripe integration
```

### Case 4: Multiple Small Fixes
**Atomic?** DEPENDS
- If all in same module: MAYBE
- If unrelated: NO

**Example:**
```
fix(auth): resolve three auth-related bugs
- All in auth module
- All are fixes
- Related to each other
→ ATOMIC

vs.

- Fix auth bug
- Fix API bug
- Fix UI bug
→ NON-ATOMIC (different scopes)
```

## Output Format

Return:
- Atomicity status (ATOMIC or SHOULD SPLIT)
- Detailed analysis and reasoning
- Atomicity checks (passed/failed)
- Splitting recommendations if needed
- Benefits explanation
- Specific recommendation

## Error Handling

**No changes:**
```
NO CHANGES TO ASSESS
Working tree is clean.
```

**Single file change:**
```
ATOMIC (Single File)
One file changed: <filename>
Automatically atomic.
```

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Determine if /commit or /commit-split should be used
2. Warn users about non-atomic changes
3. Provide splitting guidance
4. Educate users on atomic commit benefits

## Usage Example

```bash
# Agent checks atomicity before committing
# User: "commit my changes"
# Agent: Invokes assess-atomicity
# Operation: Returns "SHOULD SPLIT"
# Agent: "Your changes should be split. Run /commit-review"
```

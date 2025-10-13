---
description: Review staged changes and recommend commit strategy for atomic commits
allowed-tools: Bash(git:*)
---

# Commit Review - Analyze Changes for Atomic Commits

Review your staged or unstaged changes and receive recommendations on whether to create a single commit or split into multiple atomic commits.

## Overview

The `/commit-review` command provides comprehensive change analysis by orchestrating multiple analytical skills to determine whether your changes should be committed as one atomic commit or split into multiple focused commits.

### Skills Orchestrated

This command coordinates:

1. **commit-error-handling** - Repository state validation
   - Operation: `/commit-error-handling diagnose-issues`
   - Ensures repository is ready for analysis

2. **commit-analysis** - Multi-dimensional change analysis
   - Operation: `/commit-analysis analyze`
   - Detects: types, scopes, file changes, atomicity
   - Provides: Comprehensive change breakdown

3. **atomic-commit** - Splitting analysis
   - Operations:
     - `/atomic-commit analyze` - Determine if should split
     - `/atomic-commit group strategy:type` - Group files by type
     - `/atomic-commit suggest` - Generate commit breakdown
   - Provides: Detailed splitting recommendations

4. **message-generation** - Preview commit messages
   - Operation: `/message-generation complete`
   - Generates: Suggested messages for each commit group

5. **history-analysis** (optional) - Project convention awareness
   - Operation: `/history-analysis analyze-style`
   - Ensures: Recommendations match project style

### Workflow Integration

After `/commit-review` shows recommendations:

**If single commit recommended**:
→ Use `/commit` to create the commit

**If split recommended**:
→ Use `/commit-split` for interactive splitting
→ OR use `/atomic-commit interactive` for granular control
→ OR manually commit each group

### For Granular Control

Analyze specific aspects independently:
- `/commit-analysis detect-type` - Just classify change types
- `/commit-analysis assess-atomicity` - Just check atomicity
- `/atomic-commit group` - Just group files
- `/atomic-commit suggest` - Just get commit suggestions

## Usage

```bash
/commit-review              # Review all changes (staged and unstaged)
```

## What is an Atomic Commit?

An atomic commit is a single, focused commit that:
- Contains one logical change
- Can be reverted independently without breaking other functionality
- Has all tests passing after the commit
- Is self-contained and complete
- Has a clear, single purpose

**Good Atomic Commits:**
- Add authentication feature (all auth files together)
- Fix login bug (only the fix, not other changes)
- Update dependencies (package updates together)

**Bad Non-Atomic Commits:**
- Add feature + fix unrelated bug + update docs
- Refactor + add new functionality
- Mix of formatting changes and logic changes

## Complete Analysis Workflow

```
User: /commit-review
         ↓
    ┌────────────────────────────────┐
    │ 1. Validate Repository         │
    │ /commit-error-handling         │
    │ diagnose-issues                │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 2. Analyze All Changes         │
    │ /commit-analysis analyze       │
    │ - Detect types                 │
    │ - Identify scopes              │
    │ - Count files/lines            │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 3. Assess Atomicity            │
    │ /atomic-commit analyze         │
    └────────────┬───────────────────┘
                 ↓
           ┌─────┴──────┐
           │ Should     │
           │ Split?     │
           └─────┬──────┘
                 │
        ┌────────┴────────┐
        │                 │
       YES               NO
        ↓                 ↓
┌───────────────┐  ┌──────────────────┐
│ 4a. Group     │  │ 4b. Recommend    │
│ Files         │  │ Single Commit    │
│ /atomic-      │  │                  │
│ commit group  │  │ → Use /commit    │
└───────┬───────┘  └──────────────────┘
        ↓
┌───────────────────┐
│ 5a. Generate      │
│ Suggestions       │
│ /atomic-commit    │
│ suggest           │
│                   │
│ For each group:   │
│ /message-         │
│ generation        │
│ complete          │
└─────────┬─────────┘
          ↓
┌─────────────────────────────┐
│ 6a. Present Plan            │
│ - Commit breakdown          │
│ - Suggested messages        │
│ - File groups               │
│                             │
│ → Use /commit-split         │
└─────────────────────────────┘
```

## Process

### Step 1: Repository Validation

**Orchestrates**: `/commit-error-handling diagnose-issues`

Before analyzing changes, verify:
- Valid git repository
- Changes present (staged or unstaged)
- No merge conflicts blocking analysis
- Repository not in problematic state

This prevents analysis of invalid states.

**For detailed diagnostics**: `/commit-error-handling diagnose-issues`

```bash
git rev-parse --git-dir 2>/dev/null
git status --short
```

If not a git repo, show error and exit.

### Step 2: Analyze All Changes

**Orchestrates**: `/commit-analysis analyze`

Performs multi-dimensional analysis:

**File-Level Analysis**:
- Type detection (feat, fix, docs, refactor, test, chore, style, perf, ci)
- Scope identification (auth, api, ui, database, etc.)
- Line change statistics (+/- counts)

**Change-Level Analysis**:
- Total files modified
- Insertions and deletions
- Change complexity assessment

**Atomicity Assessment**:
- Single concern vs. multiple concerns
- Related vs. unrelated changes
- Interdependencies between files

**Grouping Strategy**:
- Type-based grouping (all feat together)
- Scope-based grouping (all auth together)
- Feature-based grouping (implementation + tests)

Check both staged and unstaged changes:

```bash
# Get status
git status --short

# Get staged changes
git diff --cached --stat
git diff --cached

# Get unstaged changes
git diff --stat
git diff

# Count files by status
git status --short | wc -l
```

**Type Detection Rules**:

Analyze the diff output to categorize each file by its primary change type:

1. **feat** (New Feature):
   - New files being added
   - New functions/classes/exports
   - New functionality in existing files
   - Look for: `export function`, `export class`, `export const`, new files

2. **fix** (Bug Fix):
   - Error handling additions
   - Null/undefined checks
   - Validation fixes
   - Look for: `if (!`, `try/catch`, `throw`, `error`, `null`, `undefined`

3. **refactor** (Code Restructuring):
   - Variable/function renaming
   - Code extraction or reorganization
   - Look for: similar logic moved, renamed identifiers

4. **docs** (Documentation):
   - README.md changes, documentation files (*.md), JSDoc additions
   - Look for: file extensions `.md`, comment blocks

5. **style** (Formatting):
   - Whitespace changes only, indentation fixes
   - Look for: only whitespace diffs, no logic changes

6. **test** (Tests):
   - Test file changes (*.test.js, *.spec.js, *_test.py)
   - Look for: `test(`, `describe(`, `it(`, `expect(`, file patterns

7. **chore** (Build/Config):
   - package.json dependencies, build configuration
   - Look for: package.json, *.config.js, .github/workflows

8. **perf** (Performance):
   - Optimization changes, caching implementations
   - Look for: `cache`, `memoize`, performance-related comments

9. **ci** (CI/CD):
   - GitHub Actions workflows, GitLab CI configs
   - Look for: .github/workflows, .gitlab-ci.yml

**For granular analysis**:
- `/commit-analysis detect-type file:path` - Type for specific file
- `/commit-analysis identify-scope file:path` - Scope for specific file
- `/commit-analysis file-stats` - Just statistics

### Step 3: Determine Split Strategy

**Orchestrates**: `/atomic-commit analyze`

Evaluates whether changes should be split:

**Split Criteria**:
- Multiple types present (feat + fix + docs)
- Multiple scopes (auth + api + ui)
- Too many files (10+ of different types)
- Mixed concerns (feature + unrelated refactor)

**Keep Together Criteria**:
- Single type and scope
- All files serve same purpose
- Changes are interdependent
- Reasonable file count (≤10)

**Atomicity Scoring**:
- atomic=true (single commit) → Proceed to `/commit`
- atomic=false (split needed) → Continue to grouping

**For direct splitting analysis**: `/atomic-commit analyze`

### Step 4: Group Related Files

**Orchestrates**: `/atomic-commit group strategy:type`

Groups files into logical commit groups:

**Grouping Strategies**:

1. **Type-Based** (default):
   - feat files → Commit 1
   - fix files → Commit 2
   - docs files → Commit 3
   - test files → Commit 4

2. **Scope-Based**:
   - auth files → Commit 1
   - api files → Commit 2
   - ui files → Commit 3

3. **Feature-Based**:
   - Implementation + Tests → Commit 1
   - Documentation → Commit 2

Create a mapping of files to their change types:

```
feat:
  - src/auth/oauth.js
  - src/auth/providers.js
  - src/auth/middleware.js

test:
  - tests/auth.test.js
  - tests/oauth.test.js

docs:
  - README.md

refactor:
  - src/utils.js
  - src/helpers.js
```

**For custom grouping**:
- `/atomic-commit group strategy:scope` - Group by module
- `/atomic-commit group strategy:feature` - Group by feature

### Step 5: Generate Commit Recommendations

**Orchestrates**:
- `/atomic-commit suggest` - Create commit breakdown
- `/message-generation complete` (for each group) - Generate messages

For each group, generates:
- **Commit message**: Conventional commits format
- **File list**: All files in the group
- **Change summary**: What the commit does
- **Line statistics**: Insertions/deletions

**Message Generation Uses**:
- Detected type (feat, fix, etc.)
- Identified scope (auth, api, etc.)
- Change analysis (what was actually done)
- Project conventions (from history-analysis)

**For custom messages**:
- `/message-generation subject` - Just subject line
- `/message-generation validate` - Check message format

### Step 6: Present Analysis Results

## Analysis Output Format

### Split Recommendation

When multiple concerns are detected:

```
COMMIT REVIEW ANALYSIS
═══════════════════════════════════════════════
Data from: /commit-analysis analyze
           /atomic-commit analyze

RECOMMENDATION: SPLIT INTO ATOMIC COMMITS

Your changes cover multiple concerns:
 ⚠ Multiple types: feat, test, refactor, docs
 ⚠ Multiple scopes or unrelated changes
 ⚠ Better split for clear history

──────────────────────────────────────────────
CURRENT CHANGES SUMMARY:
Data from: /commit-analysis analyze
────────────────────────────────────────────
Total Files: 12
Insertions: 847 (+)
Deletions: 234 (-)

CHANGE TYPE BREAKDOWN:
────────────────────────────────────────────
FEAT (5 files) - New authentication system
  M src/auth/oauth.js (+156 lines)
  M src/auth/providers.js (+89 lines)
  M src/auth/middleware.js (+73 lines)
  M src/auth/config.js (+45 lines)
  M src/auth/index.js (+23 lines)

TEST (2 files) - Authentication tests
  M tests/auth.test.js (+142 lines)
  M tests/oauth.test.js (+98 lines)

REFACTOR (3 files) - Code cleanup
  M src/utils.js (+45 -67 lines)
  M src/helpers.js (+34 -52 lines)
  M src/validators.js (+12 -8 lines)

DOCS (2 files) - Documentation updates
  M README.md (+156 -42 lines)
  M docs/authentication.md (+74 lines)

──────────────────────────────────────────────
SPLITTING PLAN
Generated by: /atomic-commit suggest
Messages from: /message-generation complete

Commit 1 (feat): 5 files, 386 lines
  feat(auth): implement OAuth authentication system

  - Add OAuth2 authentication flow
  - Implement provider support for Google and GitHub
  - Add authentication middleware
  - Include configuration management

  Files:
    src/auth/oauth.js
    src/auth/providers.js
    src/auth/middleware.js
    src/auth/config.js
    src/auth/index.js

────────────────────────────────────────────

Commit 2 (test): 2 files, 240 lines
  test(auth): add comprehensive OAuth authentication tests

  - Add unit tests for OAuth flow
  - Add integration tests for providers
  - Achieve 95% coverage for auth module

  Files:
    tests/auth.test.js
    tests/oauth.test.js

────────────────────────────────────────────

Commit 3 (refactor): 3 files, 24 lines
  refactor: simplify utility functions and improve validation

  - Simplify date/time utilities
  - Improve helper function clarity
  - Enhance validator logic

  Files:
    src/utils.js
    src/helpers.js
    src/validators.js

────────────────────────────────────────────

Commit 4 (docs): 2 files, 188 lines
  docs: add OAuth authentication guide

  - Update README with authentication setup
  - Add detailed authentication documentation
  - Include usage examples

  Files:
    README.md
    docs/authentication.md

──────────────────────────────────────────────

NEXT STEPS:
→ Interactive splitting: /commit-split
→ Granular control: /atomic-commit interactive
→ Manual commits: Use /commit for each group

WHY SPLIT COMMITS?
Atomic commits provide:
 ✓ Better history browsing (each commit tells a story)
 ✓ Easier code review (reviewers see logical changes)
 ✓ Safer reverts (revert one feature without breaking others)
 ✓ Clearer blame/annotate (understand why changes were made)
 ✓ Better bisecting (find bugs by commit)
═══════════════════════════════════════════════
```

### Single Commit Recommendation

When changes form a cohesive unit:

```
COMMIT REVIEW ANALYSIS
═══════════════════════════════════════════════
Data from: /commit-analysis analyze

RECOMMENDATION: SINGLE ATOMIC COMMIT ✓

Your changes form a cohesive unit:
 ✓ Single type: feat
 ✓ Single scope: auth
 ✓ Logical unit: OAuth authentication
 ✓ Reasonable size: 5 files, 386 lines

──────────────────────────────────────────────
CURRENT CHANGES SUMMARY:
Data from: /commit-analysis analyze
────────────────────────────────────────────
Total Files: 5
Insertions: 386 (+)
Deletions: 0 (-)

CHANGE TYPE BREAKDOWN:
────────────────────────────────────────────
FEAT (5 files) - Complete authentication feature
  M src/auth/oauth.js
  M src/auth/providers.js
  M src/auth/middleware.js
  M src/auth/config.js
  M src/auth/index.js

──────────────────────────────────────────────
SUGGESTED COMMIT MESSAGE
Generated by: /message-generation complete

feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support for Google and GitHub
- Add authentication middleware
- Include configuration management
──────────────────────────────────────────────

ATOMICITY CHECK: PASSED
 ✓ All files relate to a single feature (auth)
 ✓ Changes are cohesive and interdependent
 ✓ Single commit tells a clear story
 ✓ Can be reverted as a complete unit

NEXT STEPS:
→ Create commit: /commit
→ Pre-validate: /commit-best-practices check-pre-commit
═══════════════════════════════════════════════
```

## Error Handling

**Not a git repository:**
```
ERROR: Not a git repository
Run: git init
```

**No changes to review:**
```
NO CHANGES TO REVIEW

Your working tree is clean.
Make some changes, then run /commit-review again.
```

**All changes already committed:**
```
ALL CHANGES COMMITTED

Great job! Your working tree is clean.
Run git log to see your commits.
```

## Tips for Atomic Commits

**DO:**
- Group related changes together
- Keep features separate from fixes
- Keep refactoring separate from new features
- Include tests with the code they test (optional)
- Make each commit independently buildable

**DON'T:**
- Mix formatting changes with logic changes
- Combine multiple features in one commit
- Include unrelated bug fixes with features
- Make "WIP" or "misc changes" commits
- Bundle everything at the end of the day

## Examples

**Example 1: Mixed changes (needs splitting)**
```bash
/commit-review
# Shows: feat (3 files), fix (2 files), docs (1 file)
# Recommends: Split into 3 commits
# Next: /commit-split
```

**Example 2: Clean atomic change**
```bash
/commit-review
# Shows: fix (2 files) - all related to login bug
# Recommends: Single commit is appropriate
# Next: /commit
```

**Example 3: Large feature**
```bash
/commit-review
# Shows: feat (15 files) - authentication system
# Recommends: Consider splitting by module/component
# Next: /commit-split or careful manual commits
```

## Related Skills and Commands

### Analytical Skills Used

- **commit-analysis**: `/commit-analysis` - Detailed change analysis
  - Operations: analyze, detect-type, identify-scope, assess-atomicity, file-stats
  - Purpose: Multi-dimensional change analysis and type/scope detection

- **atomic-commit**: `/atomic-commit` - Splitting analysis and grouping
  - Operations: analyze, group, suggest, sequence, interactive
  - Purpose: Determine if changes should split and generate commit groups

- **history-analysis**: `/history-analysis` - Project convention analysis
  - Operations: analyze-style, recent-patterns, common-scopes
  - Purpose: Learn project conventions to inform recommendations

### Execution Skills Referenced

- **message-generation**: `/message-generation` - Message creation
  - Operations: complete, subject, body, validate
  - Purpose: Generate conventional commit messages for each group

- **commit-best-practices**: `/commit-best-practices` - Validation
  - Operations: check-pre-commit, workflow-tips, validate-message
  - Purpose: Ensure commits follow best practices

- **commit-error-handling**: `/commit-error-handling` - Error diagnosis
  - Operations: diagnose-issues, recover, clean-state
  - Purpose: Validate repository state before analysis

### Related Commands

- `/commit` - Create single atomic commit
  - Use when: Review recommends single commit
  - Purpose: Execute the commit with generated message

- `/commit-split` - Interactively split into atomic commits
  - Use when: Review recommends splitting
  - Purpose: Interactive file-by-file commit creation

### Workflow Paths

```
/commit-review (analysis)
    ↓
    ├─ Single commit? → /commit (execution)
    │
    └─ Multiple commits? → /commit-split (execution)
                        OR /atomic-commit interactive (granular control)
```

### For Power Users

Access granular operations directly:

**Analysis Only**:
- `/commit-analysis detect-type` - Classify file types
- `/commit-analysis identify-scope` - Extract scopes
- `/commit-analysis assess-atomicity` - Check if should split

**Grouping Only**:
- `/atomic-commit group strategy:type` - Group by type
- `/atomic-commit group strategy:scope` - Group by scope
- `/atomic-commit group strategy:feature` - Group by feature

**Message Generation Only**:
- `/message-generation complete` - Generate full message
- `/message-generation subject` - Just subject line
- `/message-generation validate message:"text"` - Validate format

### Documentation References

- **Atomic Commits Guide**: See `/commit-best-practices workflow-tips`
- **Skill Architecture**: See `.claude/docs/SKILL_ARCHITECTURE.md`
- **Agent Reference**: See `agents/commit-assistant.md`
- **Command List**: See plugin README.md for all available commands

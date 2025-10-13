---
description: Split large commits into atomic commits through interactive guidance
allowed-tools: Bash(git:*)
---

# Commit Split - Interactive Atomic Commit Creation

## Overview

The `/commit-split` command provides an interactive workflow that orchestrates multiple skills to help you split large commits into focused, atomic commits. Each atomic commit represents one logical change that can be independently reviewed, tested, and reverted.

### Skills Orchestrated

This command coordinates a complete execution workflow:

1. **commit-error-handling** - Pre-flight validation
   - Operation: `/commit-error-handling diagnose-issues`
   - Ensures: Repository ready for splitting

2. **commit-analysis** - Change understanding
   - Operation: `/commit-analysis analyze`
   - Provides: Type, scope, and file analysis for grouping

3. **atomic-commit** - Core splitting logic (PRIMARY)
   - Operation: `/atomic-commit interactive`
   - Provides: File grouping, suggestions, sequence generation
   - This skill contains the core splitting algorithms

4. **message-generation** - Message creation
   - Operation: `/message-generation complete` (per commit)
   - Generates: Conventional commit message for each group

5. **commit-best-practices** - Quality assurance
   - Operation: `/commit-best-practices check-pre-commit` (optional)
   - Operation: `/commit-best-practices review-commit` (after each)
   - Validates: Tests pass, quality maintained

6. **history-analysis** - Project awareness
   - Operation: `/history-analysis analyze-style` (cached)
   - Ensures: Messages match project conventions

### Interactive Workflow

The `/commit-split` command provides a guided experience:

```
1. Analyze changes → Show plan
2. Group files → Present groups
3. For each group:
   - Show files and changes
   - Generate message
   - Get user approval
   - Create commit
   - Review quality
4. Final summary
```

### Alternative Workflows

**For more control**:
- `/atomic-commit interactive` - Same workflow, skill-level access
- `/atomic-commit sequence` - Generate script to execute
- Manual: Use `/commit` for each group after reviewing

**For just analysis**:
- `/commit-review` - Analysis without execution
- `/atomic-commit suggest` - Get suggestions only

## Usage

```bash
/commit-split               # Start interactive commit splitting
```

## What This Does

This command helps you:
1. Validate repository state and analyze all changes
2. Group related files by change type and scope
3. Generate conventional commit messages for each group
4. Create multiple focused commits interactively
5. Ensure each commit is atomic and well-documented

## Complete Interactive Workflow

```
User: /commit-split
         ↓
┌─────────────────────────────────┐
│ Pre-Flight & Analysis           │
│ /commit-error-handling          │
│ /commit-analysis                │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│ Generate Splitting Plan         │
│ /atomic-commit suggest          │
│   → groups files                │
│   → calls /message-generation   │
│       for each group            │
└────────────┬────────────────────┘
             ↓
┌─────────────────────────────────┐
│ Present Plan & Confirm          │
│ User reviews:                   │
│ - N commits                     │
│ - Files in each                 │
│ - Suggested messages            │
└────────────┬────────────────────┘
             ↓
             ┌────────┐
             │ Ready? │
             └───┬────┘
                 │
          ┌──────┴──────┐
         NO            YES
          ↓              ↓
      [Abort]    ┌──────────────┐
                 │ For Each     │
                 │ Group (1-N)  │
                 └──────┬───────┘
                        ↓
          ┌─────────────────────────────┐
          │ Show Group Details          │
          │ - Files                     │
          │ - Message                   │
          │ - Changes                   │
          └──────────┬──────────────────┘
                     ↓
          ┌─────────────────────────────┐
          │ Get User Action             │
          │ 1. Create                   │
          │ 2. Edit                     │
          │ 3. Skip                     │
          │ 4. Abort                    │
          └──────────┬──────────────────┘
                     ↓
              ┌──────┴──────┐
         Create          Skip/Abort
              ↓              ↓
    ┌──────────────────┐    │
    │ Pre-Commit Check │    │
    │ (optional)       │    │
    │ /commit-best-    │    │
    │ practices        │    │
    └────────┬─────────┘    │
             ↓              │
    ┌──────────────────┐    │
    │ git add <files>  │    │
    │ git commit -m "" │    │
    └────────┬─────────┘    │
             ↓              │
    ┌──────────────────┐    │
    │ Post-Commit      │    │
    │ Review           │    │
    │ /commit-best-    │    │
    │ practices        │    │
    └────────┬─────────┘    │
             ↓              │
    ┌──────────────────┐    │
    │ Show Progress    │    │
    │ Continue?        │    │
    └────────┬─────────┘    │
             │              │
             └──────────────┘
                     ↓
          ┌─────────────────────────────┐
          │ Final Summary               │
          │ - List commits created      │
          │ - Quality scores            │
          │ - Remaining changes         │
          │ - Verification commands     │
          └─────────────────────────────┘
```

## Process

### Step 1: Validate Repository and Analyze Changes

**Orchestrates**:
1. `/commit-error-handling diagnose-issues` - Validate state
2. `/commit-analysis analyze` - Understand changes

**Pre-Flight Checks**:
```bash
# Verify git repository
git rev-parse --git-dir 2>/dev/null
```

If not a git repo, show error and exit.

**Change Analysis**:
```bash
# Get all changes
git status --short

# Get detailed diff
git diff HEAD

# Count changes
git status --short | wc -l
```

**Analysis Output**:
- Total files and line changes
- Type detection for each file
- Scope identification
- Initial grouping strategy

This provides the data for intelligent splitting.

**Direct access**:
- `/commit-error-handling diagnose-issues` - Just validation
- `/commit-analysis analyze` - Just analysis

If no changes, show message and exit.

### Step 2: Generate Splitting Plan

**Orchestrates**: `/atomic-commit suggest`

This operation:
1. **Groups related files**:
   - Strategy: Type-based (feat, fix, docs, test)
   - Alternative strategies: scope-based, feature-based

2. **Generates commit messages** for each group:
   - Uses: `/message-generation complete`
   - Format: Conventional commits
   - Style: Matches project conventions (from `/history-analysis`)

3. **Creates execution plan**:
   - Commit order (dependencies respected)
   - File → commit mapping
   - Estimated changes per commit

**Plan Structure**:
```
Group 1: feat(auth) - 5 files, +386 lines
  feat(auth): implement OAuth authentication system

Group 2: test(auth) - 2 files, +240 lines
  test(auth): add comprehensive OAuth tests

Group 3: docs - 1 file, +128 lines
  docs: add OAuth authentication guide
```

**Direct access**:
- `/atomic-commit group` - Just grouping
- `/atomic-commit suggest` - Suggestions only
- `/atomic-commit sequence` - Executable script

### Step 3: Present Splitting Plan

Shows the complete plan generated by skill orchestration:

```
INTERACTIVE COMMIT SPLITTING
═════════════════════════════════════════════

I've analyzed your changes and identified 4 logical
commits to create. I'll guide you through each one.

SPLITTING PLAN:
────────────────────────────────────────────

📦 Commit 1: Authentication Feature
   Type: feat(auth)
   Files: 5 files
   Lines: +386 -0

📦 Commit 2: Authentication Tests
   Type: test(auth)
   Files: 2 files
   Lines: +240 -0

📦 Commit 3: Utility Refactoring
   Type: refactor
   Files: 2 files
   Lines: +79 -119

📦 Commit 4: Documentation Updates
   Type: docs
   Files: 2 files
   Lines: +230 -42

════════════════════════════════════════════

Let's create these commits one by one.
You'll review each before it's created.

Ready to start? (y/n)
```

User reviews and confirms before any commits are created.

This transparency allows users to understand the splitting strategy before execution.

### Step 4: Create Commits Iteratively

For each commit group, orchestrates:

**Per-Commit Workflow**:
```
For each group (1 to N):
  ↓
  1. Show group details
  2. Present generated message
     (from /message-generation complete)
  ↓
  3. Get user action:
     - Create with message
     - Edit message
     - Skip group
     - Abort
  ↓
  4. If creating:
     a. Stage files: git add <files>
     b. Validate (optional):
        /commit-best-practices check-pre-commit
     c. Create commit: git commit -m "message"
     d. Review quality:
        /commit-best-practices review-commit
  ↓
  5. Show progress
  6. Continue to next group
```

**User Control Points**:
- Review each commit before creation
- Edit any generated message
- Skip groups to commit separately
- Abort if plan needs adjustment

**Quality Assurance** (optional, configurable):
- Pre-commit checks before each commit
- Post-commit review after each commit
- Rollback guidance if issues found

#### Detailed Commit Creation Loop

**For each group:**

1. **Show Group Details**

```
═══════════════════════════════════════════
COMMIT 1 of 4: Authentication Feature
═══════════════════════════════════════════

FILES TO COMMIT (5 files):
────────────────────────────────────────────
 M src/auth/oauth.js                  +156
 M src/auth/providers.js              +89
 M src/auth/middleware.js             +73
 M src/auth/config.js                 +45
 M src/auth/index.js                  +23

CHANGES SUMMARY:
────────────────────────────────────────────
- Implements OAuth2 authentication flow
- Adds provider support (Google, GitHub)
- Includes authentication middleware
- Adds configuration management
- Exports unified auth interface

PROPOSED COMMIT MESSAGE:
────────────────────────────────────────────
feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support for Google and GitHub
- Add authentication middleware
- Include configuration management

════════════════════════════════════════════

What would you like to do?

1. Create commit with this message (recommended)
2. Edit the message
3. Skip this group
4. Abort splitting

Enter choice (1/2/3/4):
```

2. **Handle User Choice**

**Choice 1: Create commit**
```bash
# Stage only the files in this group
git add src/auth/oauth.js src/auth/providers.js src/auth/middleware.js src/auth/config.js src/auth/index.js

# Create the commit
git commit -m "feat(auth): implement OAuth authentication system

- Add OAuth2 authentication flow
- Implement provider support for Google and GitHub
- Add authentication middleware
- Include configuration management"

# Show success
echo "✅ Commit 1 created successfully"
git log -1 --oneline
```

**Choice 2: Edit message**
Prompt user for new message:
```
Enter your commit message:
(Use conventional commits format: <type>(<scope>): <subject>)

> _
```

Then create commit with user's message.

**Choice 3: Skip**
Skip this group, move to next.

**Choice 4: Abort**
Exit without creating any more commits. Already created commits remain.

3. **Show Progress**

After each commit:
```
PROGRESS: 1 of 4 commits created

✅ Commit 1: feat(auth) - abc1234

Remaining commits:
 📦 Commit 2: test(auth) - 2 files
 📦 Commit 3: refactor - 2 files
 📦 Commit 4: docs - 2 files

Continue to next commit? (y/n)
```

### Step 5: Complete and Verify

After all commits created:

**Final Validation**:
- List all created commits
- Show remaining uncommitted changes (if any)
- Provide git commands to verify:
  - `git log --oneline -N`
  - `git log -p -N`

**Quality Report**:
For each commit created:
- Commit hash
- Message
- Quality score (from `/commit-best-practices review-commit`)

**Next Steps Guidance**:
- Run full test suite
- Push commits
- Create pull request
- Use `/commit-best-practices revert-guidance` if needed

**Final Summary Display**:

```
═══════════════════════════════════════════
COMMIT SPLITTING COMPLETE
═══════════════════════════════════════════

CREATED COMMITS:
────────────────────────────────────────────
✅ abc1234 - feat(auth): implement OAuth authentication system
✅ def5678 - test(auth): add comprehensive OAuth tests
✅ ghi9012 - refactor: simplify utility functions
✅ jkl3456 - docs: add OAuth authentication guide

SUMMARY:
────────────────────────────────────────────
Total commits created: 4
Files committed: 12
Remaining changes: 0

═══════════════════════════════════════════

VERIFY YOUR COMMITS:
────────────────────────────────────────────
git log --oneline -4
git log -p -4

NEXT STEPS:
────────────────────────────────────────────
✓ Run tests to verify everything works
✓ Push commits: git push
✓ Create pull request if needed

═══════════════════════════════════════════

Great job creating atomic commits!
Your git history is now clean and logical.
```

### Alternative: If Skipped Groups

If user skipped some groups, show remaining files:

```
REMAINING UNCOMMITTED CHANGES:
────────────────────────────────────────────
 M src/utils.js
 M README.md

These files were skipped during splitting.
Run /commit to commit them, or /commit-split to try again.
```

## Smart Grouping Strategies

The `/atomic-commit` skill implements multiple grouping strategies:

### Strategy 1: Type-Based Grouping

Group by change type first:
- All `feat` changes together (if same scope)
- All `fix` changes together
- All `refactor` changes together
- All `docs` changes together
- All `test` changes together

### Strategy 2: Scope-Based Grouping

Group by module/component:
- All `auth` changes together
- All `api` changes together
- All `ui` changes together

### Strategy 3: Feature-Based Grouping

Group by feature completion:
- Implementation + Tests together
- Feature code + Documentation together

**Recommendation**: Use Type-Based for most cases, Scope-Based for large features.

**Direct access**: `/atomic-commit group strategy:<type|scope|feature>`

## Commit Message Generation

For each group, the `/message-generation` skill generates a message:

**Template:**
```
<type>(<scope>): <subject>

<body>
```

**Subject Generation:**
- Analyze primary change in the files
- Use active voice, imperative mood
- Keep under 50 characters
- Example: "implement OAuth authentication system"

**Body Generation (bullet points):**
- List major changes in the group
- Keep bullets concise (under 72 chars)
- Focus on what and why, not how
- Example:
  ```
  - Add OAuth2 authentication flow
  - Implement provider support for Google and GitHub
  - Include authentication middleware
  ```

**Direct access**: `/message-generation complete files:"<files>" type:<type> scope:<scope>`

## Edge Cases

### Case 1: Single File, Multiple Concerns

If one file has multiple unrelated changes:

```
WARNING: Complex Changes Detected
────────────────────────────────────────────
File: src/app.js

This file contains multiple types of changes:
- New feature: OAuth integration
- Bug fix: Memory leak fix
- Refactor: Code cleanup

RECOMMENDATION:
Use git add -p to stage changes interactively,
or manually split the file changes.

Cannot automatically split this file.
```

### Case 2: Interdependent Changes

If changes must stay together:

```
NOTE: Interdependent Changes
────────────────────────────────────────────
These files must be committed together:
- src/auth/oauth.js (defines function)
- src/auth/index.js (exports function)

Keeping them in the same commit: Commit 1
```

### Case 3: Very Large Number of Files

If 20+ files:

```
LARGE CHANGE SET DETECTED
────────────────────────────────────────────
You have 47 files changed.

This is a lot! Consider:

1. Splitting by module/feature first
2. Creating multiple PRs
3. Committing incrementally as you work

Would you like me to try splitting anyway? (y/n)
```

## Error Handling

**Not a git repository:**
```
ERROR: Not a git repository
Run: git init

(Detected by /commit-error-handling diagnose-issues)
```

**No changes to split:**
```
NO CHANGES TO SPLIT

Your working tree is clean.
Make some changes first, then run /commit-split.
```

**Commit creation failed:**
```
ERROR: Failed to create commit

<git error message>

This may happen if:
- Git user.name or user.email not configured
- Repository is in conflicted state
- Pre-commit hooks failed

Fix the issue and try again.

Use /commit-error-handling diagnose-issues for detailed diagnostics.
```

## Granular Control Options

### Option 1: Use atomic-commit Skill Directly

The `/commit-split` command is a wrapper around `/atomic-commit interactive`.

For equivalent functionality with more control:
```bash
/atomic-commit interactive
```

**Additional atomic-commit operations**:
- `/atomic-commit analyze` - Just check if should split
- `/atomic-commit group strategy:type` - Just group files
- `/atomic-commit suggest` - Just get suggestions
- `/atomic-commit sequence output:script` - Generate bash script

### Option 2: Generate Script and Execute

Generate an executable script:
```bash
/atomic-commit sequence output:script > split-commits.sh
chmod +x split-commits.sh
./split-commits.sh
```

This gives you a script you can review and modify before execution.

### Option 3: Manual with Guidance

Get the plan without execution:
```bash
/commit-review  # Get analysis and recommendations
/atomic-commit suggest  # Get specific suggestions
```

Then manually:
```bash
git add file1 file2 file3
/commit "feat(auth): add OAuth"

git add file4 file5
/commit "test(auth): add tests"
```

### Option 4: Analysis Only

Just understand your changes without committing:
```bash
/commit-review  # Full analysis
/commit-analysis analyze  # Just change analysis
/atomic-commit analyze  # Just atomicity check
```

## Tips

**Before Splitting:**
- Run `/commit-review` first to see the splitting plan
- Ensure all changes are related to work you want to commit
- Consider using `git stash` for truly unrelated changes

**During Splitting:**
- Review each proposed message carefully
- Edit messages if the generated ones aren't perfect
- Skip groups if you want to commit them separately
- Don't worry about making mistakes - commits can be amended

**After Splitting:**
- Run tests to verify everything still works
- Review commits with `git log -p`
- Use `git commit --amend` if you need to fix the last commit
- Push all commits together or create a PR

## Examples

**Example 1: Feature Development**
```
Files changed: 8
Groups: 3
- feat(payment): 5 files
- test(payment): 2 files
- docs: 1 file

Result: 3 clean atomic commits
```

**Example 2: Bug Fix with Refactoring**
```
Files changed: 4
Groups: 2
- fix(api): 2 files (the actual fix)
- refactor: 2 files (cleanup done while fixing)

Result: 2 separate commits (fix can be cherry-picked)
```

**Example 3: Mixed Changes**
```
Files changed: 15
Groups: 5
- feat(auth): 6 files
- feat(profile): 4 files
- fix(api): 2 files
- test: 2 files
- docs: 1 file

Result: 5 focused commits
```

## Best Practices

1. **Keep It Simple**: Don't overthink grouping
2. **Test Between Commits**: Each commit should work
3. **Review Messages**: Generated messages are suggestions
4. **Be Consistent**: Follow your team's commit conventions
5. **Document Why**: Use commit body for complex changes
6. **One Story Per Commit**: Each commit tells one story

## Related Skills and Commands

### Core Skill: atomic-commit

The `/commit-split` command is powered by the atomic-commit skill:

**Full Skill Access**: `/atomic-commit`
- `analyze` - Determine if should split
- `group` - Group related files
- `suggest` - Generate commit breakdown
- `sequence` - Create execution plan
- `interactive` - Full guided workflow (what /commit-split uses)

### Supporting Skills

**Analysis**:
- `/commit-analysis` - Change type/scope detection
- `/commit-error-handling` - Repository validation

**Message Generation**:
- `/message-generation` - Conventional commit messages
- `/history-analysis` - Project convention learning

**Quality Assurance**:
- `/commit-best-practices` - Validation and review

### Related Commands

**Analysis Phase**:
- `/commit-review` - Analyze and get recommendations (no execution)

**Execution Phase**:
- `/commit-split` - Interactive splitting (this command)
- `/commit` - Single atomic commit

### Complete Workflow

```
1. Analysis: /commit-review
   ↓ If split needed
2. Execution: /commit-split
   ↓ Creates N atomic commits
3. Verify: /commit-best-practices review-commit
```

### Documentation

- **Atomic Commits Guide**: `.claude/commands/commit-best-practices/workflow-tips.md`
- **Splitting Strategies**: `.claude/commands/atomic-commit/` skill documentation
- **Skill Architecture**: `.claude/docs/SKILL_ARCHITECTURE.md`
- **Agent Reference**: `.claude/agents/commit-assistant.md`

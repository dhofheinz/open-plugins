---
description: Create git commit with intelligent message generation using conventional commits format
argument-hint: [message]
allowed-tools: Bash(git:*)
---

# Intelligent Git Commit Assistant

Create well-formatted git commits with optional automatic message generation following conventional commits standards.

## Overview

The `/commit` command provides a simplified workflow that orchestrates multiple specialized skills to create intelligent, well-formatted commits following conventional commits standards.

### Skills Orchestrated

This command coordinates these granular skills:

1. **commit-error-handling** - Validates git repository state and checks for issues
   - Operation: `/commit-error-handling diagnose-issues`
   - Purpose: Ensure repository is in a clean state before committing

2. **commit-analysis** - Analyzes changes to determine type, scope, and atomicity
   - Operation: `/commit-analysis analyze`
   - Purpose: Understand what changes are being committed

3. **history-analysis** (optional) - Learns project commit conventions
   - Operation: `/history-analysis analyze-style`
   - Purpose: Match team's existing commit style

4. **commit-best-practices** - Validates commit readiness
   - Operation: `/commit-best-practices check-pre-commit`
   - Purpose: Ensure tests pass, no debug code, lint clean

5. **message-generation** - Generates conventional commit messages
   - Operation: `/message-generation complete`
   - Purpose: Create well-formatted conventional commit message

6. **atomic-commit** (conditional) - Suggests splitting if needed
   - Operation: `/atomic-commit analyze`
   - Purpose: Determine if changes should be split into multiple commits

### For Granular Control

If you need precise control over individual operations:
- Use `/commit-error-handling` for error diagnosis
- Use `/commit-analysis` for change analysis
- Use `/message-generation` for message generation
- Use `/atomic-commit` for commit splitting
- Use `/commit-best-practices` for validation
- Use `/history-analysis` for project conventions

See the commit-assistant agent for complete skill documentation.

## Usage

```bash
/commit                    # Analyze changes and generate commit message
/commit "feat: add login"  # Use provided message directly
```

## Complete Workflow

```
User: /commit [optional message]
         ↓
    ┌────────────────────────────────┐
    │ 1. Error Check                 │
    │ /commit-error-handling         │
    │ diagnose-issues                │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 2. Analyze Changes             │
    │ /commit-analysis analyze       │
    └────────────┬───────────────────┘
                 ↓
           ┌─────┴──────┐
           │ Atomic?    │
           └─────┬──────┘
                 │
        ┌────────┴────────┐
        │ NO              │ YES
        ↓                 ↓
┌───────────────┐  ┌──────────────────┐
│ Suggest Split │  │ Continue         │
│ /atomic-commit│  │                  │
│ analyze       │  │                  │
└───────┬───────┘  └────────┬─────────┘
        │                   │
        └───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 3. Learn Project Style         │
    │ /history-analysis (optional)   │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 4. Pre-Commit Check            │
    │ /commit-best-practices         │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 5. Generate Message            │
    │ /message-generation complete   │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 6. Present & Confirm           │
    │ User reviews message           │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 7. Create Commit               │
    │ git add . && git commit        │
    └────────────┬───────────────────┘
                 ↓
    ┌────────────────────────────────┐
    │ 8. Post-Commit Review          │
    │ /commit-best-practices         │
    │ review-commit                  │
    └────────────────────────────────┘
```

## Process

### Step 1: Verify Git Repository and Check for Issues

**Orchestrates**: `/commit-error-handling diagnose-issues`

This operation checks:
- Repository validity (is this a git repo?)
- Changes present (are there files to commit?)
- No merge conflicts
- Not in detached HEAD state
- Git configuration present

Internally executes:
```bash
git rev-parse --git-dir 2>/dev/null
git status --short
git status --porcelain
git config user.name
git config user.email
```

If issues are found, the operation provides specific guidance:

**Not a git repository:**
```
ERROR: Not a git repository

This directory is not initialized as a git repository.
Initialize one with: git init
```

**No changes to commit:**
```
No changes to commit

Working tree is clean. Make some changes first, then run /commit again.
```

**For detailed error handling**: Use `/commit-error-handling` skill directly with operations:
- `/commit-error-handling handle-no-repo` - Not a repository error
- `/commit-error-handling handle-no-changes` - No changes error
- `/commit-error-handling handle-conflicts` - Merge conflict guidance
- `/commit-error-handling handle-detached-head` - Detached HEAD handling

### Step 2: Check for Atomic Commit Opportunity

**Orchestrates**: `/atomic-commit analyze`

Before proceeding with message generation, check if the changes should be split into multiple atomic commits.

This operation analyzes:
- Number of files changed
- Logical groupings of changes
- Mixed concerns (e.g., feature + refactor + tests)

If changes should be split, provide guidance:
```
RECOMMENDATION: Split into atomic commits

Your changes involve multiple concerns:
1. Feature: New authentication module (3 files)
2. Refactor: Code cleanup in utils (2 files)
3. Tests: Test coverage for auth (1 file)

Consider using /atomic-commit interactive to split these into 3 commits.
```

**For granular atomic commit analysis**:
- `/atomic-commit group` - Group related files together
- `/atomic-commit suggest` - Recommend commit breakdown
- `/atomic-commit sequence` - Generate commit execution plan
- `/atomic-commit interactive` - Step-by-step guided splitting

### Step 3: Analyze Changes

**Orchestrates**: `/commit-analysis analyze`

If user provided a message ($ARGUMENTS is not empty), skip to Step 5 and use their message.

If no message provided, this operation analyzes your changes to determine:
- **Type**: feat, fix, docs, style, refactor, test, chore, perf, ci
- **Scope**: Primary module/component affected (auth, api, ui, etc.)
- **Atomicity**: Whether changes should be in one commit or split
- **Files**: What files are being modified

The analysis uses git commands:
```bash
# Get detailed diff
git diff HEAD

# Get status for summary
git status --short

# Get recent commits for style reference
git log --oneline -10
```

**For granular analysis**: Use these operations directly:
- `/commit-analysis detect-type` - Just determine type
- `/commit-analysis identify-scope` - Just identify scope
- `/commit-analysis assess-atomicity` - Just check if should split
- `/commit-analysis file-stats` - Get file change statistics

### Step 4: Learn Project Conventions (Optional)

**Orchestrates**: `/history-analysis analyze-style` (optional, caches results)

This operation (run periodically, results cached):
1. **Learns project conventions**
   - Analyzes recent 50-100 commits
   - Detects conventional commits usage
   - Identifies common scopes
   - Determines average subject length
   - Identifies team patterns

The analysis helps ensure generated messages match your project's existing style.

**For custom history analysis**:
- `/history-analysis detect-patterns` - Identify project conventions
- `/history-analysis extract-scopes` - Discover commonly used scopes
- `/history-analysis suggest-conventions` - Recommend conventions
- `/history-analysis learn-project` - Full project learning

### Step 5: Pre-Commit Validation (Recommended)

**Orchestrates**: `/commit-best-practices check-pre-commit`

This operation validates:
- Tests pass (npm test, pytest, cargo test, go test)
- Lint passes (eslint, pylint, clippy)
- No debug code (console.log, debugger, print, pdb)
- No TODO/FIXME in new code
- No merge conflict markers

If validation fails, commit is blocked with specific guidance:
```
PRE-COMMIT VALIDATION FAILED

Issues found:
 Tests: 2 tests failing in auth.test.js
 Lint: 3 errors in src/auth/oauth.js
 Debug: Found console.log in src/utils/debug.js

Fix these issues before committing.
Run /commit-best-practices check-pre-commit for details.
```

**For validation control**:
- Enable/disable via configuration
- Run manually: `/commit-best-practices check-pre-commit`
- Skip with: `/commit --skip-validation` (not recommended)

### Step 6: Generate Commit Message

**Orchestrates**: `/message-generation complete`

Based on the analysis from Steps 3-4, this operation generates a conventional commit message following this format:

```
<type>(<scope>): <subject>

<body (optional)>

<footer (optional)>
```

The generated message matches your project's existing style from history analysis.

**Commit Types (prioritize by analyzing changes):**

- **feat**: New features, new functions, new capabilities
  - Detects: New files, new functions, new exports, new components
  - Example: "feat(auth): add OAuth2 authentication support"

- **fix**: Bug fixes, error corrections, issue resolutions
  - Detects: Error handling, null checks, validation fixes, condition fixes
  - Example: "fix(api): resolve null pointer in user endpoint"

- **docs**: Documentation only changes
  - Detects: Changes only in README, *.md files, comments, JSDoc
  - Example: "docs(readme): update installation instructions"

- **style**: Formatting, whitespace, no code logic change
  - Detects: Indentation, semicolons, whitespace, code formatting
  - Example: "style: apply prettier formatting to components"

- **refactor**: Code restructuring without behavior change
  - Detects: Renamed variables, extracted functions, reorganized code
  - Example: "refactor(utils): simplify date formatting logic"

- **test**: Adding or updating tests
  - Detects: Changes in test files, spec files, test utilities
  - Example: "test(auth): add unit tests for login flow"

- **chore**: Build, dependencies, tooling, configuration
  - Detects: package.json, build configs, CI configs, dependencies
  - Example: "chore: update dependencies to latest versions"

- **perf**: Performance improvements
  - Detects: Optimization, caching, algorithm improvements
  - Example: "perf(render): optimize component re-rendering"

- **ci**: CI/CD configuration changes
  - Detects: .github/workflows, .gitlab-ci.yml, CI configs
  - Example: "ci: add automated testing workflow"

**Scope Determination:**
- Identify the primary module, component, or area affected
- Use kebab-case for scope names
- Examples: auth, api, utils, components, config, database

**Subject Guidelines:**
- 50 characters or less
- Present tense, imperative mood (add, not added or adds)
- No period at the end
- Lowercase after the colon

**Body (include if changes are complex):**
- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line
- Use bullet points for multiple items

**For custom message generation**:
- `/message-generation subject` - Generate subject line only
- `/message-generation body` - Generate body only
- `/message-generation footer` - Add footer with breaking changes/issues
- `/message-generation validate` - Validate existing message format

**Analysis Example:**

If git diff shows:
```diff
+++ src/auth/oauth.js
+export function authenticateWithOAuth(provider) {
+  // OAuth implementation
+}

+++ src/auth/providers.js
+export const providers = {
+  google: { ... },
+  github: { ... }
+}

+++ tests/auth.test.js
+describe('OAuth authentication', () => {
```

Generate message:
```
feat(auth): add OAuth authentication support

- Implement OAuth2 authentication flow
- Add support for Google and GitHub providers
- Include comprehensive unit tests
```

### Step 7: Present Message and Confirm

If message was generated, present it to the user:

```
PROPOSED COMMIT MESSAGE:
─────────────────────────────────────────────

feat(auth): add OAuth authentication support

- Implement OAuth2 authentication flow
- Add support for Google and GitHub providers
- Include comprehensive unit tests

─────────────────────────────────────────────

FILES TO BE COMMITTED:
 M src/auth/oauth.js
 M src/auth/providers.js
 M tests/auth.test.js

Would you like to:
1. Use this message (y)
2. Edit the message (e)
3. Provide your own message (m)
4. Cancel (n)
```

**Handle user response:**
- If user says "y" or "yes" or approves: proceed to commit
- If user says "e" or "edit": tell them to run `/commit "edited message here"`
- If user says "m" or "custom": tell them to run `/commit "your custom message"`
- If user says "n" or "no" or "cancel": abort

### Step 8: Create Commit

Stage all changes and create the commit:

```bash
# Stage all changes
git add .

# Create commit with message
git commit -m "<the message>"
```

### Step 9: Post-Commit Review

**Orchestrates**: `/commit-best-practices review-commit`

After successful commit, this operation:
- Analyzes commit quality (0-100 score)
- Validates conventional commits format
- Checks atomicity
- Provides improvement suggestions

Show detailed information:

```bash
# Get commit info
git log -1 --stat
git log -1 --format="%H"
```

Format output with quality review:

```
COMMIT SUCCESSFUL
─────────────────────────────────────────────

Hash: abc1234def5678
Message: feat(auth): add OAuth authentication support

FILES CHANGED: 5 files
INSERTIONS: 247 (+)
DELETIONS: 63 (-)

─────────────────────────────────────────────

COMMIT QUALITY REVIEW (Score: 95/100)

Format: Excellent - follows conventional commits
Atomicity: Good - focused on single feature
Message: Clear and descriptive

Suggestions:
 Consider adding issue reference in footer (e.g., "Closes #123")

─────────────────────────────────────────────

NEXT STEPS:

Run /commit again to check for remaining uncommitted changes
Run git push to push this commit to remote
```

**For detailed review**:
- `/commit-best-practices review-commit` - Full analysis
- `/commit-best-practices amend-guidance` - Safe amend help
- `/commit-best-practices revert-guidance` - Help with commit reverts

### Step 10: Check for Remaining Changes

After committing, check if there are more uncommitted changes:

```bash
git status --short
```

If there are more changes, add a tip:
```
TIP: You have 3 more modified files.
     Run /commit again to commit them.
```

## Error Handling

**Orchestrates**: `/commit-error-handling` skill for all error scenarios

**Not a git repository:**
```
ERROR: Not a git repository
Initialize with: git init
```
Use: `/commit-error-handling handle-no-repo` for detailed guidance

**No changes to commit:**
```
Nothing to commit, working tree clean
```
Use: `/commit-error-handling handle-no-changes` for suggestions

**Merge conflicts:**
```
ERROR: Merge conflicts detected
Resolve conflicts before committing
```
Use: `/commit-error-handling handle-conflicts` for conflict resolution guidance

**Detached HEAD state:**
```
ERROR: Detached HEAD state
Cannot commit in detached HEAD
```
Use: `/commit-error-handling handle-detached-head` for recovery steps

**Commit failed:**
```
ERROR: Commit failed
<show git error message>

Common fixes:
- Ensure you have staged changes
- Check git configuration (git config user.name/user.email)
- Verify repository is not in a conflicted state
```
Use: `/commit-error-handling diagnose-issues` for comprehensive diagnosis

## Examples

**Example 1: Auto-generate message**
```bash
/commit
# Analyzes changes, generates "feat(api): add user authentication endpoint"
# Prompts for confirmation, creates commit
```

**Example 2: Custom message**
```bash
/commit "fix: resolve login timeout issue"
# Uses provided message directly
```

**Example 3: Complex feature**
```bash
/commit
# Generates:
# feat(payments): integrate Stripe payment processing
#
# - Add Stripe SDK integration
# - Implement payment flow for subscriptions
# - Add webhook handlers for payment events
# - Include error handling and retry logic
```

## Tips

- Let the assistant analyze changes for accurate commit types
- Use conventional commits format for consistency
- Create atomic commits (one logical change per commit)
- Run `/atomic-commit analyze` first to check if you should split commits
- Run `/commit-best-practices check-pre-commit` to validate before committing
- Use `/history-analysis analyze-style` to learn project conventions
- Include scope for better commit history navigation

## Conventional Commits Quick Reference

**Format:** `<type>(<scope>): <subject>`

**Types:** feat, fix, docs, style, refactor, test, chore, perf, ci

**Good Examples:**
- feat(auth): add two-factor authentication
- fix(api): handle null response in user endpoint
- docs(readme): add installation instructions
- refactor(utils): extract validation logic to separate module
- test(auth): add integration tests for OAuth flow

**Bad Examples:**
- update files (vague, no type)
- fixed bug (no scope, not descriptive)
- WIP (work in progress, not descriptive)
- asdf (meaningless)

## Related Skills and Commands

### Granular Skills
For precise control over individual operations:

- **Error Handling**: `/commit-error-handling` - Diagnose and resolve git issues
  - `/commit-error-handling diagnose-issues` - Comprehensive diagnosis
  - `/commit-error-handling handle-no-repo` - Repository initialization
  - `/commit-error-handling handle-no-changes` - No changes guidance
  - `/commit-error-handling handle-conflicts` - Merge conflict resolution
  - `/commit-error-handling handle-detached-head` - Detached HEAD recovery

- **Analysis**: `/commit-analysis` - Detailed change analysis
  - `/commit-analysis analyze` - Full comprehensive analysis
  - `/commit-analysis detect-type` - Determine commit type
  - `/commit-analysis identify-scope` - Identify affected module
  - `/commit-analysis assess-atomicity` - Check if should split
  - `/commit-analysis file-stats` - Get file change statistics

- **Message Generation**: `/message-generation` - Create/validate messages
  - `/message-generation complete` - Generate full message
  - `/message-generation subject` - Create subject line only
  - `/message-generation body` - Compose commit body
  - `/message-generation footer` - Add footer with issues
  - `/message-generation validate` - Validate message format

- **Atomic Commits**: `/atomic-commit` - Split large commits
  - `/atomic-commit analyze` - Determine if should split
  - `/atomic-commit group` - Group related files
  - `/atomic-commit suggest` - Recommend commit breakdown
  - `/atomic-commit sequence` - Generate commit plan
  - `/atomic-commit interactive` - Guided splitting

- **Best Practices**: `/commit-best-practices` - Validate and review
  - `/commit-best-practices check-pre-commit` - Validate readiness
  - `/commit-best-practices review-commit` - Analyze quality
  - `/commit-best-practices amend-guidance` - Safe amend help
  - `/commit-best-practices revert-guidance` - Revert help
  - `/commit-best-practices workflow-tips` - Complete workflow guidance

- **History Analysis**: `/history-analysis` - Learn project conventions
  - `/history-analysis analyze-style` - Learn from recent commits
  - `/history-analysis detect-patterns` - Identify conventions
  - `/history-analysis extract-scopes` - Discover common scopes
  - `/history-analysis suggest-conventions` - Recommend conventions
  - `/history-analysis learn-project` - Full project learning

### Related High-Level Commands
Other simplified workflows:

- `/commit-review` - Analyze changes and get splitting recommendations
- `/commit-split` - Interactively split large commits into atomic commits

### Documentation References

- **Conventional Commits**: https://www.conventionalcommits.org/
- **SKILL_ARCHITECTURE.md**: Pattern documentation for skill orchestration
- **Agent Documentation**: See `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/agents/commit-assistant.md` for complete skill reference
- **Plugin Repository**: https://github.com/your-repo/git-commit-assistant

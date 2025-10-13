# Operation: Interactive Split

Interactive guided workflow for splitting commits.

## Parameters from $ARGUMENTS

- `step:number` - Start at specific step (default: 1)
- `auto:true|false` - Auto-advance through steps (default: false)

## Workflow

This operation provides step-by-step guided experience through the entire atomic commit splitting process.

### Step 1: Analyze Current Changes

**Display:**
```
🔍 STEP 1: ANALYZE CHANGES
─────────────────────────────────────

Analyzing your current changes...
```

**Execute:**
```bash
/atomic-commit analyze verbose:true
```

**Parse results and show:**
```
Current status:
  Files changed: 13
  Types detected: feat, fix, docs
  Scopes detected: auth, api
  Recommendation: Should split

Analysis:
  ⚠️  Multiple types detected (feat, fix, docs)
  ⚠️  Multiple scopes detected (auth, api)
  ✅ File count manageable (13 files)

Recommendation:
  Split into multiple atomic commits for:
  - Easier code review
  - Safer reverts
  - Clearer history
```

**Prompt user:**
```
Options:
  [1] Continue to grouping (recommended)
  [2] Review analysis details
  [3] Exit (keep as one commit)

Your choice:
```

### Step 2: Group Files

**Display:**
```
📦 STEP 2: GROUP FILES
─────────────────────────────────────

How would you like to group files?
```

**Show grouping strategies:**
```
Strategies:
  [1] By type (feat, fix, docs)
      Best for: Mixed-type changes
      Groups: ~3 groups expected

  [2] By scope (auth, api, docs)
      Best for: Changes across modules
      Groups: ~3 groups expected

  [3] By feature (related functionality)
      Best for: Complex feature work
      Groups: ~2-4 groups expected

  [4] Auto-select (recommended)
      Let me choose the best strategy

Your choice:
```

**Execute grouping:**
```bash
/atomic-commit group strategy:<selected> show:all
```

**Show results:**
```
Groups created:

📦 Group 1: feat(auth) - 8 files
  Purpose: OAuth 2.0 implementation
  Files: src/auth/*, tests/auth/*
  Atomic: ✅ Yes

📦 Group 2: fix(api) - 3 files
  Purpose: Null pointer fix
  Files: src/api/*, tests/api/*
  Atomic: ✅ Yes

📦 Group 3: docs - 2 files
  Purpose: Authentication guide
  Files: README.md, docs/authentication.md
  Atomic: ✅ Yes

All groups are atomic: ✅ Yes
```

**Prompt user:**
```
Options:
  [1] Continue to commit suggestions
  [2] Adjust grouping
  [3] Try different strategy
  [4] Back to step 1

Your choice:
```

### Step 3: Review Commit Suggestions

**Display:**
```
💬 STEP 3: COMMIT SUGGESTIONS
─────────────────────────────────────

Generating commit messages...
```

**Execute:**
```bash
/atomic-commit suggest format:conventional include_body:true
```

**Show suggestions with review interface:**
```
Commit 1 of 3:
┌─────────────────────────────────────────────┐
│ feat(auth): implement OAuth 2.0 auth        │
│                                             │
│ Add complete OAuth 2.0 authentication flow │
│ with support for multiple providers        │
│ (GitHub, Google). Includes token           │
│ management, refresh handling, and          │
│ comprehensive test coverage.               │
│                                             │
│ Files: 8                                    │
│ Atomic: ✅ Yes                              │
└─────────────────────────────────────────────┘

Options for this commit:
  [a] Accept as-is
  [e] Edit message
  [s] Skip this commit
  [v] View files in commit

Your choice:
```

**If user edits, provide interface:**
```
Edit commit message:

Subject (max 50 chars):
> feat(auth): implement OAuth 2.0 authentication

Body (optional):
> Add complete OAuth 2.0 authentication flow with
> support for multiple providers (GitHub, Google).
> Includes token management, refresh handling, and
> comprehensive test coverage.

Footer (optional):
>

[s] Save   [c] Cancel   [r] Reset
```

**After reviewing all commits:**
```
All commits reviewed:
  ✅ Commit 1: feat(auth) - Accepted
  ✅ Commit 2: fix(api) - Edited
  ✅ Commit 3: docs - Accepted

Options:
  [1] Continue to sequence planning
  [2] Review commits again
  [3] Back to grouping

Your choice:
```

### Step 4: Create Commit Sequence

**Display:**
```
📋 STEP 4: COMMIT SEQUENCE
─────────────────────────────────────

Creating execution plan...
```

**Execute:**
```bash
/atomic-commit sequence output:plan
```

**Show sequence:**
```
Commit Order:

1️⃣ feat(auth) - 8 files
   Dependencies: None
   Can commit: ✅ Now

2️⃣ fix(api) - 3 files
   Dependencies: None
   Can commit: ✅ After commit 1

3️⃣ docs - 2 files
   Dependencies: Commit 1 (documents auth)
   Can commit: ✅ After commit 1

Execution time: ~3 minutes
All dependencies resolved: ✅ Yes
```

**Prompt user:**
```
Options:
  [1] Show execution commands
  [2] Generate script
  [3] Execute with guidance (recommended)
  [4] Let agent execute
  [5] Back to step 3

Your choice:
```

### Step 5: Execute Commits

**If user chooses guided execution:**

```
🚀 STEP 5: EXECUTE COMMITS
─────────────────────────────────────

Executing commit 1 of 3...

┌─────────────────────────────────────────────┐
│ COMMIT 1: feat(auth)                        │
└─────────────────────────────────────────────┘

Staging files:
  ✅ src/auth/oauth.ts
  ✅ src/auth/tokens.ts
  ✅ src/auth/providers/github.ts
  ✅ src/auth/providers/google.ts
  ✅ src/config/oauth.config.ts
  ✅ src/types/auth.types.ts
  ✅ tests/auth/oauth.test.ts
  ✅ tests/auth/tokens.test.ts

Creating commit:
  Message: feat(auth): implement OAuth 2.0 authentication
  Files: 8
  Status: ✅ Success

Commit created: a1b2c3d

─────────────────────────────────────────────

Proceed to commit 2?
  [y] Yes, continue
  [r] Review what was just committed
  [p] Pause (save progress)
  [a] Abort remaining commits

Your choice:
```

**Continue through all commits...**

**Final summary:**
```
✨ COMPLETE: ALL COMMITS CREATED
─────────────────────────────────────

Summary:
  ✅ Commit 1: feat(auth) - a1b2c3d
  ✅ Commit 2: fix(api) - b2c3d4e
  ✅ Commit 3: docs - c3d4e5f

Total commits: 3
Total files: 13
Time elapsed: 2m 45s

Your git history is now atomic! 🎉

Next steps:
  • Review commits: git log -3
  • Push commits: git push
  • Create PR: gh pr create
```

## Progress Tracking

The interactive workflow maintains state:

```yaml
session:
  step: 1-5
  completed_steps: [list]
  current_groups: [...]
  current_suggestions: [...]
  current_sequence: [...]
  created_commits: [...]
  can_resume: true|false
```

Users can:
- Pause at any step
- Resume from where they left off
- Go back to previous steps
- Skip steps if desired

## Navigation Commands

Throughout the interactive workflow:
- **[n]** Next
- **[b]** Back
- **[h]** Help
- **[q]** Quit
- **[r]** Restart
- **[s]** Status

## Error Handling

**During analysis:**
- No changes detected → Guide to make changes first
- Git errors → Provide troubleshooting steps

**During grouping:**
- Cannot group files → Suggest manual review
- Grouping unclear → Offer alternative strategies

**During suggestions:**
- Cannot generate message → Provide template
- User unsure → Offer examples and guidance

**During execution:**
- Staging fails → Show file status and retry
- Commit fails → Preserve work, show error
- Partial completion → Save progress, allow resume

## Auto Mode

When `auto:true` is specified:
- Automatically selects recommended options
- Shows results at each step
- Pauses for user confirmation at commit execution
- Useful for experienced users who trust recommendations

Example:
```bash
/atomic-commit interactive auto:true
→ Analyzes → Groups by best strategy → Suggests → Creates sequence → Waits for confirmation
```

## Resume Capability

If interrupted, users can resume:
```bash
/atomic-commit interactive step:3
→ Resumes from step 3 (commit suggestions)
```

Session data is preserved across invocations.

## Help System

At any point, user can type `[h]` for context-sensitive help:

```
📚 HELP - Step 2: Grouping
─────────────────────────────────────

Grouping strategies:
  • Type: Groups by commit type (feat, fix, docs)
  • Scope: Groups by module (auth, api, ui)
  • Feature: Groups by related functionality

Tips:
  • Choose "type" for mixed-type changes
  • Choose "scope" for module-based work
  • Choose "feature" for complex features
  • Choose "auto" if unsure

Examples:
  Type grouping: feat files | fix files | docs files
  Scope grouping: auth files | api files | ui files

Press any key to continue...
```

## Output Format

The interactive workflow uses:
- Clear step indicators
- Progress tracking
- Visual separators
- Emoji for status
- Color coding (if supported)
- Consistent option menus
- Helpful prompts

## Examples

**Example 1: Full interactive workflow**
```bash
/atomic-commit interactive
→ Guides through all steps with prompts
```

**Example 2: Auto mode**
```bash
/atomic-commit interactive auto:true
→ Auto-selects best options, confirms before execution
```

**Example 3: Resume from step**
```bash
/atomic-commit interactive step:3
→ Resumes from commit suggestions step
```

## Integration with Agent

The commit-assistant agent can:
1. Recommend interactive mode for complex splits
2. Guide users through steps
3. Answer questions during workflow
4. Explain recommendations
5. Execute commits on behalf of user (with approval)

The interactive workflow provides the best user experience for learning atomic commit practices.

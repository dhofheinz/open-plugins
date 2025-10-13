# Operation: Safe Commit Amend Guidance

Guide users through safely amending commits with comprehensive safety checks.

## Parameters from $ARGUMENTS

- **force** (optional): Skip safety checks (default: false) - USE WITH EXTREME CAUTION

Parse as: `amend-guidance force:true` or `amend-guidance`

## Amend Safety Workflow

### Step 1: Run Amend Safety Check

Execute safety validation script:

```bash
./.claude/commands/commit-best-practices/.scripts/amend-safety.sh
```

The script checks:
1. Commit not pushed to remote
2. Same author (current user matches commit author)
3. Not on protected branch (main/master)
4. No collaborators have pulled it

Returns:
```json
{
  "safe": true|false,
  "checks": {
    "not_pushed": {"status": "pass|fail", "message": "..."},
    "same_author": {"status": "pass|fail", "message": "..."},
    "safe_branch": {"status": "pass|warn", "message": "..."},
    "collaborators": {"status": "pass|warn", "message": "..."}
  },
  "recommendation": "safe|warning|unsafe"
}
```

### Step 2: Evaluate Safety Status

**SAFE (All checks pass):**
```
✅ SAFE TO AMEND

Last commit: abc123
Author: John Doe <john@example.com> (you)
Branch: feature/oauth-implementation
Status: Not pushed to remote

All safety checks passed:
  ✅ Commit not pushed to remote
  ✅ You are the author
  ✅ Not on main/master branch
  ✅ No collaborators have this commit

It is SAFE to amend this commit.
```

**WARNING (Minor concerns):**
```
⚠️  AMEND WITH CAUTION

Last commit: abc123
Author: John Doe <john@example.com> (you)
Branch: main
Status: Not pushed to remote

Safety checks:
  ✅ Commit not pushed to remote
  ✅ You are the author
  ⚠️  WARNING: On main/master branch
  ✅ No collaborators have this commit

Amending on main/master is discouraged but technically safe if not pushed.

Recommendation: Create new commit instead of amending.
```

**UNSAFE (Critical issues):**
```
❌ UNSAFE TO AMEND

Last commit: abc123
Author: Jane Smith <jane@example.com> (NOT you)
Branch: feature/oauth
Status: Pushed to origin/feature/oauth

Safety violations:
  ❌ CRITICAL: Commit already pushed to remote
  ❌ CRITICAL: Different author (Jane Smith, not you)
  ✅ Safe branch (not main/master)
  ⚠️  WARNING: Other developers may have pulled this

DO NOT AMEND THIS COMMIT!

Amending will:
  1. Rewrite git history
  2. Break other developers' work
  3. Require force push (dangerous)
  4. Cause merge conflicts for collaborators

Use: git revert (to undo changes safely)
Or: Create new commit (to add fixes)
```

### Step 3: Provide Amend Instructions

**If SAFE, show how to amend:**

```
How to Amend Commit
===================

Current commit message:
---
feat(auth): add OAuth authentication

Implement OAuth2 flow for Google and GitHub
---

Option 1: Amend with staged changes
-------------------------------------
1. Make your changes to files
2. Stage changes: git add <files>
3. Amend commit: git commit --amend

This opens editor to modify message if needed.

Option 2: Amend message only
-----------------------------
git commit --amend

Opens editor to change commit message.
No file changes included.

Option 3: Amend with new message (no editor)
---------------------------------------------
git commit --amend -m "new message here"

Direct message change without editor.

After amending:
---------------
Review commit: /commit-best-practices review-commit
Verify changes: git show HEAD
Continue work or push: git push origin <branch>

Note: If you already pushed, you'll need: git push --force-with-lease
(Only if you're certain no one else has pulled your changes!)
```

**If UNSAFE, show alternatives:**

```
Safe Alternatives to Amending
==============================

Since amending is unsafe, use these alternatives:

Option 1: Create New Commit (Recommended)
------------------------------------------
Make your changes and commit normally:

1. Make changes to files
2. Stage: git add <files>
3. Commit: git commit -m "fix: address review feedback"

This preserves history and is safe for collaborators.

Option 2: Revert Previous Commit
---------------------------------
If the commit is wrong, revert it:

1. Revert: git revert HEAD
2. Make correct changes
3. Commit: git commit -m "correct implementation"

This creates two new commits (revert + fix).

Option 3: Interactive Rebase (Advanced)
----------------------------------------
Only if you're experienced and coordinate with team:

1. git rebase -i HEAD~2
2. Mark commit as 'edit'
3. Make changes
4. git rebase --continue

⚠️  WARNING: Requires force push, coordinate with team!

Best Practice:
--------------
When in doubt, create a new commit. It's always safer.
```

### Step 4: Force Mode Handling

If user specified `force:true`:

```
⚠️  FORCE MODE ENABLED

You've bypassed safety checks. This is DANGEROUS!

Proceeding with amend despite warnings.

Current commit: abc123
Branch: main
Status: Pushed to remote

You are responsible for:
  1. Coordinating with team before force push
  2. Ensuring no one has pulled this commit
  3. Handling any conflicts that arise
  4. Notifying team of force push

Force push command (if you must):
git push --force-with-lease origin <branch>

Better alternatives:
  - Create new commit instead
  - Use git revert for pushed commits
  - Coordinate with team before rewriting history

Proceed with extreme caution!
```

## Safety Rules Summary

### ✅ SAFE to amend if ALL true:

1. **Not pushed to remote**
   - `git log @{upstream}..HEAD` shows commit
   - Commit only exists locally

2. **Same author**
   - `git config user.email` matches commit author
   - You made the commit

3. **Not on protected branch**
   - Not on main/master
   - Or: on feature branch

4. **No collaborators affected**
   - Solo work on branch
   - Or: coordinated with team

### ❌ NEVER amend if ANY true:

1. **Already pushed to remote**
   - Commit exists on origin
   - Others may have pulled it

2. **Different author**
   - Someone else made the commit
   - Not your work to modify

3. **Collaborators working on same branch**
   - Team has pulled your commit
   - Would break their work

4. **On shared/protected branch**
   - main/master branch
   - Production/release branches

## When Amend is Useful

**Good use cases:**
- Fix typo in commit message (before push)
- Add forgotten file to commit (before push)
- Improve commit message clarity (before push)
- Reformat message to match conventions (before push)

**Bad use cases:**
- Fixing bug in pushed commit (use new commit)
- Changing commit after code review started (confusing)
- Modifying shared branch commits (breaks collaboration)
- Rewriting public history (dangerous)

## Output Format

```
Amend Safety Check
==================

Commit: <sha>
Author: <name> <email> [you|NOT you]
Branch: <branch>
Status: [Local only|Pushed to <remote>]

SAFETY CHECKS:
  [✅|⚠️|❌] Commit not pushed
  [✅|⚠️|❌] Same author
  [✅|⚠️|❌] Safe branch
  [✅|⚠️|❌] No collaborators affected

VERDICT: [SAFE|WARNING|UNSAFE]

[Detailed explanation]

[If SAFE: Amend instructions]
[If UNSAFE: Safe alternatives]
```

## Error Handling

**No commits to amend:**
```
ERROR: No commits to amend
This is the first commit (no parent)
Use: git commit (to create first commit)
```

**Not a git repository:**
```
ERROR: Not a git repository
Run: git init (to initialize)
```

**Script execution error:**
```
ERROR: Amend safety check script failed
Check: .claude/commands/commit-best-practices/.scripts/amend-safety.sh exists
Verify: Script is executable
```

## Integration with Agent

When user says "amend my commit" or "fix my commit":
1. Agent MUST run safety check FIRST
2. If unsafe, BLOCK amend and show alternatives
3. If safe, provide clear amend instructions
4. Never allow unsafe amend without explicit force flag

## Git Commands Reference

```bash
# Check if commit is pushed
git log @{upstream}..HEAD

# Check commit author
git log -1 --format='%an %ae'

# Check current branch
git branch --show-current

# Check remote tracking
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}

# Amend commit (opens editor)
git commit --amend

# Amend with message (no editor)
git commit --amend -m "new message"

# Amend without changing message
git commit --amend --no-edit

# Force push if needed (DANGEROUS)
git push --force-with-lease origin <branch>
```

## Best Practices

1. **Default to safe**: Always check before amending
2. **Never force without reason**: Force flag is dangerous
3. **Prefer new commits**: When in doubt, commit new changes
4. **Communicate**: Tell team before force pushing
5. **Use revert**: For pushed commits, revert instead of amend

Safe git practices prevent broken collaboration and lost work.

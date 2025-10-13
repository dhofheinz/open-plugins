# Operation: Handle Merge Conflicts

Detect and guide resolution of merge conflicts.

## Purpose

When merge conflicts are present, provide clear detection, explanation, and step-by-step resolution guidance.

## Parameters

None required - automatic detection and analysis.

## Workflow

### 1. Detect Conflicts

Execute the conflict detector script:

```bash
/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/conflict-detector.py
```

This will return JSON:
```json
{
  "has_conflicts": true,
  "conflict_count": 3,
  "conflicted_files": [
    "src/auth/oauth.js",
    "src/api/users.js",
    "README.md"
  ],
  "merge_in_progress": true
}
```

### 2. Analyze Conflict Context

Determine the merge situation:

```bash
# Check merge state
git status

# View merge information
git log --merge --oneline -5

# Check which operation caused conflicts
ls -la .git/MERGE_HEAD 2>/dev/null && echo "Merge in progress"
ls -la .git/REBASE_HEAD 2>/dev/null && echo "Rebase in progress"
ls -la .git/CHERRY_PICK_HEAD 2>/dev/null && echo "Cherry-pick in progress"
```

### 3. Present Conflict Report

#### High-Level Overview

```
MERGE CONFLICTS DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━

You have unresolved merge conflicts.

Conflict Summary:
━━━━━━━━━━━━━━━━
Conflicted files: 3
Operation: merge
Current branch: feature-branch
Merging from: main

Conflicted Files:
━━━━━━━━━━━━━━━━
1. src/auth/oauth.js
2. src/api/users.js
3. README.md
```

### 4. Provide Resolution Guidance

#### Step-by-Step Resolution Process

```
RESOLUTION STEPS
━━━━━━━━━━━━━━━━━━

Step 1: Understand Conflict Markers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Conflicts look like this in files:

<<<<<<< HEAD (your changes)
your code here
=======
their code here
>>>>>>> branch-name (incoming changes)

Step 2: Open Each Conflicted File
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Open in your editor:
- src/auth/oauth.js
- src/api/users.js
- README.md

Step 3: Resolve Each Conflict
━━━━━━━━━━━━━━━━━━━━━━━━━━━

For each conflict, decide:

A) Keep your changes (HEAD):
   Remove markers and keep your version

B) Keep their changes:
   Remove markers and keep their version

C) Keep both (merge manually):
   Combine both versions intelligently
   Remove all conflict markers

D) Rewrite completely:
   Replace with new code that integrates both

Important: Remove ALL markers (<<<<<<, =======, >>>>>>>)

Step 4: Mark as Resolved
━━━━━━━━━━━━━━━━━━━━━━━

After editing each file:

git add src/auth/oauth.js
git add src/api/users.js
git add README.md

Step 5: Complete the Merge
━━━━━━━━━━━━━━━━━━━━━━━

After resolving all conflicts:

git commit

This will create a merge commit.
Git will suggest a merge message - accept or customize it.

Step 6: Verify Resolution
━━━━━━━━━━━━━━━━━━━━━━━

git status  # Should show no conflicts
git log --oneline -1  # See merge commit
```

### 5. Provide Abort Option

```
ALTERNATIVE: Abort the Merge
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you want to cancel and start over:

git merge --abort

This will:
- Undo the merge attempt
- Return to state before merge
- No changes will be committed

After aborting, you can:
- Prepare your branch better
- Try the merge again later
- Use a different merge strategy
```

### 6. Show Conflict Details Per File

For each conflicted file, provide analysis:

```
File: src/auth/oauth.js
━━━━━━━━━━━━━━━━━━━━━━━

Conflict regions: 2

Region 1 (lines 45-52):
  Your changes: Added new OAuth provider
  Their changes: Refactored existing providers
  Suggestion: Keep both, integrate new provider into refactored code

Region 2 (lines 89-94):
  Your changes: New error handling
  Their changes: Different error handling
  Suggestion: Merge both approaches, keep comprehensive handling

Quick view:
git diff src/auth/oauth.js
```

### 7. Provide Merge Tool Suggestions

```
MERGE TOOLS
━━━━━━━━━━━

For complex conflicts, use a merge tool:

1. Built-in tool:
   git mergetool

2. VS Code:
   code src/auth/oauth.js
   (Look for conflict highlighting)

3. Diff tool:
   git diff --merge

4. Compare with branches:
   git show :1:src/auth/oauth.js  # common ancestor
   git show :2:src/auth/oauth.js  # your version
   git show :3:src/auth/oauth.js  # their version
```

## Error Handling

### If no conflicts detected

```
No conflicts detected.

Checking git status...
[show git status output]

If you expected conflicts:
- Conflicts may have been auto-resolved
- Check git log for merge commits
- Run: git log --merge
```

### If conflicts already resolved

```
Conflicts were already resolved.

Remaining actions:
1. Verify all changes are correct:
   git diff --cached

2. Complete the merge:
   git commit

3. Or abort if incorrect:
   git merge --abort
```

### If in middle of rebase

```
Rebase in progress (not merge).

Different resolution process:

1. Resolve conflicts in files
2. Stage resolved files:
   git add <file>
3. Continue rebase:
   git rebase --continue

Or abort:
   git rebase --abort
```

## Output Format

Always provide:
1. **Conflict summary** - Count and list of files
2. **Context** - What operation caused conflicts
3. **Step-by-step guidance** - Clear resolution steps
4. **Per-file analysis** - Specific conflict details
5. **Verification steps** - How to confirm resolution
6. **Abort option** - How to cancel safely

## Success Indicators

After resolution:
- No conflict markers remain in files
- `git status` shows no conflicts
- All changes are staged
- User can complete merge commit
- Tests still pass (if applicable)

## Best Practices Guidance

```
CONFLICT RESOLUTION BEST PRACTICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Don't rush - Understand both versions first
2. Test after resolving - Ensure code still works
3. Ask for help - If conflict is complex, consult team
4. Keep context - Review what both branches were trying to do
5. Document - If resolution is non-obvious, explain in commit

When in doubt:
- git merge --abort and ask for help
- Don't commit broken code
- Review changes carefully
```

## Related Operations

- Before resolving, run **diagnose-issues** for full context
- After resolving, run **commit-analysis/analyze-changes** to verify
- Use **commit-best-practices/review-commit** before pushing merge

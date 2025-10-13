# Operation: Handle Detached HEAD State

Handle detached HEAD state and provide solutions.

## Purpose

When git is in "detached HEAD" state, explain what this means and provide clear options for resolution.

## Parameters

None required - automatic detection and guidance.

## Workflow

### 1. Detect Detached HEAD State

Check HEAD status:

```bash
# Check if HEAD is detached
git symbolic-ref HEAD 2>/dev/null || echo "detached"

# Get current commit
git rev-parse --short HEAD

# Check if any branch points here
git branch --contains HEAD
```

### 2. Analyze Context

Determine how user got into detached HEAD:

```bash
# Check reflog for recent operations
git reflog -10

# Check recent checkouts
git reflog | grep "checkout:" | head -5

# See what branches exist
git branch -a
```

Common causes:
- Checked out a specific commit SHA
- Checked out a tag
- During rebase or bisect operations
- After certain git operations that move HEAD

### 3. Explain Detached HEAD State

#### Clear Explanation

```
DETACHED HEAD STATE
━━━━━━━━━━━━━━━━━━━

Current state:
HEAD is at: abc1234
Branch: (none - detached HEAD)

What This Means:
━━━━━━━━━━━━━━━━

You are not on any branch. You're directly on commit abc1234.

Why This Matters:
━━━━━━━━━━━━━━━━

- New commits you make won't be on any branch
- When you switch branches, these commits become hard to find
- You could lose work if you don't create a branch

This is OK for:
✅ Viewing old commits
✅ Testing code at a specific point
✅ Temporary exploration

This is NOT OK for:
❌ Making new commits you want to keep
❌ Starting new work
❌ Continuing development
```

### 4. Provide Resolution Options

#### Option A: Create New Branch Here

```
SOLUTION A: Create a New Branch Here
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you want to keep working from this commit:

1. Create and switch to new branch:
   git checkout -b new-branch-name

   OR (two steps):
   git branch new-branch-name
   git checkout new-branch-name

2. Verify:
   git status
   # Should show "On branch new-branch-name"

3. Continue working:
   Make commits as normal
   They'll be on the new branch

Example:
git checkout -b fix-issue-123
```

#### Option B: Return to a Branch

```
SOLUTION B: Return to Your Branch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you were just exploring and want to go back:

1. Switch to your branch:
   git checkout main

   OR:
   git checkout <your-branch-name>

2. Verify:
   git status
   # Should show "On branch main"

Available branches:
[List branches from git branch -a]

Recent branch:
git checkout -  # Goes to previous branch
```

#### Option C: Attach HEAD to Existing Branch

```
SOLUTION C: Attach HEAD to Existing Branch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If a branch already points to this commit:

Current commit: abc1234
Branches at this commit:
[List from git branch --contains]

1. Check out that branch:
   git checkout <branch-name>

2. Verify:
   git branch
   # Should show * next to branch name
```

#### Option D: Keep Commits Made in Detached HEAD

If user already made commits in detached HEAD:

```
SOLUTION D: Preserve Commits Made in Detached HEAD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You made commits while in detached HEAD.

Current situation:
- HEAD at: abc1234
- Commits made: 3
- These commits are not on any branch!

To save them:

1. Create branch from current position:
   git checkout -b save-my-work

2. Verify commits are there:
   git log --oneline -5

Your commits are now safe on "save-my-work" branch.

Next steps:
- Continue work on this branch, OR
- Merge into another branch:
  git checkout main
  git merge save-my-work
```

### 5. Show Visual Diagram

```
VISUAL EXPLANATION
━━━━━━━━━━━━━━━━━━

Normal State (on a branch):
━━━━━━━━━━━━━━━━━━━━━━━━━

main → [commit 1] → [commit 2] → [commit 3]
                                      ↑
                                    HEAD

HEAD points to branch "main"
Branch "main" points to commit 3


Detached HEAD State:
━━━━━━━━━━━━━━━━━━━━

main → [commit 1] → [commit 2] → [commit 3]

              [commit X] ← HEAD (detached)

HEAD points directly to commit X
No branch points to commit X


Making Commits in Detached HEAD:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main → [commit 1] → [commit 2] → [commit 3]

              [commit X] → [commit Y] ← HEAD (detached)

If you checkout main now, commit Y becomes orphaned!


Solution - Create Branch:
━━━━━━━━━━━━━━━━━━━━━━━━

main → [commit 1] → [commit 2] → [commit 3]

new-branch → [commit X] → [commit Y] ← HEAD

Now commits are safe on "new-branch"
```

### 6. Interactive Decision Support

Guide user to choose:

```
What would you like to do?

A) Create a new branch here and continue working
   → Choose this if you want to keep this commit as a starting point

B) Return to a branch (discard position)
   → Choose this if you were just exploring

C) Attach to an existing branch
   → Choose this if a branch already points here

D) Save commits I made while detached
   → Choose this if you already made commits

E) Not sure - need more explanation

Please respond with A, B, C, D, or E.
```

## Error Handling

### If not in detached HEAD

```
Not in detached HEAD state.

Current state:
Branch: main
HEAD: abc1234

You're on a normal branch. No action needed.
```

### If during special operation

```
Detached HEAD during rebase.

This is temporary and expected.

Actions:
- Complete the rebase: git rebase --continue
- OR abort: git rebase --abort

After completing/aborting, HEAD will reattach automatically.
```

### If commits will be lost

```
⚠️  WARNING: Orphaned Commits Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You made 3 commits in detached HEAD:
- abc1234 "commit message 1"
- def5678 "commit message 2"
- ghi9012 "commit message 3"

If you switch branches now, these will be lost!

REQUIRED ACTION: Create a branch first
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

git checkout -b save-my-commits

Then you can safely work with these commits.
```

## Output Format

Always provide:
1. **Clear state description** - What detached HEAD means
2. **Current situation** - What commit, how user got here
3. **Multiple solutions** - All applicable options
4. **Visual aids** - Diagrams if helpful
5. **Specific commands** - Exact steps to resolve
6. **Warnings** - If commits could be lost

## Success Indicators

After resolution:
- HEAD is attached to a branch
- `git branch` shows current branch with *
- `git status` shows "On branch <name>"
- User understands what happened
- No commits were lost

## Best Practices Guidance

```
AVOIDING DETACHED HEAD
━━━━━━━━━━━━━━━━━━━━━━

Prevention tips:

1. Use branches for work:
   git checkout -b feature-name
   (not: git checkout abc1234)

2. If checking out commits for inspection:
   Remember you're in detached HEAD
   Don't make commits you want to keep

3. If you need to work on an old commit:
   git checkout -b fix-branch abc1234
   (Creates branch at that commit)

4. Use tags for reference points:
   git tag v1.0 abc1234
   git checkout tags/v1.0
   (Still detached, but purpose is clear)

Remember:
Detached HEAD is a valid state for temporary inspection,
but always create a branch before making commits.
```

## Related Operations

- After resolving, run **diagnose-issues** to verify state
- Before creating branches, check with **history-analysis** for naming conventions
- After attaching HEAD, continue with normal commit workflow

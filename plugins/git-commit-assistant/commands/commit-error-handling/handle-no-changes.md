# Operation: Handle No Changes Error

Handle "nothing to commit, working tree clean" errors.

## Purpose

When attempting to commit with no staged or unstaged changes, guide users to understand why and what to do next.

## Parameters

None required - detection is automatic.

## Workflow

### 1. Verify Changes Status

Execute the changes detector script:

```bash
/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/changes-detector.sh
```

This will return JSON:
```json
{
  "has_changes": false,
  "staged_count": 0,
  "unstaged_count": 0,
  "untracked_count": 0,
  "total_changes": 0
}
```

### 2. Analyze Git Status

Run comprehensive status check:
```bash
git status --porcelain
git status
```

Determine:
- Are files modified but not saved?
- Are all changes already committed?
- Are changes in a different directory?
- Are files ignored by .gitignore?

### 3. Provide Context-Specific Guidance

#### Scenario A: All Changes Already Committed

```
NO CHANGES TO COMMIT
━━━━━━━━━━━━━━━━━━━━

Your working tree is clean.

Current Status:
✅ All changes are already committed
✅ No modified files
✅ No untracked files

This means:
- All your changes have been saved to git
- Nothing new to commit

Next Steps:
1. Make some changes to files
2. Create new files
3. Then commit again

Or if you're done:
- Push your commits: git push
- View history: git log --oneline -5
```

#### Scenario B: Files Modified But Not Saved

```
NO CHANGES TO COMMIT
━━━━━━━━━━━━━━━━━━━━

Possible Reason: Files Not Saved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Git sees no changes because:
- You edited files but didn't save them
- Changes are in your editor buffer

Actions:
1. Save all files in your editor (Ctrl+S or Cmd+S)
2. Check git status again:
   git status
3. If files appear, stage and commit:
   git add .
   git commit
```

#### Scenario C: Wrong Directory

```
NO CHANGES TO COMMIT
━━━━━━━━━━━━━━━━━━━━

Possible Reason: Wrong Directory
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current directory: /path/to/current
Changes might be elsewhere.

Actions:
1. Verify you're in the right place:
   pwd
   ls

2. Navigate to project root:
   cd /path/to/project

3. Check status there:
   git status
```

#### Scenario D: Files Ignored

```
NO CHANGES TO COMMIT
━━━━━━━━━━━━━━━━━━━━

Possible Reason: Files Ignored by .gitignore
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Git might be ignoring your files.

Check:
1. View ignored patterns:
   cat .gitignore

2. Check if file is ignored:
   git check-ignore -v <filename>

3. Force add ignored files (if needed):
   git add -f <filename>

Note: Be careful adding ignored files - they're usually
ignored for good reason (node_modules, .env, etc.)
```

### 4. Detect Edge Cases

Check for:
- **Unstaged changes in subdirectories**
  ```bash
  git status --porcelain
  ```

- **Changes to ignored files only**
  ```bash
  git status --ignored
  ```

- **Accidentally reset changes**
  ```bash
  git reflog -5
  ```

### 5. Interactive Verification

Guide user to verify:

```
Let's verify your changes:

1. List all files in directory:
   ls -la

2. Check git status:
   git status

3. Check recent history:
   git log --oneline -3

Do you see the files you expected to commit?
```

## Error Handling

### If git status fails
```
Unable to check git status.
Ensure you're in a git repository.
Run: /commit-error-handling handle-no-repo
```

### If permissions issues
```
Permission denied reading files.
Check file permissions: ls -la
```

## Output Format

Always provide:
1. **Clear status** - What git sees
2. **Explanation** - Why there are no changes
3. **Likely causes** - Ordered by probability
4. **Specific actions** - Commands to verify/fix
5. **Next steps** - What to do after resolution

## Success Indicators

After user follows guidance:
- User understands why there were no changes
- Changes appear in `git status`
- User can proceed with commit
- Or user understands work is already committed

## Related Operations

- Run **diagnose-issues** for comprehensive check
- After making changes, verify with **commit-analysis/analyze-changes**

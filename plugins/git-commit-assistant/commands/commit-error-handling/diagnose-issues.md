# Operation: Diagnose Issues

Comprehensive git repository issue diagnosis.

## Purpose

Run all diagnostic checks and provide a complete health report of the repository state, identifying any issues that could prevent commits or other git operations.

## Parameters

None required - runs complete diagnostic suite.

## Workflow

### 1. Run All Diagnostic Scripts

Execute all diagnostic utilities in parallel:

#### Check Repository Validity
```bash
REPO_RESULT=$(/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/repo-checker.sh)
```

#### Check for Changes
```bash
CHANGES_RESULT=$(/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/changes-detector.sh)
```

#### Check for Conflicts
```bash
CONFLICTS_RESULT=$(/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/conflict-detector.py)
```

#### Check Repository State
```bash
STATE_RESULT=$(/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/commit-error-handling/.scripts/state-analyzer.sh)
```

### 2. Check Git Configuration

Verify git is properly configured:

```bash
# User name
USER_NAME=$(git config user.name)
USER_EMAIL=$(git config user.email)

# Verify both are set
if [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ]; then
    CONFIG_STATUS="missing"
else
    CONFIG_STATUS="configured"
fi
```

### 3. Check Remote Status

Verify remote connectivity and status:

```bash
# Check if remote exists
git remote -v

# Check remote connection (if exists)
git ls-remote --exit-code origin &>/dev/null
REMOTE_STATUS=$?

# Check if ahead/behind remote
git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null
```

### 4. Aggregate Results

Combine all diagnostic results into comprehensive report.

### 5. Present Comprehensive Diagnosis

#### Example Output Format

```
GIT REPOSITORY DIAGNOSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository Information:
━━━━━━━━━━━━━━━━━━━━━
Location: /home/user/project
Branch: feature-auth
Repository: Valid ✅

Repository State:
━━━━━━━━━━━━━━━━
HEAD State: Attached ✅
Current Branch: feature-auth ✅
Remote Status: Up to date ✅

Changes Status:
━━━━━━━━━━━━━━━
Has Changes: Yes ✅
Staged Files: 3
Unstaged Files: 2
Untracked Files: 1
Total Changes: 6

Conflicts:
━━━━━━━━━━
Merge Conflicts: None ✅
Conflict Count: 0

Configuration:
━━━━━━━━━━━━━━
User Name: John Doe ✅
User Email: john@example.com ✅
Git Version: 2.39.0 ✅

Remote:
━━━━━━━
Remote Name: origin ✅
Remote URL: github.com/user/repo ✅
Connection: Reachable ✅
Ahead: 2 commits
Behind: 0 commits

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: HEALTHY ✅

Summary:
✅ Repository is valid and properly configured
✅ Git configuration complete
✅ No merge conflicts
✅ Changes ready to commit
✅ Remote connection working

You can proceed with git operations.

Next Steps:
1. Review changes: git status
2. Commit changes: git commit
3. Push to remote: git push
```

#### Example with Issues

```
GIT REPOSITORY DIAGNOSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository Information:
━━━━━━━━━━━━━━━━━━━━━
Location: /home/user/project
Branch: (detached HEAD)
Repository: Valid ✅

Repository State:
━━━━━━━━━━━━━━━━
HEAD State: Detached ⚠️
Current Branch: (none)
Remote Status: Cannot determine

Changes Status:
━━━━━━━━━━━━━━━
Has Changes: Yes ✅
Staged Files: 0
Unstaged Files: 5
Untracked Files: 2
Total Changes: 7

Conflicts:
━━━━━━━━━━
Merge Conflicts: YES ❌
Conflicted Files: 2
  - src/auth/oauth.js
  - src/api/users.js

Configuration:
━━━━━━━━━━━━━━
User Name: (not set) ❌
User Email: (not set) ❌
Git Version: 2.39.0 ✅

Remote:
━━━━━━━
Remote Name: origin ✅
Remote URL: github.com/user/repo ✅
Connection: Failed ❌

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: ISSUES DETECTED ⚠️

Issues Found: 4
Priority: HIGH ❌

CRITICAL ISSUES:
━━━━━━━━━━━━━━━━

1. Merge Conflicts Present ❌
   Impact: Cannot commit until resolved
   Files affected: 2
   Action: /commit-error-handling handle-conflicts

2. Git Configuration Missing ❌
   Impact: Cannot commit without user.name and user.email
   Action: Configure git:
           git config user.name "Your Name"
           git config user.email "your@email.com"

WARNINGS:
━━━━━━━━━

3. Detached HEAD State ⚠️
   Impact: New commits won't be on a branch
   Action: /commit-error-handling handle-detached-head

4. Remote Connection Failed ⚠️
   Impact: Cannot push changes
   Possible causes: Network issues, authentication
   Action: Check network and credentials

RECOMMENDED RESOLUTION ORDER:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. First: Resolve merge conflicts
   → /commit-error-handling handle-conflicts

2. Then: Configure git user
   → git config user.name "Your Name"
   → git config user.email "your@email.com"

3. Then: Fix detached HEAD
   → /commit-error-handling handle-detached-head

4. Finally: Test remote connection
   → git fetch origin

After resolving all issues, run:
/commit-error-handling diagnose-issues
```

### 6. Provide Specific Recommendations

Based on findings, provide targeted guidance:

#### If no issues found

```
✅ ALL CHECKS PASSED

Your repository is in good health.

Ready for:
- Committing changes
- Pushing to remote
- Branching
- Merging
- All git operations

Proceed with your intended git operation.
```

#### If issues found

Priority-ordered resolution plan:

```
RESOLUTION PLAN
━━━━━━━━━━━━━━━

CRITICAL (must fix first):
1. Issue: Merge conflicts
   Command: /commit-error-handling handle-conflicts
   Estimated time: 10-30 minutes

2. Issue: Git config missing
   Command: git config user.name "Your Name"
            git config user.email "your@email.com"
   Estimated time: 1 minute

HIGH (should fix):
3. Issue: Detached HEAD
   Command: /commit-error-handling handle-detached-head
   Estimated time: 2 minutes

MEDIUM (can fix later):
4. Issue: Remote connection
   Check network, verify credentials
   Estimated time: 5 minutes
```

### 7. Export Detailed Report

Optionally save full diagnostic report:

```bash
# Save to file
cat > git-diagnosis.txt <<EOF
[Full diagnosis output]
EOF

echo "Full report saved to: git-diagnosis.txt"
```

## Diagnostic Categories

### 1. Repository Validity
- Is this a git repository?
- Is .git directory valid?
- Is repository corrupted?

### 2. Repository State
- HEAD attached or detached?
- Current branch name
- Clean or dirty working tree?

### 3. Changes Detection
- Staged changes count
- Unstaged changes count
- Untracked files count
- Total changes

### 4. Conflicts
- Any merge conflicts?
- Conflicted file list
- Merge/rebase in progress?

### 5. Configuration
- user.name set?
- user.email set?
- Other critical config

### 6. Remote Status
- Remote configured?
- Remote reachable?
- Ahead/behind status
- Push/pull needed?

### 7. Branch Status
- On a branch?
- Branch tracking remote?
- Up to date with remote?

## Error Handling

### If critical git command fails

```
Unable to run git commands.

Possible causes:
- Git not installed
- Current directory has permission issues
- Repository is corrupted

Actions:
1. Verify git is installed:
   git --version

2. Check current directory:
   pwd
   ls -la

3. Try from different directory
```

### If partial diagnosis succeeds

```
Partial diagnosis completed.

Completed checks:
✅ Repository validity
✅ Changes detection
❌ Remote status (failed)
❌ Branch status (failed)

Showing results from successful checks...

Note: Some checks failed. This may indicate:
- Network issues
- Permission problems
- Repository corruption
```

## Output Format

The diagnosis always provides:

1. **Executive Summary** - Overall status at a glance
2. **Detailed Sections** - Each diagnostic category
3. **Issue List** - All problems found, prioritized
4. **Resolution Plan** - Ordered steps to fix issues
5. **Next Actions** - Specific commands to run
6. **Success Indicators** - How to verify fixes

Use visual indicators:
- ✅ Pass
- ❌ Fail
- ⚠️ Warning
- ℹ️ Info

## Success Indicators

After diagnosis:
- User understands complete repository state
- All issues identified and prioritized
- Clear action plan provided
- User knows exact commands to run
- Estimated effort/time provided

## Integration with Other Operations

The diagnosis operation orchestrates all error handling:

```
If repository invalid:
  → Route to: handle-no-repo

If no changes:
  → Route to: handle-no-changes

If conflicts found:
  → Route to: handle-conflicts

If detached HEAD:
  → Route to: handle-detached-head

If all pass:
  → Ready to proceed with commit workflow
```

## Usage Patterns

### Pre-commit Check
```bash
# Before attempting commit
/commit-error-handling diagnose-issues

# If all clear:
/commit-analysis analyze
/message-generation complete-message
```

### Troubleshooting
```bash
# When git operations fail
/commit-error-handling diagnose-issues

# Follow recommended resolution order
```

### Repository Health Check
```bash
# Periodic verification
/commit-error-handling diagnose-issues

# Ensure repository is in good state
```

## Related Operations

- Comprehensive entry point that may route to any other operation
- **handle-no-repo** - If repository invalid
- **handle-no-changes** - If no changes detected
- **handle-conflicts** - If conflicts found
- **handle-detached-head** - If HEAD detached
- After fixes, re-run **diagnose-issues** to verify

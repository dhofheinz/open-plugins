# Operation: Commit Revert Guidance

Guide users through safely reverting commits with proper formatting and workflow.

## Parameters from $ARGUMENTS

- **commit** (required): Commit SHA to revert

Parse as: `revert-guidance commit:abc123`

## Revert Workflow

### Step 1: Validate Commit

Verify commit exists and get details:

```bash
# Check if commit exists
if ! git rev-parse --verify ${commit} >/dev/null 2>&1; then
    ERROR: "Commit not found: ${commit}"
    exit 1
fi

# Get commit details
commit_sha=$(git rev-parse ${commit})
commit_subject=$(git log -1 --format='%s' ${commit_sha})
commit_author=$(git log -1 --format='%an <%ae>' ${commit_sha})
commit_date=$(git log -1 --format='%ad' ${commit_sha})
```

### Step 2: Run Revert Helper Script

Generate proper revert commit message:

```bash
./.claude/commands/commit-best-practices/.scripts/revert-helper.sh "${commit_sha}"
```

Returns:
```json
{
  "commit": "abc123...",
  "original_message": "feat(auth): add OAuth authentication",
  "revert_message": "revert: feat(auth): add OAuth authentication\n\nThis reverts commit abc123.\n\nReason: OAuth implementation incompatible with current auth system",
  "type": "feat",
  "scope": "auth",
  "files_affected": 5,
  "safe_to_revert": true,
  "warnings": []
}
```

### Step 3: Analyze Revert Safety

Check if revert will cause issues:

**Safe to revert:**
```
✅ Safe to revert

Commit: abc123
Original: feat(auth): add OAuth authentication
Author: John Doe
Date: 2025-10-10

Analysis:
  ✅ No dependent commits found
  ✅ No merge conflicts expected
  ✅ Files still exist
  ✅ Clean revert possible

This commit can be safely reverted.
```

**Potential issues:**
```
⚠️  Revert with caution

Commit: abc123
Original: feat(auth): add OAuth authentication
Author: John Doe
Date: 2025-10-10

Warnings:
  ⚠️  3 commits depend on this change
      - def456: feat(auth): add OAuth providers
      - ghi789: fix(auth): OAuth token refresh
      - jkl012: docs: OAuth setup guide

  ⚠️  Potential merge conflicts
      - src/auth/oauth.js: modified in later commits
      - src/config/auth.js: modified in later commits

Reverting will require:
  1. Resolving merge conflicts
  2. Possibly reverting dependent commits first
  3. Updating or removing affected features

Consider: Revert dependent commits in reverse order.
```

### Step 4: Generate Revert Message

Follow proper revert commit message format:

```
Conventional Commits Revert Format:
-----------------------------------
revert: <original-type>(<original-scope>): <original-subject>

This reverts commit <sha>.

Reason: <explanation-of-why>

[Optional: Additional context]
[Optional: BREAKING CHANGE if revert breaks functionality]
[Optional: Issue references]

Example:
-----------------------------------
revert: feat(auth): add OAuth authentication

This reverts commit abc123def456789.

Reason: OAuth implementation incompatible with existing SAML
authentication system. Caused authentication failures for
enterprise users.

Need to redesign OAuth to work alongside SAML before
reintroducing.

BREAKING CHANGE: OAuth authentication temporarily removed.
Users must use username/password authentication.

Refs: #456
```

### Step 5: Provide Revert Instructions

**Simple revert (no conflicts):**

```
How to Revert Commit
====================

Commit to revert: abc123
Original message: feat(auth): add OAuth authentication

Generated revert message:
---
revert: feat(auth): add OAuth authentication

This reverts commit abc123.

Reason: [Provide reason here]
---

Option 1: Auto-revert with Git (Recommended)
---------------------------------------------
git revert abc123

This will:
  1. Create revert commit automatically
  2. Open editor for message (pre-filled)
  3. Add reason for revert
  4. Save and close

Option 2: Manual revert
-----------------------
1. git revert --no-commit abc123
2. Review changes: git diff --cached
3. Adjust if needed
4. git commit (use message above)

After reverting:
----------------
1. Test that functionality is restored
2. Verify no broken dependencies
3. Push: git push origin <branch>

The revert commit preserves history while undoing changes.
```

**Complex revert (conflicts or dependencies):**

```
Complex Revert Required
=======================

Commit to revert: abc123
Original: feat(auth): add OAuth authentication
Dependencies: 3 commits depend on this

Revert Strategy:
----------------

Step 1: Revert dependent commits FIRST (newest to oldest)
  git revert jkl012  # docs: OAuth setup guide
  git revert ghi789  # fix(auth): OAuth token refresh
  git revert def456  # feat(auth): add OAuth providers

Step 2: Revert original commit
  git revert abc123  # feat(auth): add OAuth authentication

Step 3: Handle conflicts
  If conflicts occur:
    1. git status (see conflicted files)
    2. Edit files to resolve conflicts
    3. git add <resolved-files>
    4. git revert --continue

Step 4: Test thoroughly
  - Run full test suite
  - Verify auth system works
  - Check for broken functionality

Alternative: Revert in single commit
-------------------------------------
If you want one revert commit for all:

1. git revert --no-commit jkl012
2. git revert --no-commit ghi789
3. git revert --no-commit def456
4. git revert --no-commit abc123
5. Resolve any conflicts
6. git commit -m "revert: OAuth authentication feature

This reverts commits abc123, def456, ghi789, jkl012.

Reason: OAuth incompatible with SAML system."

This creates a single revert commit for multiple changes.
```

### Step 6: Post-Revert Checklist

After reverting, verify:

```
Post-Revert Checklist
=====================

□ Revert commit created successfully
  git log -1 (verify revert commit exists)

□ Changes actually reverted
  git diff <commit>^..<commit> (should be inverse of original)

□ Tests pass
  npm test (or your test command)

□ No broken functionality
  Test affected features manually

□ Documentation updated
  Update docs if feature was documented

□ Team notified
  Inform team of revert and reason

□ Issue tracker updated
  Comment on related issues

□ Ready to push
  git push origin <branch>
```

## Revert vs Reset vs Amend

**Use `git revert` when:**
- ✅ Commit already pushed to remote
- ✅ Working on shared branch
- ✅ Need to preserve history
- ✅ Undoing specific commit in middle of history

**Use `git reset` when:**
- ⚠️ Commit not yet pushed (local only)
- ⚠️ Want to completely remove commit
- ⚠️ Rewriting personal branch history
- ⚠️ No one else has the commit

**Use `git commit --amend` when:**
- ⚠️ Fixing most recent commit only
- ⚠️ Commit not yet pushed
- ⚠️ Small typo or forgotten file

**Decision tree:**
```
Has commit been pushed?
├─ Yes → Use git revert (safe for shared history)
└─ No → Is it the most recent commit?
    ├─ Yes → Use git commit --amend (if minor fix)
    └─ No → Use git reset (if complete removal needed)
```

## Revert Message Examples

**Example 1: Bug found**
```
revert: fix(api): add null check in user endpoint

This reverts commit abc123.

Reason: Fix introduced regression causing authentication
failures for legacy clients. Null check logic incorrect.

Will reimplement with proper validation after adding tests.

Fixes: #789
```

**Example 2: Performance issue**
```
revert: perf(search): implement new search algorithm

This reverts commit def456.

Reason: New algorithm causes 300% increase in database
load under production traffic. Needs optimization before
redeployment.

Keeping old algorithm until performance issues resolved.
```

**Example 3: Breaking change**
```
revert: feat(api): change authentication endpoint format

This reverts commit ghi789.

Reason: Breaking change deployed without proper migration
period. Mobile app version 1.x incompatible with new format.

BREAKING CHANGE: Reverting API format to v1 for backwards
compatibility. Will reintroduce in v2 with migration path.

Refs: #234, #235, #236 (user reports)
```

## Output Format

```
Revert Guidance Report
======================

Commit to Revert: <sha>
Original Message: <message>
Author: <name>
Date: <date>

REVERT SAFETY:
  [✅|⚠️] No dependent commits
  [✅|⚠️] No merge conflicts expected
  [✅|⚠️] Files still exist

GENERATED REVERT MESSAGE:
---
<revert-message-content>
---

REVERT INSTRUCTIONS:
[Step-by-step instructions]

POST-REVERT CHECKLIST:
[Verification steps]
```

## Error Handling

**Commit not found:**
```
ERROR: Commit not found: abc123
Check: git log (to see available commits)
Verify: Commit hash is correct (7+ characters)
```

**Already reverted:**
```
WARNING: This commit may already be reverted

Found revert commit: xyz789
Message: "revert: feat(auth): add OAuth authentication"

If this is a duplicate revert, it may cause issues.
Check: git log (to verify)
```

**Merge commit:**
```
WARNING: This is a merge commit

Merge commits require special handling:
git revert -m 1 abc123

-m 1: Keep changes from first parent
-m 2: Keep changes from second parent

Determine which parent to keep based on your branch strategy.
```

## Integration with Agent

When user says "revert my commit" or "undo commit abc123":
1. Agent identifies commit to revert
2. Runs safety analysis
3. Generates proper revert message
4. Provides step-by-step instructions
5. Offers post-revert verification checklist

## Best Practices

1. **Always provide reason**: Explain WHY reverting in message
2. **Reference original commit**: Include SHA in revert message
3. **Test after revert**: Ensure functionality restored
4. **Notify team**: Communicate reverts to collaborators
5. **Update issues**: Comment on related issue tracker items
6. **Preserve history**: Use revert, not reset, for shared branches

Proper reverts maintain clear history and facilitate collaboration.

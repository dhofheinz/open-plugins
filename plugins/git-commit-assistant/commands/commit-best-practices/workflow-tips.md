# Operation: Git Workflow Tips and Best Practices

Comprehensive git workflow guidance covering commits, branches, merging, and collaboration.

## Parameters from $ARGUMENTS

- **focus** (optional): Specific area (commit|branch|merge|all) (default: all)

Parse as: `workflow-tips focus:commit` or `workflow-tips`

## Workflow Guidance

Route to specific section based on focus parameter:

### Focus: Commit Workflow

**Complete commit workflow best practices:**

```
Git Commit Workflow Best Practices
===================================

1. BEFORE YOU CODE
------------------
□ Create feature branch
  git checkout -b feature/your-feature-name

□ Pull latest changes
  git pull origin main

□ Verify clean state
  git status


2. WHILE CODING
---------------
□ Commit frequently (atomic commits)
  - After each logical change
  - Not too small (typo fixes can be bundled)
  - Not too large (avoid 1000+ line commits)

□ Test before committing
  npm test (or your test command)

□ Keep commits focused
  - One concern per commit
  - Don't mix features and fixes
  - Don't mix multiple scopes


3. BEFORE COMMITTING
--------------------
□ Review your changes
  git diff (see what changed)
  git status (see staged/unstaged)

□ Stage selectively
  git add <specific-files>
  (Don't blindly: git add .)

□ Run pre-commit checks
  /commit-best-practices check-pre-commit

□ Remove debug code
  - console.log, print statements
  - debugger statements
  - Temporary test code


4. CREATING COMMIT
------------------
□ Use conventional commits format
  <type>(<scope>): <subject>

□ Write clear subject (≤50 chars)
  - Imperative mood: "add" not "added"
  - Lowercase after type
  - No period at end

□ Add descriptive body (if needed)
  - Explain WHY, not what
  - Wrap at 72 characters
  - Use bullet points

□ Include footer (if applicable)
  - BREAKING CHANGE: description
  - Closes #123


5. AFTER COMMITTING
-------------------
□ Review commit
  /commit-best-practices review-commit
  git show HEAD

□ Verify tests still pass
  npm test

□ Push to remote
  git push origin <branch>

□ Create pull request (if ready)
  gh pr create


6. COMMON MISTAKES TO AVOID
---------------------------
❌ "WIP" or "work in progress" commits
   → Finish work before committing

❌ "Fix" or "update" without context
   → Be specific: "fix(auth): null pointer in OAuth"

❌ Committing all changes at once
   → Split into atomic commits

❌ Forgetting to add tests
   → Tests should accompany code changes

❌ Committing node_modules or .env files
   → Use .gitignore properly

❌ Force pushing to shared branches
   → Only force push on personal branches


7. COMMIT CHECKLIST
-------------------
Before every commit, verify:

□ Changes are atomic (single logical change)
□ Tests pass
□ No debug code
□ No TODOs in committed code
□ Message follows conventions
□ Includes tests (if new functionality)
□ Documentation updated (if needed)

Use: /commit (agent handles checklist automatically)
```

### Focus: Branch Workflow

**Branch management best practices:**

```
Git Branch Workflow Best Practices
===================================

1. BRANCH NAMING CONVENTIONS
-----------------------------
Follow consistent naming:

Feature branches:
  feature/oauth-authentication
  feature/user-profile-page

Bug fixes:
  fix/null-pointer-in-auth
  fix/memory-leak-in-parser

Hotfixes:
  hotfix/security-vulnerability
  hotfix/production-crash

Experiments:
  experiment/new-algorithm
  experiment/performance-optimization

Pattern: <type>/<brief-description>
Use: lowercase-with-hyphens


2. BRANCH LIFECYCLE
-------------------
Create → Develop → Test → Merge → Delete

Create:
  git checkout -b feature/my-feature
  (Always branch from main/develop)

Develop:
  - Commit frequently
  - Push regularly
  - Keep branch updated

Test:
  - Run full test suite
  - Manual testing
  - Code review

Merge:
  - Create pull request
  - Address review feedback
  - Merge to main

Delete:
  git branch -d feature/my-feature
  git push origin --delete feature/my-feature


3. KEEPING BRANCHES UPDATED
---------------------------
Regularly sync with main branch:

Option 1: Rebase (cleaner history)
  git checkout feature/my-feature
  git fetch origin
  git rebase origin/main

Option 2: Merge (preserves history)
  git checkout feature/my-feature
  git merge origin/main

Recommendation: Use rebase for feature branches,
merge for shared branches.


4. BRANCH PROTECTION RULES
---------------------------
Protect important branches:

Main/Master:
  - Require pull request
  - Require code review
  - Require passing tests
  - Block force push
  - Block deletion

Develop:
  - Require pull request
  - Require passing tests
  - Allow force push with lease

Feature:
  - No restrictions
  - Personal branches


5. LONG-RUNNING BRANCHES
-------------------------
If branch lives more than a few days:

□ Sync with main frequently (daily)
□ Keep commits atomic and clean
□ Push to remote regularly
□ Communicate with team
□ Consider splitting into smaller branches


6. BRANCH STRATEGIES
--------------------
Choose strategy based on team size:

Git Flow (large teams):
  - main: production
  - develop: integration
  - feature/*: new features
  - release/*: release prep
  - hotfix/*: urgent fixes

GitHub Flow (small teams):
  - main: production
  - feature/*: all work
  (Simple and effective)

Trunk-Based (continuous deployment):
  - main: always deployable
  - Short-lived feature branches
  - Feature flags for incomplete work


7. COMMON BRANCH MISTAKES
--------------------------
❌ Working directly on main
   → Always use feature branches

❌ Branches that live for weeks
   → Split into smaller branches

❌ Not syncing with main regularly
   → Causes massive merge conflicts

❌ Unclear branch names (branch1, temp)
   → Use descriptive names

❌ Leaving merged branches
   → Delete after merging

❌ Force pushing shared branches
   → Only force push personal branches
```

### Focus: Merge Workflow

**Merge and pull request best practices:**

```
Git Merge Workflow Best Practices
==================================

1. BEFORE CREATING PULL REQUEST
-------------------------------
□ All commits are atomic
  /commit-review (check quality)

□ Branch is up-to-date
  git fetch origin
  git rebase origin/main

□ All tests pass
  npm test (full suite)

□ No merge conflicts
  Resolve before creating PR

□ Code is reviewed locally
  Self-review your changes


2. CREATING PULL REQUEST
------------------------
Good PR title:
  feat(auth): Add OAuth authentication support

Good PR description:
  ## Summary
  Implements OAuth 2.0 authentication for Google and GitHub.

  ## Changes
  - OAuth configuration system
  - Provider implementations (Google, GitHub)
  - Token refresh mechanism
  - Middleware integration

  ## Testing
  - Unit tests: 15 added
  - Integration tests: 3 added
  - Manual testing: OAuth flows verified

  ## Screenshots (if UI)
  [Include screenshots]

  Closes #123


3. CODE REVIEW PROCESS
----------------------
As author:
  □ Respond to all comments
  □ Make requested changes
  □ Push new commits (don't amend!)
  □ Re-request review when ready
  □ Be open to feedback

As reviewer:
  □ Review code thoroughly
  □ Check tests are included
  □ Verify documentation updated
  □ Test locally if possible
  □ Be constructive in feedback


4. MERGE STRATEGIES
-------------------
Choose appropriate merge strategy:

Merge Commit (default):
  git merge --no-ff feature/my-feature
  - Preserves complete history
  - Shows where feature was merged
  - Creates merge commit
  Use for: Significant features

Squash Merge:
  git merge --squash feature/my-feature
  - Combines all commits into one
  - Clean linear history
  - Loses individual commit detail
  Use for: Small features, many WIP commits

Rebase Merge:
  git rebase main
  git merge --ff-only
  - Linear history
  - No merge commit
  - Clean git log
  Use for: Personal branches, small changes


5. RESOLVING MERGE CONFLICTS
-----------------------------
When conflicts occur:

Step 1: Identify conflicts
  git status (shows conflicted files)

Step 2: Open conflicted file
  Conflict markers:
    <<<<<<< HEAD
    Your changes
    =======
    Their changes
    >>>>>>> feature/branch

Step 3: Resolve conflict
  - Choose one version, or
  - Combine both versions, or
  - Write new solution

Step 4: Remove conflict markers
  Delete <<<<<<<, =======, >>>>>>>

Step 5: Mark as resolved
  git add <resolved-file>

Step 6: Complete merge
  git merge --continue
  (or git rebase --continue)

Step 7: Test thoroughly
  npm test
  Manual testing


6. AFTER MERGING
----------------
□ Delete feature branch
  git branch -d feature/my-feature
  git push origin --delete feature/my-feature

□ Verify merge on main
  git checkout main
  git pull origin main
  git log (verify commit appears)

□ Run tests on main
  npm test

□ Deploy if applicable
  (Follow deployment process)

□ Update issue tracker
  Close related issues

□ Notify stakeholders
  Team notification of merge


7. MERGE BEST PRACTICES
------------------------
✅ Merge frequently (avoid long-lived branches)
✅ Require code review before merge
✅ Ensure tests pass before merge
✅ Delete branches after merge
✅ Use meaningful merge commit messages
✅ Squash "fix review comments" commits

❌ Don't merge failing tests
❌ Don't merge without review
❌ Don't merge with unresolved conflicts
❌ Don't merge incomplete features to main
❌ Don't forget to pull after merge
```

### Focus: All (Complete Workflow)

When `focus:all` or no focus specified, provide comprehensive overview:

```
Complete Git Workflow Guide
============================

Quick Reference for Git Best Practices

DAILY WORKFLOW
--------------
1. Start day: git pull origin main
2. Create branch: git checkout -b feature/name
3. Code & commit frequently (atomic commits)
4. Test before each commit
5. Push regularly: git push origin feature/name
6. Create PR when ready
7. Address review feedback
8. Merge and delete branch
9. Pull updated main

COMMIT GUIDELINES
-----------------
Format: <type>(<scope>): <subject>

Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore

Subject: ≤50 chars, imperative, lowercase, no period
Body: Wrap at 72 chars, explain WHY
Footer: BREAKING CHANGE, Closes #123

BRANCH STRATEGY
---------------
- main: production-ready code
- feature/*: new features
- fix/*: bug fixes
- hotfix/*: urgent production fixes

Keep branches short-lived (< 1 week)
Sync with main daily
Delete after merging

MERGE PROCESS
-------------
1. Rebase on main: git rebase origin/main
2. Resolve conflicts
3. All tests pass
4. Code review approved
5. Merge to main
6. Delete feature branch

TOOLS TO USE
------------
/commit - Create commit with agent assistance
/commit-review - Review commit quality
/commit-split - Split non-atomic commits
/commit-best-practices check-pre-commit - Validate before commit
/commit-best-practices review-commit - Review commit after creation
/commit-best-practices amend-guidance - Safe amend help
/commit-best-practices revert-guidance - Revert help

COMMON COMMANDS
---------------
git status                    # Check status
git diff                      # See changes
git add <files>              # Stage changes
git commit                   # Create commit
git push origin <branch>     # Push to remote
git pull origin main         # Get latest main
git log --oneline -10        # Recent commits
git show HEAD                # Show last commit

EMERGENCY PROCEDURES
--------------------
Committed to wrong branch:
  git reset --soft HEAD~1
  git checkout correct-branch
  git commit

Pushed wrong commit:
  git revert HEAD
  git push

Need to undo local changes:
  git checkout -- <file>
  (or git restore <file>)

Accidentally deleted branch:
  git reflog
  git checkout -b branch-name <sha>

For more detailed guidance on specific areas:
  /commit-best-practices workflow-tips focus:commit
  /commit-best-practices workflow-tips focus:branch
  /commit-best-practices workflow-tips focus:merge
```

## Output Format

Provide guidance formatted with:
- Clear section headers
- Checkboxes for actionable items
- Code examples with syntax highlighting
- Visual indicators (✅ ❌ ⚠️)
- Step-by-step instructions
- Common pitfalls and solutions

## Error Handling

**Invalid focus parameter:**
```
ERROR: Invalid focus: invalid-focus
Valid options: commit, branch, merge, all
Example: /commit-best-practices workflow-tips focus:commit
```

## Integration with Agent

Proactively suggest workflow tips when:
- User commits to main branch directly (suggest feature branch)
- Branch hasn't been synced in 3+ days (suggest rebase)
- PR has many commits (suggest squash)
- User attempts unsafe operation (provide guidance)

## Best Practices Summary

**The Golden Rules:**

1. **Commit often** - Atomic, focused commits
2. **Test always** - Before every commit
3. **Branch per feature** - Isolate work
4. **Sync regularly** - Stay updated with main
5. **Review thoroughly** - All code reviewed
6. **Merge cleanly** - No conflicts, passing tests
7. **Delete branches** - After merging
8. **Communicate** - Keep team informed

**Tools make it easier:**
Use `/commit` and related skills to automate best practices and ensure consistent, high-quality commits.

These workflows ensure clean history, facilitate collaboration, and make debugging easier when issues arise.

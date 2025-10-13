# Commit Best Practices Skill - Usage Examples

## Quick Reference

```bash
# Pre-commit validation (full)
/commit-best-practices check-pre-commit

# Pre-commit validation (quick - skip tests/lint)
/commit-best-practices check-pre-commit quick:true

# Review last commit
/commit-best-practices review-commit

# Review specific commit
/commit-best-practices review-commit commit:abc123

# Check if safe to amend
/commit-best-practices amend-guidance

# Amend with force (bypass safety)
/commit-best-practices amend-guidance force:true

# Revert guidance for commit
/commit-best-practices revert-guidance commit:abc123

# Workflow tips (all)
/commit-best-practices workflow-tips

# Workflow tips (specific focus)
/commit-best-practices workflow-tips focus:commit
/commit-best-practices workflow-tips focus:branch
/commit-best-practices workflow-tips focus:merge
```

## Workflow Example 1: Safe Commit Flow

```
Developer: "I want to commit my changes"

Agent:
  1. Runs: /commit-best-practices check-pre-commit
  2. IF checks fail:
     - Shows: "Tests failing, debug code found"
     - Blocks commit
     - Provides guidance to fix
  3. IF checks pass:
     - Continues with commit workflow
     - Generates message
     - Creates commit
     - Reviews commit quality
```

## Workflow Example 2: Amend Safety Check

```
Developer: "I need to amend my last commit"

Agent:
  1. Runs: /commit-best-practices amend-guidance
  2. Checks:
     - Not pushed to remote? ✓
     - Same author? ✓
     - Not on main/master? ✓
  3. Result: SAFE - provides amend instructions
  
  OR if unsafe:
  
  3. Result: UNSAFE - commit already pushed
     - Shows alternatives (new commit, revert)
     - Blocks amend
```

## Workflow Example 3: Commit Review & Improvement

```
Developer commits code

Agent (automatically):
  1. Runs: /commit-best-practices review-commit
  2. Analyzes:
     - Message quality: GOOD
     - Atomicity: ✓ single feature
     - Tests: ⚠ missing
     - Score: 72/100
  3. Suggests:
     - "Good commit! Consider adding unit tests."
     - "Safe to push with minor note."
```

## Script Output Examples

### pre-commit-check.sh

```json
{
  "status": "fail",
  "quick_mode": false,
  "checks": {
    "tests": {"status": "fail", "message": "Tests failing"},
    "lint": {"status": "pass", "message": "Linting passed"},
    "debug_code": {"status": "fail", "count": 3, "locations": ["src/auth.js:42: console.log(user)"]},
    "todos": {"status": "warn", "count": 1, "locations": ["src/auth.js:56: TODO: refactor"]},
    "merge_markers": {"status": "pass", "count": 0, "locations": []}
  }
}
```

### commit-reviewer.py

```json
{
  "commit": "abc123",
  "author": "John Doe <john@example.com>",
  "date": "2025-10-13",
  "message": {
    "subject": "feat(auth): add OAuth authentication",
    "subject_length": 38,
    "conventional": true,
    "type": "feat",
    "scope": "auth"
  },
  "changes": {
    "files_changed": 5,
    "insertions": 234,
    "deletions": 12,
    "test_files": 1
  },
  "quality": {
    "atomic": true,
    "message_quality": "excellent",
    "test_coverage": true,
    "issues": []
  },
  "score": 95
}
```

### amend-safety.sh

```json
{
  "safe": true,
  "recommendation": "safe",
  "commit": "abc123",
  "author": "John Doe <john@example.com>",
  "branch": "feature/oauth",
  "checks": {
    "not_pushed": {"status": "pass", "message": "Commit not pushed to origin/feature/oauth"},
    "same_author": {"status": "pass", "message": "You are the commit author"},
    "safe_branch": {"status": "pass", "message": "On feature branch: feature/oauth"},
    "collaborators": {"status": "pass", "message": "Solo work on branch"}
  }
}
```

### revert-helper.sh

```json
{
  "commit": "abc123",
  "original_message": "feat(auth): add OAuth authentication",
  "type": "feat",
  "scope": "auth",
  "files_affected": 5,
  "revert_message": "revert: feat(auth): add OAuth authentication\n\nThis reverts commit abc123.\n\nReason: [Provide reason here]",
  "safety": {
    "safe_to_revert": true,
    "warnings": [],
    "dependent_count": 0
  }
}
```

## Integration with Other Skills

```
/commit-best-practices check-pre-commit
  ↓ (if pass)
/commit-analysis analyze
  ↓
/message-generation complete-message
  ↓
/commit (create commit)
  ↓
/commit-best-practices review-commit
  ↓ (if score < 70)
/commit-best-practices amend-guidance
```

## Best Practices Enforced

1. **Tests must pass** - No commits with failing tests
2. **No debug code** - No console.log, debugger in commits
3. **No TODOs** - Fix or remove before committing
4. **No merge markers** - Resolve conflicts fully
5. **Atomic commits** - One logical change per commit
6. **Quality messages** - Conventional commits format
7. **Safe amends** - Only amend unpushed commits
8. **Proper reverts** - Use revert for shared history

## Common Scenarios

### Scenario 1: Debug Code Found

```
Pre-commit check fails:
  ❌ Debug code: 3 instances found
     - src/auth.js:42: console.log(user)
     - src/api.js:18: debugger statement

Action: Remove debug code, re-stage files, retry
```

### Scenario 2: Tests Failing

```
Pre-commit check fails:
  ❌ Tests: 2 failing
     - test/auth.test.js: OAuth flow test

Action: Fix tests, verify passing, retry
```

### Scenario 3: Unsafe Amend

```
Amend safety check:
  ❌ UNSAFE: Commit already pushed to remote
  
Alternatives:
  1. Create new commit (recommended)
  2. Use git revert (if undoing)
  3. Coordinate with team before force push
```

### Scenario 4: Non-Atomic Commit

```
Commit review:
  Score: 58/100
  ⚠ Non-atomic: Mixes feat + fix + docs

Recommendation:
  Split into 3 commits:
    1. feat(auth): OAuth implementation
    2. fix(api): null pointer handling
    3. docs: authentication guide
    
  Use: /commit-split
```

---

This skill ensures high-quality commits through automated validation, intelligent review, and guided workflows.

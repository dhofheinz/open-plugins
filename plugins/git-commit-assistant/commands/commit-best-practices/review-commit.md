# Operation: Review Commit Quality

Analyze a commit's quality including message, changes, atomicity, and completeness.

## Parameters from $ARGUMENTS

- **commit** (optional): Commit SHA or reference (default: HEAD)

Parse as: `review-commit commit:abc123` or `review-commit` (defaults to HEAD)

## Commit Review Workflow

### Step 1: Validate Commit Exists

```bash
# Check if commit exists
if ! git rev-parse --verify ${commit:-HEAD} >/dev/null 2>&1; then
    ERROR: "Commit not found: ${commit}"
    exit 1
fi

# Get commit hash
commit_sha=$(git rev-parse ${commit:-HEAD})
```

### Step 2: Run Commit Reviewer Script

Execute comprehensive analysis:

```bash
./.claude/commands/commit-best-practices/.scripts/commit-reviewer.py "${commit_sha}"
```

The script returns JSON:
```json
{
  "commit": "abc123...",
  "author": "John Doe <john@example.com>",
  "date": "2025-10-13",
  "message": {
    "subject": "feat(auth): add OAuth authentication",
    "body": "- Implement OAuth2 flow\n- Add providers",
    "subject_length": 38,
    "has_body": true,
    "conventional": true,
    "type": "feat",
    "scope": "auth"
  },
  "changes": {
    "files_changed": 5,
    "insertions": 234,
    "deletions": 12,
    "test_files": 1,
    "doc_files": 0
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

### Step 3: Analyze Message Quality

**Check Subject Line:**
- Length ≤ 50 characters ✅
- Imperative mood ("add" not "added") ✅
- Conventional commits format ✅
- Clear and descriptive ✅

**Check Body (if present):**
- Wrapped at 72 characters ✅
- Explains WHY (not just what) ✅
- Uses bullet points for clarity ✅
- Blank line after subject ✅

**Check Footer (if present):**
- Breaking changes noted ✅
- Issue references included ✅

### Step 4: Analyze Changes

**Atomicity Check:**
```
Atomic commit = Single logical change

Check for:
  ❌ Multiple types mixed (feat + fix)
  ❌ Multiple scopes mixed (auth + api + docs)
  ❌ Unrelated changes bundled together

Example ATOMIC:
  feat(auth): add OAuth authentication
  - 5 files, all auth-related
  - Single feature implementation

Example NON-ATOMIC:
  feat: add OAuth and fix null pointer
  - Mixing feat + fix
  - Should be 2 commits
```

**Completeness Check:**
```
Complete commit includes:
  ✅ Implementation code
  ✅ Tests for new code
  ✅ Documentation if needed
  ✅ No missing pieces

Incomplete examples:
  ❌ New feature without tests
  ❌ API change without docs
  ❌ Partial implementation
```

### Step 5: Generate Review Report

**Excellent Commit (Score 90-100):**
```
✅ EXCELLENT COMMIT

Commit: abc123 (HEAD)
Author: John Doe
Date: 2025-10-13

Message Quality: EXCELLENT
  ✅ Subject: "feat(auth): add OAuth authentication" (38 chars)
  ✅ Conventional commits format
  ✅ Descriptive body with bullet points
  ✅ Proper formatting

Changes:
  ✅ Atomic: Single feature (OAuth authentication)
  ✅ Complete: Implementation + tests
  ✅ Files: 5 changed (+234 -12 lines)
  ✅ Test coverage included

Score: 95/100

This commit follows all best practices. Safe to push!
```

**Good Commit (Score 70-89):**
```
✅ GOOD COMMIT (Minor improvements possible)

Commit: abc123 (HEAD)
Author: John Doe
Date: 2025-10-13

Message Quality: GOOD
  ✅ Subject: "feat(auth): add OAuth authentication" (38 chars)
  ✅ Conventional commits format
  ⚠️  Body: Could be more detailed (explains WHAT but not WHY)

Changes:
  ✅ Atomic: Single feature
  ⚠️  Test coverage: Only integration tests (unit tests missing)
  ✅ Files: 5 changed (+234 -12 lines)

Score: 82/100

Suggestions:
  1. Add more context in commit body about WHY this change
  2. Consider adding unit tests for edge cases

Still a good commit. Safe to push with minor notes.
```

**Needs Improvement (Score 50-69):**
```
⚠️  NEEDS IMPROVEMENT

Commit: abc123 (HEAD)
Author: John Doe
Date: 2025-10-13

Message Quality: FAIR
  ⚠️  Subject: "add oauth" (9 chars - too short)
  ❌ Not conventional commits format (missing type/scope)
  ❌ No body explaining changes

Changes:
  ⚠️  Atomicity: Questionable (mixes auth + API changes)
  ❌ Test coverage: No tests included
  ✅ Files: 8 changed (+312 -45 lines)

Score: 58/100

Issues to address:
  1. Improve commit message: "feat(auth): add OAuth authentication"
  2. Add commit body explaining implementation
  3. Add tests for new OAuth functionality
  4. Consider splitting auth changes from API changes

Recommendation: Amend or rewrite this commit before pushing.
```

**Poor Commit (Score < 50):**
```
❌ POOR COMMIT - Should be rewritten

Commit: abc123 (HEAD)
Author: John Doe
Date: 2025-10-13

Message Quality: POOR
  ❌ Subject: "stuff" (5 chars - meaningless)
  ❌ No type, no scope, no clarity
  ❌ No body, no context

Changes:
  ❌ Non-atomic: Multiple unrelated changes
     - Auth system
     - API refactoring
     - Documentation
     - Bug fixes (3 different issues)
  ❌ No tests
  ❌ Files: 23 changed (+1,234 -567 lines)

Score: 28/100

Critical issues:
  1. Commit message is meaningless ("stuff")
  2. Bundles 4+ unrelated changes together
  3. No tests for significant code changes
  4. Too large (23 files)

Action required: Reset and split into 4+ atomic commits with proper messages.

Use: /commit-split (to split into atomic commits)
```

### Step 6: Provide Actionable Guidance

Based on score, recommend action:

**Score ≥ 90**: Safe to push as-is
**Score 70-89**: Safe to push, minor suggestions noted
**Score 50-69**: Amend recommended before pushing
**Score < 50**: Rewrite required, do not push

## Amend Guidance

If commit needs improvement and is safe to amend:

```
To amend this commit:

1. Make improvements (add tests, update message, etc.)
2. Stage changes: git add <files>
3. Amend commit: git commit --amend
4. Review again: /commit-best-practices review-commit

Note: Only amend if commit not yet pushed to remote!
Check: /commit-best-practices amend-guidance
```

## Split Guidance

If commit is non-atomic:

```
This commit should be split into multiple commits:

Detected separate concerns:
  1. feat(auth): OAuth implementation (5 files)
  2. fix(api): null pointer handling (2 files)
  3. docs: authentication guide (1 file)

Use: /commit-split (for interactive splitting)
Or: git reset HEAD~1 (to undo and recommit properly)
```

## Output Format

```
Commit Review Report
===================

Commit: <sha> (<ref>)
Author: <name> <email>
Date: <date>

MESSAGE QUALITY: [EXCELLENT|GOOD|FAIR|POOR]
  [✅|⚠️|❌] Subject: "<subject>" (<length> chars)
  [✅|⚠️|❌] Format: [Conventional|Non-conventional]
  [✅|⚠️|❌] Body: [Present|Missing]
  [✅|⚠️|❌] Clarity: [Clear|Vague]

CHANGES:
  [✅|⚠️|❌] Atomic: [Yes|Questionable|No]
  [✅|⚠️|❌] Complete: [Yes|Partial]
  [✅|⚠️|❌] Tests: [Included|Missing]
  [✅|⚠️|❌] Size: <files> files (+<ins> -<del> lines)

SCORE: <score>/100

[Issues list if any]

[Recommendations]

VERDICT: [Safe to push|Amend recommended|Rewrite required]
```

## Error Handling

**Commit not found:**
```
ERROR: Commit not found: abc123
Check: git log (to see available commits)
```

**Not a git repository:**
```
ERROR: Not a git repository
Run: git init (to initialize)
```

**Script execution error:**
```
ERROR: Commit reviewer script failed
Check: .claude/commands/commit-best-practices/.scripts/commit-reviewer.py exists
Verify: Script is executable
```

## Integration with Agent

After user creates a commit:
1. Agent automatically runs review (unless disabled)
2. If score < 70, suggest improvements
3. If non-atomic, suggest splitting
4. If excellent (≥90), congratulate and suggest push

## Best Practices Enforced

1. **Meaningful messages** - Clear, descriptive commit messages
2. **Conventional format** - type(scope): description
3. **Atomic commits** - One logical change per commit
4. **Complete commits** - Include tests and docs
5. **Proper formatting** - Subject ≤50 chars, body wrapped at 72

High-quality commits make git history useful for debugging, code review, and collaboration.

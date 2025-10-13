# Operation: Pre-Commit Validation

Validate repository state and changes before committing to ensure quality standards.

## Parameters from $ARGUMENTS

- **quick** (optional): `true` for fast checks only, `false` for full validation (default: false)

Parse as: `check-pre-commit quick:true` or `check-pre-commit`

## Pre-Commit Validation Workflow

### Step 1: Repository State Check

Verify git repository is valid and has changes:

```bash
# Check if git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    ERROR: "Not a git repository"
    exit 1
fi

# Check for changes to commit
git status --short
```

If no changes, inform user: "Working tree clean. No changes to commit."

### Step 2: Run Pre-Commit Checks Script

Execute comprehensive validation:

```bash
cd $(git rev-parse --show-toplevel)
./.claude/commands/commit-best-practices/.scripts/pre-commit-check.sh quick:${quick:-false}
```

The script returns JSON:
```json
{
  "status": "pass|fail",
  "checks": {
    "tests": {"status": "pass|fail|skip", "message": "..."},
    "lint": {"status": "pass|fail|skip", "message": "..."},
    "debug_code": {"status": "pass|fail", "count": 0, "locations": []},
    "todos": {"status": "pass|warn", "count": 0, "locations": []},
    "merge_markers": {"status": "pass|fail", "count": 0, "locations": []}
  }
}
```

### Step 3: Parse Results

**If status = "pass"**:
```
✅ Pre-commit validation passed!

All checks completed successfully:
  ✅ Tests: passed
  ✅ Lint: passed
  ✅ Debug code: none found
  ✅ TODOs: none in committed code
  ✅ Merge markers: none found

Safe to commit. Proceed with: /commit
```

**If status = "fail"**:
```
❌ Pre-commit validation failed!

Issues found:
  ❌ Tests: 2 failing
     - test/auth.test.js: OAuth flow test
     - test/api.test.js: null pointer test

  ❌ Debug code: 3 instances found
     - src/auth.js:42: console.log(user)
     - src/api.js:18: debugger statement
     - src/utils.js:91: print(response)

  ❌ TODOs: 1 found in staged code
     - src/auth.js:56: TODO: refactor this

Cannot commit until issues are resolved.

Actions to take:
1. Fix failing tests
2. Remove debug statements (console.log, debugger, print)
3. Resolve or remove TODOs in staged files
4. Run: /commit-best-practices check-pre-commit (to re-validate)
```

### Step 4: Provide Guidance

Based on failures, provide specific remediation:

**Tests Failing:**
```
To fix tests:
1. Run tests locally: npm test (or pytest, cargo test, etc.)
2. Review failures and fix issues
3. Verify all tests pass
4. Re-run validation
```

**Debug Code Found:**
```
To remove debug code:
1. Search for: console.log, debugger, print(, pdb.
2. Remove or comment out debug statements
3. Consider using proper logging instead
4. Re-stage files: git add <file>
```

**TODOs in Committed Code:**
```
TODOs found in staged code:
1. Either: Fix the TODO items now
2. Or: Unstage files with TODOs (git reset HEAD <file>)
3. Or: Remove TODO comments temporarily

Best practice: Don't commit TODOs to main/master
```

**Merge Markers Found:**
```
Merge conflict markers detected:
- <<<<<<<
- =======
- >>>>>>>

Actions:
1. Resolve merge conflicts completely
2. Remove all conflict markers
3. Test merged code
4. Re-stage resolved files
```

## Output Format

Provide clear, actionable feedback:

```
Pre-Commit Validation Report
============================

Status: [PASS|FAIL]

Checks Performed:
  [✅|❌] Tests: [result]
  [✅|❌] Lint: [result]
  [✅|❌] Debug Code: [result]
  [✅|❌] TODOs: [result]
  [✅|❌] Merge Markers: [result]

[If FAIL: Detailed issue list with file locations]

[If FAIL: Remediation steps]

[If PASS: "Safe to commit" confirmation]
```

## Quick Mode

If `quick:true`:
- Skip test execution (assume tests run in CI)
- Skip lint execution (assume linter runs separately)
- Only check: debug code, TODOs, merge markers
- Much faster (~1 second vs ~30 seconds)

Use quick mode for rapid iteration during development.

## Error Handling

**Not a git repository:**
```
ERROR: Not a git repository
Run: git init (to initialize)
Or: cd to correct directory
```

**No changes to validate:**
```
INFO: Working tree clean
No changes staged for commit
Use: git add <files> (to stage changes)
```

**Script execution error:**
```
ERROR: Pre-commit check script failed
Check: .claude/commands/commit-best-practices/.scripts/pre-commit-check.sh exists
Verify: Script is executable (chmod +x)
```

## Integration with Agent

When user says "commit my changes":
1. Agent MUST run this check FIRST
2. If check fails, BLOCK commit and provide guidance
3. If check passes, proceed with commit workflow
4. Never allow commit with failing validation (unless user explicitly forces)

## Best Practices Enforced

1. **Tests must pass** - Failing tests = broken code
2. **No debug code** - console.log, debugger not for production
3. **No committed TODOs** - Fix or remove before commit
4. **No merge markers** - Resolve conflicts completely
5. **Lint compliance** - Follow project style

These checks ensure high code quality and prevent common mistakes.

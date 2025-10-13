# Operation: Create Sequence

Generate executable commit sequence plan.

## Parameters from $ARGUMENTS

- `groups:string` - Group specifications (e.g., "feat:5,fix:2,docs:1")
- `output:plan|script` - Output format (default: plan)
- `auto_stage:true|false` - Auto-stage files (default: false)

## Workflow

### Step 1: Get Commit Suggestions

If not provided, invoke commit suggestion:
```bash
/atomic-commit suggest
```

Parse suggestions to get commit details.

### Step 2: Analyze Dependencies

Execute dependency checker:
```bash
.claude/plugins/git-commit-assistant/commands/atomic-commit/.scripts/dependency-checker.sh
```

Identify dependencies between commits:
- File dependencies (imports, references)
- Logical dependencies (feature order)
- Test dependencies (code → tests)

Build dependency graph:
```
feat(auth) → test(auth) → docs(auth)
     ↓
fix(api) → test(api)
```

### Step 3: Determine Commit Order

Apply ordering rules:

**Priority 1: Dependencies**
- Commits with dependencies come first
- Tests after implementation
- Docs after features

**Priority 2: Type Order**
Standard order:
1. feat (features enable other changes)
2. fix (fixes should be applied early)
3. refactor (restructuring before additions)
4. perf (performance after stability)
5. test (tests after implementation)
6. docs (documentation last)
7. chore (housekeeping last)

**Priority 3: Scope Grouping**
- Related scopes together
- Independent scopes can be parallel

**Priority 4: Impact**
- High-impact changes first
- Low-risk changes can be later

### Step 4: Generate Sequence Plan

Create executable sequence:

```
📋 COMMIT SEQUENCE PLAN

Execution Order: 3 commits in sequence

┌─────────────────────────────────────────────┐
│ COMMIT 1: feat(auth)                        │
│ Files: 8                                    │
│ Dependencies: None                          │
│ Can execute: ✅ Now                         │
└─────────────────────────────────────────────┘

Message:
  feat(auth): implement OAuth 2.0 authentication

  Add complete OAuth 2.0 authentication flow with
  support for multiple providers (GitHub, Google).

Files to stage:
  git add src/auth/oauth.ts
  git add src/auth/tokens.ts
  git add src/auth/providers/github.ts
  git add src/auth/providers/google.ts
  git add src/config/oauth.config.ts
  git add src/types/auth.types.ts
  git add tests/auth/oauth.test.ts
  git add tests/auth/tokens.test.ts

Command:
  git commit -m "feat(auth): implement OAuth 2.0 authentication" -m "Add complete OAuth 2.0 authentication flow with support for multiple providers (GitHub, Google). Includes token management, refresh handling, and comprehensive test coverage."

─────────────────────────────────────────────

┌─────────────────────────────────────────────┐
│ COMMIT 2: fix(api)                          │
│ Files: 3                                    │
│ Dependencies: None                          │
│ Can execute: ✅ After commit 1              │
└─────────────────────────────────────────────┘

Message:
  fix(api): handle null pointer in user endpoint

  Fix null pointer exception when user profile
  is incomplete.

Files to stage:
  git add src/api/endpoints.ts
  git add src/api/validation.ts
  git add tests/api.test.ts

Command:
  git commit -m "fix(api): handle null pointer in user endpoint" -m "Fix null pointer exception when user profile is incomplete. Add validation to check for required fields before access."

─────────────────────────────────────────────

┌─────────────────────────────────────────────┐
│ COMMIT 3: docs                              │
│ Files: 2                                    │
│ Dependencies: Commit 1 (feat(auth))         │
│ Can execute: ✅ After commit 1              │
└─────────────────────────────────────────────┘

Message:
  docs: add OAuth authentication guide

  Add comprehensive documentation for OAuth 2.0
  authentication setup and usage.

Files to stage:
  git add README.md
  git add docs/authentication.md

Command:
  git commit -m "docs: add OAuth authentication guide" -m "Add comprehensive documentation for OAuth 2.0 authentication setup and usage. Includes configuration examples and provider setup."

─────────────────────────────────────────────

Summary:
  Total commits: 3
  Total files: 13
  Execution time: ~3 minutes
  All dependencies resolved: ✅ Yes
```

### Step 5: Generate Script (if output:script)

Create executable bash script:

```bash
#!/bin/bash
# Atomic commit sequence
# Generated: 2025-10-13
# Total commits: 3

set -e  # Exit on error

echo "🚀 Starting commit sequence..."

# Commit 1: feat(auth)
echo ""
echo "📝 Commit 1/3: feat(auth)"
git add src/auth/oauth.ts
git add src/auth/tokens.ts
git add src/auth/providers/github.ts
git add src/auth/providers/google.ts
git add src/config/oauth.config.ts
git add src/types/auth.types.ts
git add tests/auth/oauth.test.ts
git add tests/auth/tokens.test.ts
git commit -m "feat(auth): implement OAuth 2.0 authentication" -m "Add complete OAuth 2.0 authentication flow with support for multiple providers (GitHub, Google). Includes token management, refresh handling, and comprehensive test coverage."
echo "✅ Commit 1 complete"

# Commit 2: fix(api)
echo ""
echo "📝 Commit 2/3: fix(api)"
git add src/api/endpoints.ts
git add src/api/validation.ts
git add tests/api.test.ts
git commit -m "fix(api): handle null pointer in user endpoint" -m "Fix null pointer exception when user profile is incomplete. Add validation to check for required fields before access."
echo "✅ Commit 2 complete"

# Commit 3: docs
echo ""
echo "📝 Commit 3/3: docs"
git add README.md
git add docs/authentication.md
git commit -m "docs: add OAuth authentication guide" -m "Add comprehensive documentation for OAuth 2.0 authentication setup and usage. Includes configuration examples and provider setup."
echo "✅ Commit 3 complete"

echo ""
echo "🎉 All commits completed successfully!"
echo "Total commits: 3"
echo "Total files: 13"
```

### Step 6: Validate Sequence

Check sequence for issues:
- All files accounted for
- No file appears in multiple commits
- Dependencies resolved
- Logical ordering
- Commands are valid

### Step 7: Provide Execution Options

Offer execution methods:

**Option 1: Manual execution**
Copy-paste commands one by one

**Option 2: Script execution**
Save script and run: `bash commit-sequence.sh`

**Option 3: Interactive**
Execute with guidance: `/atomic-commit interactive`

**Option 4: Agent execution**
Let agent execute sequence

## Output Format

Return structured sequence:
```yaml
sequence:
  - commit_id: 1
    order: 1
    type: feat
    scope: auth
    message:
      subject: "Brief description"
      body: "Detailed explanation"
    files: [list]
    dependencies: []
    can_execute: "now|after:<id>"
    commands:
      stage: [git add commands]
      commit: "git commit command"
  - commit_id: 2
    order: 2
    ...
summary:
  total_commits: number
  total_files: number
  estimated_time: "minutes"
  dependencies_resolved: true|false
execution:
  manual: "Copy commands"
  script: "Use generated script"
  interactive: "/atomic-commit interactive"
  agent: "Let agent execute"
script: "Bash script content (if output:script)"
```

## Error Handling

- **No suggestions**: "No commit suggestions. Run: /atomic-commit suggest"
- **Circular dependencies**: "Cannot resolve: circular dependency detected"
- **Invalid group spec**: "Invalid group specification: {spec}"
- **File conflicts**: "File appears in multiple commits: {file}"

## Dependency Analysis

The dependency checker identifies:

**Import dependencies:**
- File A imports from File B
- B must be committed before A

**Test dependencies:**
- Test file tests code file
- Code must be committed before tests

**Logical dependencies:**
- Feature depends on another feature
- Base feature first, dependent after

**Type dependencies:**
- Fixes may depend on features
- Docs depend on implementations

## Execution Planning

### Commit Planner Script

The commit planner creates optimal sequence:

```python
def create_sequence(suggestions, dependencies):
    # Build dependency graph
    graph = build_graph(suggestions, dependencies)

    # Topological sort for dependency order
    ordered = topological_sort(graph)

    # Apply type priority within independent groups
    prioritized = apply_type_priority(ordered)

    # Group by scope for related commits
    sequenced = group_by_scope(prioritized)

    return sequenced
```

## Examples

**Example 1: Auto-generate plan**
```bash
/atomic-commit sequence
→ Creates sequence from current suggestions
```

**Example 2: Custom groups**
```bash
/atomic-commit sequence groups:"feat:5,fix:2,docs:1"
→ Creates sequence for specified groups
```

**Example 3: Generate script**
```bash
/atomic-commit sequence output:script
→ Outputs executable bash script
```

**Example 4: Auto-stage**
```bash
/atomic-commit sequence auto_stage:true
→ Automatically stages files during execution
```

## Integration Notes

This operation:
1. Uses results from `suggest-commits`
2. Requires `dependency-checker.sh` script
3. Uses `commit-planner.py` for optimization
4. Feeds into execution workflows
5. Can output multiple formats

The sequence ensures atomic commits in optimal order.

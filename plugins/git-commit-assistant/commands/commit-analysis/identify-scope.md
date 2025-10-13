---
description: Identify the primary module or component affected by changes for commit scope
---

# Operation: Identify Scope

Analyze git changes to determine the appropriate scope (module/component/area) for the conventional commit message.

## Parameters from $ARGUMENTS

No parameters required. Analyzes current changes.

## Workflow

### Step 1: Verify Repository and Changes

```bash
git rev-parse --git-dir 2>/dev/null
git status --short
```

### Step 2: Analyze File Paths

Execute scope identifier script:

```bash
git diff HEAD --name-only | .scripts/scope-identifier.sh
```

The script analyzes file paths to identify affected modules.

### Step 3: Scope Detection Algorithm

**Directory-Based Scope:**
```
src/auth/*           → scope: auth
src/api/*            → scope: api
src/components/*     → scope: components (or specific component)
src/utils/*          → scope: utils
src/database/*       → scope: database
tests/*              → scope: test (or module being tested)
docs/*               → scope: docs
```

**Component-Based Scope:**
```
src/components/LoginForm.js  → scope: login-form
src/components/UserProfile/* → scope: user-profile
src/api/users.js             → scope: users or user-api
src/auth/oauth.js            → scope: oauth or auth
```

**Multiple Scopes:**
If multiple distinct scopes:
```
Primary: auth (5 files)
Secondary: api (2 files)
Recommendation: Split into separate commits or use broader scope
```

### Step 4: Determine Scope Specificity

**Specific Scope** (preferred):
- Targets single module/component
- Example: "auth", "user-profile", "payment-api"

**Broad Scope**:
- Multiple modules affected
- Example: "api", "components", "core"

**No Scope** (optional):
- Changes are too diverse
- Use no scope in message

### Step 5: Format Scope Report

```
SCOPE IDENTIFICATION
═══════════════════════════════════════════════

PRIMARY SCOPE: <scope-name>
CONFIDENCE: <High|Medium|Low>

REASONING:
───────────────────────────────────────────────
<explanation of scope selection>

AFFECTED AREAS:
───────────────────────────────────────────────
<scope>: X files
  - path/to/file1.js
  - path/to/file2.js

<other-scope>: X files (if applicable)
  - path/to/file3.js

FILE PATH ANALYSIS:
───────────────────────────────────────────────
src/auth/*: 5 files → scope: auth
src/api/*: 2 files → scope: api
tests/*: 3 files → scope based on tested module

RECOMMENDATION:
───────────────────────────────────────────────
Use scope: "<recommended-scope>"

Alternative: <if multiple scopes>
  - Split into commits: auth (5 files), api (2 files)
  - Use broader scope: "backend"
  - Use no scope (if too diverse)

═══════════════════════════════════════════════
```

## Scope Naming Conventions

**Format:**
- Lowercase
- Hyphen-separated (kebab-case)
- Concise (1-3 words)
- Specific but not too granular

**Good Examples:**
```
auth
user-api
login-form
payment-processing
database
ci-pipeline
docs
```

**Bad Examples:**
```
src/auth/oauth  (too specific, includes path)
Authentication  (not lowercase)
user_api        (use hyphens, not underscores)
the-entire-authentication-module-system  (too long)
```

## Common Scopes by Project Type

### Web Application:
```
auth, api, components, ui, pages, routing, state, utils, config, hooks
```

### Backend API:
```
api, auth, database, middleware, routes, controllers, services, models, validation
```

### Library/Package:
```
core, utils, types, cli, docs, build, test
```

### Full Stack:
```
frontend, backend, api, database, auth, ci, docs
```

## Multiple Scope Handling

**Case 1: Closely Related Scopes**
```
Changes in: auth/oauth.js, auth/providers.js, auth/middleware.js
Recommendation: scope: "auth"
```

**Case 2: Distinct Scopes**
```
Changes in: auth/* (5 files), api/* (3 files)
Recommendation: Split commits
  - Commit 1: feat(auth): implement OAuth
  - Commit 2: feat(api): add user endpoints
```

**Case 3: Very Broad Changes**
```
Changes in: 15 different directories
Recommendation: Use broad scope or no scope
  - feat(core): major refactoring
  - feat: implement new architecture
```

## Output Format

Return:
- Primary scope name
- Confidence level
- Reasoning for scope selection
- List of affected areas
- Alternative recommendations if applicable

## Error Handling

**No changes:**
```
NO CHANGES
Cannot identify scope from empty diff.
```

**Unclear scope:**
```
SCOPE UNCLEAR
Changes span multiple unrelated areas.
Recommendations:
  - Split into focused commits
  - Use broader scope like "core" or "backend"
  - Use no scope
```

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Determine scope for commit messages
2. Validate user-provided scopes
3. Suggest scope splitting if needed
4. Guide users in scope selection

## Usage Example

```bash
# Agent identifies scope automatically
# User: "commit my auth changes"
# Agent: Invokes identify-scope
# Operation: Returns "auth" with high confidence
# Agent: Uses in message "feat(auth): ..."
```

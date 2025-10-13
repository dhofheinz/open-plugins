# Operation: Suggest Commits

Generate commit message suggestions for file groups.

## Parameters from $ARGUMENTS

- `groups:string` - Comma-separated group IDs to process (default: all)
- `format:conventional|simple` - Message format (default: conventional)
- `include_body:true|false` - Include commit body (default: true)

## Workflow

### Step 1: Get File Groups

If groups not provided, invoke file grouping:
```bash
/atomic-commit group strategy:type
```

Parse grouping results to identify distinct commit groups.

### Step 2: Analyze Each Group

For each file group:
1. Get file diffs
2. Analyze changes
3. Identify commit type
4. Determine scope
5. Extract key changes

Invoke Bash to get detailed diffs:
```bash
git diff --cached <files>
git diff <files>
```

### Step 3: Generate Commit Messages

For each group, create commit message following conventions:

**Conventional format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Components:**
- **type**: feat|fix|docs|style|refactor|test|chore
- **scope**: Module or component affected
- **subject**: Brief description (≤50 chars)
- **body**: Detailed explanation (optional)
- **footer**: Breaking changes, issue references (optional)

**Example:**
```
feat(auth): implement OAuth 2.0 authentication

Add OAuth 2.0 authentication flow with support for:
- GitHub provider
- Google provider
- Token management
- Refresh token handling

Includes comprehensive test coverage.
```

### Step 4: Validate Messages

Check each message for:
- Type correctness
- Scope accuracy
- Subject clarity
- Body completeness
- Footer requirements

Apply commit message best practices:
- Subject in imperative mood
- Subject ≤50 characters
- Body wrapped at 72 characters
- Clear explanation of "why"
- Reference related issues

### Step 5: Rank Suggestions

Order commits by:
1. **Dependency order**: Dependencies first
2. **Type priority**: feat → fix → refactor → docs → chore
3. **Scope cohesion**: Related scopes together
4. **Logical flow**: Natural progression

### Step 6: Generate Output

Create comprehensive suggestion report:

```
💬 COMMIT SUGGESTIONS

Commit 1 of 3: feat(auth) - 8 files
─────────────────────────────────────
feat(auth): implement OAuth 2.0 authentication

Add complete OAuth 2.0 authentication flow with
support for multiple providers (GitHub, Google).
Includes token management, refresh handling, and
comprehensive test coverage.

Files:
  • src/auth/oauth.ts
  • src/auth/tokens.ts
  • src/auth/providers/github.ts
  • src/auth/providers/google.ts
  • src/config/oauth.config.ts
  • src/types/auth.types.ts
  • tests/auth/oauth.test.ts
  • tests/auth/tokens.test.ts

Atomic: ✅ Yes
Ready: ✅ Can commit

─────────────────────────────────────

Commit 2 of 3: fix(api) - 3 files
─────────────────────────────────────
fix(api): handle null pointer in user endpoint

Fix null pointer exception when user profile is
incomplete. Add validation to check for required
fields before access.

Files:
  • src/api/endpoints.ts
  • src/api/validation.ts
  • tests/api.test.ts

Atomic: ✅ Yes
Ready: ✅ Can commit

─────────────────────────────────────

Commit 3 of 3: docs - 2 files
─────────────────────────────────────
docs: add OAuth authentication guide

Add comprehensive documentation for OAuth 2.0
authentication setup and usage. Includes
configuration examples and provider setup.

Files:
  • README.md
  • docs/authentication.md

Atomic: ✅ Yes
Ready: ✅ Can commit

─────────────────────────────────────

Summary:
  Total commits: 3
  Total files: 13
  All atomic: ✅ Yes
  Ready to commit: ✅ Yes

Next steps:
  1. Review suggestions above
  2. Run: /atomic-commit sequence (to create plan)
  3. Or manually stage and commit each group
```

## Output Format

Return structured suggestions:
```yaml
suggestions:
  - commit_id: 1
    type: feat|fix|docs|etc
    scope: module_name
    subject: "Brief description"
    body: "Detailed explanation"
    footer: "Breaking changes, refs"
    files: [list]
    stats:
      file_count: number
      additions: number
      deletions: number
    atomic: true|false
    ready: true|false
    dependencies: [commit_ids]
summary:
  total_commits: number
  total_files: number
  all_atomic: true|false
  ready_to_commit: true|false
next_steps: [ordered actions]
```

## Message Generation Rules

### Type Detection
- `feat`: New features, capabilities, enhancements
- `fix`: Bug fixes, error corrections
- `docs`: Documentation only
- `style`: Formatting, whitespace, semicolons
- `refactor`: Code restructuring without behavior change
- `test`: Test additions or modifications
- `chore`: Build, dependencies, tooling
- `perf`: Performance improvements
- `ci`: CI/CD configuration changes

### Scope Extraction
1. Analyze file paths for common prefix
2. Identify module name from structure
3. Use meaningful component names
4. Keep scopes consistent across project

### Subject Crafting
1. Use imperative mood: "add" not "added"
2. No capitalization of first letter
3. No period at the end
4. Be specific but concise
5. Maximum 50 characters

### Body Creation
1. Explain "why" not "what"
2. Provide context for changes
3. Wrap at 72 characters
4. Use bullet points for lists
5. Include relevant details

### Footer Guidelines
- **Breaking changes**: Start with "BREAKING CHANGE:"
- **Issue references**: "Fixes #123", "Closes #456"
- **Related issues**: "Related to #789"

## Error Handling

- **No groups**: "No file groups found. Run: /atomic-commit group"
- **Invalid group**: "Group ID not found: {id}"
- **Cannot analyze**: "Failed to analyze changes for group {id}"
- **Message generation failed**: "Could not generate message. Check diffs."

## Examples

**Example 1: All groups**
```bash
/atomic-commit suggest
→ Suggests commits for all detected groups
```

**Example 2: Specific groups**
```bash
/atomic-commit suggest groups:"1,3"
→ Suggests commits only for groups 1 and 3
```

**Example 3: Simple format**
```bash
/atomic-commit suggest format:simple include_body:false
→ Simple messages without detailed bodies
```

## Integration Notes

This operation:
1. Uses results from `group-files`
2. Feeds into `create-sequence`
3. Is part of `interactive-split` workflow
4. Can be used standalone for quick suggestions

Suggestions are not final - user can review and modify before committing.

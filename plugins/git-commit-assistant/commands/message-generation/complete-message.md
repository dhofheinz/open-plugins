---
description: Generate complete commit message orchestrating subject, body, and footer
---

# Operation: Complete Message

Generate a complete, well-formatted commit message by orchestrating subject generation, body composition, and footer creation.

## Parameters from $ARGUMENTS

**Required:**
- `type:` - Commit type (feat, fix, docs, etc.)

**Optional:**
- `scope:` - Affected module/component
- `description:` - Brief description (if not provided, derived from files)
- `files:` - Comma-separated file paths for context
- `changes:` - Comma-separated list of changes
- `why:` - Explanation of why changes were made
- `breaking:` - Breaking change description
- `closes:` - Issue numbers to close
- `fixes:` - Issue numbers to fix
- `include_body:` - Include body (true|false, default: true if multiple files)
- `include_footer:` - Include footer (true|false, default: true if breaking/issues)

**Format:** `complete type:feat scope:auth files:"file1.js,file2.js" breaking:"API changed" closes:123`

## Workflow

### Step 1: Parse All Parameters

Extract all parameters from $ARGUMENTS:

```bash
# Required
type=$(echo "$ARGUMENTS" | grep -oP 'type:\K[^ ]+')

# Optional
scope=$(echo "$ARGUMENTS" | grep -oP 'scope:\K[^ ]+')
description=$(echo "$ARGUMENTS" | grep -oP 'description:"\K[^"]+' || echo "$ARGUMENTS" | grep -oP 'description:\K[^ ]+')
files=$(echo "$ARGUMENTS" | grep -oP 'files:"\K[^"]+' || echo "$ARGUMENTS" | grep -oP 'files:\K[^ ]+')
changes=$(echo "$ARGUMENTS" | grep -oP 'changes:"\K[^"]+')
why=$(echo "$ARGUMENTS" | grep -oP 'why:"\K[^"]+')
breaking=$(echo "$ARGUMENTS" | grep -oP 'breaking:"\K[^"]+')
closes=$(echo "$ARGUMENTS" | grep -oP 'closes:\K[0-9,]+')
fixes=$(echo "$ARGUMENTS" | grep -oP 'fixes:\K[0-9,]+')
include_body=$(echo "$ARGUMENTS" | grep -oP 'include_body:\K(true|false)' || echo "auto")
include_footer=$(echo "$ARGUMENTS" | grep -oP 'include_footer:\K(true|false)' || echo "auto")
```

### Step 2: Validate Required Parameters

**Check type is provided:**
```bash
if [ -z "$type" ]; then
  echo "ERROR: type parameter is required"
  echo "Usage: complete type:<type> [scope:<scope>] [files:\"<files>\"]"
  exit 1
fi
```

**Validate type:**
```bash
valid_types="feat fix docs style refactor perf test build ci chore revert"
if ! echo "$valid_types" | grep -qw "$type"; then
  echo "ERROR: Invalid type '$type'"
  echo "Valid types: $valid_types"
  exit 1
fi
```

### Step 3: Derive Missing Parameters

**If description not provided, derive from files:**
```bash
if [ -z "$description" ] && [ -n "$files" ]; then
  # Analyze files to create description
  file_count=$(echo "$files" | tr ',' '\n' | wc -l)
  if [ $file_count -eq 1 ]; then
    description="update $(basename $files)"
  else
    # Extract common directory or feature
    description="update ${file_count} files"
  fi
fi
```

**Determine body inclusion:**
```bash
if [ "$include_body" = "auto" ]; then
  file_count=$(echo "$files" | tr ',' '\n' | wc -l)
  if [ $file_count -gt 1 ] || [ -n "$changes" ] || [ -n "$why" ]; then
    include_body="true"
  else
    include_body="false"
  fi
fi
```

**Determine footer inclusion:**
```bash
if [ "$include_footer" = "auto" ]; then
  if [ -n "$breaking" ] || [ -n "$closes" ] || [ -n "$fixes" ]; then
    include_footer="true"
  else
    include_footer="false"
  fi
fi
```

### Step 4: Generate Subject Line

**Read and execute generate-subject.md:**

```bash
# Build subject arguments
subject_args="subject type:$type"
[ -n "$scope" ] && subject_args="$subject_args scope:$scope"
[ -n "$description" ] && subject_args="$subject_args description:\"$description\""

# Invoke subject generation
subject_result=$(bash -c "cd /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation && cat generate-subject.md")

# Extract generated subject line
subject_line="<generated subject>"
```

**Store subject line:**
```bash
COMMIT_MESSAGE="$subject_line"
```

### Step 5: Generate Body (if needed)

**If include_body is true, read and execute write-body.md:**

```bash
if [ "$include_body" = "true" ]; then
  # Build body arguments
  body_args="body"

  if [ -n "$changes" ]; then
    body_args="$body_args changes:\"$changes\""
  elif [ -n "$files" ]; then
    # Derive changes from files
    body_args="$body_args changes:\"$files\""
  fi

  [ -n "$why" ] && body_args="$body_args why:\"$why\""

  # Invoke body generation
  body_result=$(bash -c "cd /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation && cat write-body.md")

  # Extract generated body
  body_content="<generated body>"

  # Append to message (with blank line)
  COMMIT_MESSAGE="$COMMIT_MESSAGE

$body_content"
fi
```

### Step 6: Generate Footer (if needed)

**If include_footer is true, read and execute add-footer.md:**

```bash
if [ "$include_footer" = "true" ]; then
  # Build footer arguments
  footer_args="footer"
  [ -n "$breaking" ] && footer_args="$footer_args breaking:\"$breaking\""
  [ -n "$closes" ] && footer_args="$footer_args closes:$closes"
  [ -n "$fixes" ] && footer_args="$footer_args fixes:$fixes"

  # Invoke footer generation
  footer_result=$(bash -c "cd /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation && cat add-footer.md")

  # Extract generated footer
  footer_content="<generated footer>"

  # Append to message (with blank line)
  COMMIT_MESSAGE="$COMMIT_MESSAGE

$footer_content"
fi
```

### Step 7: Validate Complete Message

**Read and execute validate-message.md:**

```bash
# Invoke validation
validation_result=$(bash -c "cd /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation && cat validate-message.md")

# Parse validation result
validation_status="<VALID|INVALID>"
validation_score="<score>"
```

### Step 8: Format Final Output

Present the complete commit message:

```
COMPLETE COMMIT MESSAGE GENERATED
═══════════════════════════════════════════════

MESSAGE:
───────────────────────────────────────────────
<subject line>

<body content if present>

<footer content if present>
───────────────────────────────────────────────

COMPONENTS:
───────────────────────────────────────────────
Subject: ✓ Generated (XX chars)
Body: ✓ Generated (X lines) / ⊘ Omitted
Footer: ✓ Generated / ⊘ Omitted

VALIDATION:
───────────────────────────────────────────────
Format: ✓ Conventional Commits
Status: ✓ VALID
Score: XX/100

STATISTICS:
───────────────────────────────────────────────
Total Lines: X
Subject Length: XX/50 chars
Body Lines: X (if present)
Footer Elements: X (if present)

READY TO COMMIT:
───────────────────────────────────────────────
git commit -m "$(cat <<'EOF'
<complete message here>
EOF
)"

═══════════════════════════════════════════════
```

## Output Format

Return structured output with:
- Complete formatted message
- Component breakdown
- Validation results
- Statistics
- Ready-to-use git command

## Error Handling

**Missing required parameters:**
```
ERROR: type parameter is required
Usage: complete type:<type> [scope:<scope>] [files:"<files>"]

Example: complete type:feat scope:auth files:"auth.js,provider.js"
```

**Invalid type:**
```
ERROR: Invalid type 'feature'
Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
```

**Validation fails:**
```
WARNING: Generated message has issues
<validation errors>

Message generated but may need manual adjustment.
```

**Insufficient context:**
```
ERROR: Insufficient information to generate message
Provide either:
  - description: explicit description
  - files: files changed for context
  - changes: list of changes made

Example: complete type:feat description:"add authentication"
```

## Integration with Agent

The commit-assistant agent uses this operation as the primary message generation workflow:

```
1. User: "commit my changes"
   ↓
2. Agent: Analyze changes (/commit-analysis analyze)
   → type=feat, scope=auth, files=[...]
   ↓
3. Agent: Generate complete message (THIS OPERATION)
   → /message-generation complete type:feat scope:auth files:"..."
   ↓
4. Operation: Orchestrate generation
   → Generate subject
   → Generate body (if multiple files)
   → Generate footer (if issues/breaking)
   → Validate complete message
   ↓
5. Return: Complete, validated message
   ↓
6. Agent: Present to user for approval
```

## Usage Examples

### Example 1: Simple Commit (Subject Only)

```bash
# Input
/message-generation complete type:fix description:"resolve login crash"

# Output
MESSAGE:
fix: resolve login crash

COMPONENTS:
Subject: ✓ (26/50 chars)
Body: ⊘ Omitted (single change)
Footer: ⊘ Omitted (no issues)

VALIDATION: ✓ VALID (100/100)
```

### Example 2: Feature with Multiple Files

```bash
# Input
/message-generation complete type:feat scope:auth files:"oauth.js,providers/google.js,providers/github.js"

# Output
MESSAGE:
feat(auth): add OAuth authentication

- Add OAuth2 authentication module
- Implement Google provider
- Implement GitHub provider

COMPONENTS:
Subject: ✓ (36/50 chars)
Body: ✓ Generated (3 lines)
Footer: ⊘ Omitted

VALIDATION: ✓ VALID (95/100)
```

### Example 3: Breaking Change with Issues

```bash
# Input
/message-generation complete type:feat scope:api description:"redesign authentication API" breaking:"authentication endpoints changed" closes:100,101

# Output
MESSAGE:
feat(api): redesign authentication API

- Redesign authentication endpoints
- Improve security with OAuth2
- Simplify client integration

BREAKING CHANGE: authentication endpoints changed from /login and
/logout to /auth/login and /auth/logout
Closes #100, #101

COMPONENTS:
Subject: ✓ (42/50 chars)
Body: ✓ Generated (3 lines)
Footer: ✓ Generated (breaking + issues)

VALIDATION: ✓ VALID (100/100)
```

### Example 4: Bug Fix with Context

```bash
# Input
/message-generation complete type:fix scope:api files:"user.js" why:"prevent null pointer when user not found" fixes:42

# Output
MESSAGE:
fix(api): resolve null pointer in user endpoint

- Add null check for user lookup
- Return 404 when user not found
- Add error handling

Prevent null pointer exception when user is not found in database.

Fixes #42

COMPONENTS:
Subject: ✓ (46/50 chars)
Body: ✓ Generated (5 lines with context)
Footer: ✓ Generated (issue fix)

VALIDATION: ✓ VALID (100/100)
```

### Example 5: Documentation Update

```bash
# Input
/message-generation complete type:docs files:"README.md" description:"add installation instructions"

# Output
MESSAGE:
docs: add installation instructions

COMPONENTS:
Subject: ✓ (36/50 chars)
Body: ⊘ Omitted (docs only)
Footer: ⊘ Omitted

VALIDATION: ✓ VALID (100/100)
```

### Example 6: Explicit Body and Footer Control

```bash
# Input
/message-generation complete type:refactor scope:database description:"optimize queries" include_body:true include_footer:false changes:"Add indexes,Optimize joins,Cache results"

# Output
MESSAGE:
refactor(database): optimize queries

- Add database indexes
- Optimize query joins
- Implement result caching

COMPONENTS:
Subject: ✓ (35/50 chars)
Body: ✓ Forced inclusion
Footer: ⊘ Forced omission

VALIDATION: ✓ VALID (95/100)
```

## Best Practices

**Provide sufficient context:**
- ✅ type + scope + files (agent can derive details)
- ✅ type + description + changes (explicit)
- ❌ type only (insufficient)

**Let automation work:**
- ✅ Trust body/footer auto-inclusion logic
- ❌ Manually force inclusion when not needed

**Use breaking and issues:**
- ✅ Always include breaking changes
- ✅ Always link to issues
- ❌ Forget to document breaking changes

**Validate assumptions:**
- ✅ Review generated message
- ✅ Check validation results
- ❌ Blindly commit generated message

## Decision Logic

**Body inclusion decision tree:**
```
if include_body explicitly set:
  use explicit value
else if multiple files changed (>1):
  include body
else if changes list provided:
  include body
else if why context provided:
  include body
else:
  omit body
```

**Footer inclusion decision tree:**
```
if include_footer explicitly set:
  use explicit value
else if breaking change provided:
  include footer
else if issue numbers provided (closes/fixes):
  include footer
else:
  omit footer
```

## Orchestration Flow

**Step-by-step orchestration:**

```
1. Parse parameters
   ↓
2. Validate required (type)
   ↓
3. Derive missing (description from files)
   ↓
4. Determine body/footer inclusion
   ↓
5. Generate subject (always)
   → Invoke: generate-subject.md
   ↓
6. Generate body (if needed)
   → Invoke: write-body.md
   ↓
7. Generate footer (if needed)
   → Invoke: add-footer.md
   ↓
8. Combine all parts
   ↓
9. Validate complete message
   → Invoke: validate-message.md
   ↓
10. Return complete message with validation
```

## Error Recovery

**If subject generation fails:**
- Return error immediately
- Do not proceed to body/footer

**If body generation fails:**
- Return subject only
- Mark body as "generation failed"
- Continue to footer if needed

**If footer generation fails:**
- Return subject + body
- Mark footer as "generation failed"

**If validation fails:**
- Return message anyway
- Include validation errors
- Let user decide to fix or use

## Performance Considerations

**Typical generation time:**
- Subject only: <100ms
- Subject + body: <200ms
- Subject + body + footer: <300ms
- With validation: +50ms

**Optimization:**
- Cache repeated operations
- Minimize script invocations
- Stream output for large bodies

## Advanced Usage

**Template-based generation:**
```bash
# Feature template
complete type:feat scope:$SCOPE template:feature

# Bugfix template
complete type:fix scope:$SCOPE template:bugfix fixes:$ISSUE
```

**From analysis results:**
```bash
# Agent workflow
analysis=$(/commit-analysis analyze)
type=$(echo "$analysis" | jq -r '.type')
scope=$(echo "$analysis" | jq -r '.scope')
files=$(echo "$analysis" | jq -r '.files | join(",")')

/message-generation complete type:$type scope:$scope files:"$files"
```

**Interactive refinement:**
```bash
# Generate initial
msg=$(/message-generation complete type:feat scope:auth)

# User: "too long"
# Regenerate with constraint
msg=$(/message-generation complete type:feat scope:auth description:"add OAuth" include_body:false)
```

---
description: Generate conventional commit subject line with type, scope, and description
---

# Operation: Generate Subject Line

Create a properly formatted subject line following the conventional commits standard: `<type>(<scope>): <description>`

## Parameters from $ARGUMENTS

**Required:**
- `type:` - Commit type (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
- `description:` - Brief description of changes

**Optional:**
- `scope:` - Affected module/component
- `max_length:` - Maximum length (default: 50, hard limit: 72)

**Format:** `subject type:feat scope:auth description:"add OAuth authentication"`

## Workflow

### Step 1: Parse Parameters

Extract parameters from $ARGUMENTS:

```bash
# Parse key:value pairs
type=$(echo "$ARGUMENTS" | grep -oP 'type:\K[^ ]+')
scope=$(echo "$ARGUMENTS" | grep -oP 'scope:\K[^ ]+')
description=$(echo "$ARGUMENTS" | grep -oP 'description:"\K[^"]+' || echo "$ARGUMENTS" | grep -oP 'description:\K[^ ]+')
max_length=$(echo "$ARGUMENTS" | grep -oP 'max_length:\K[0-9]+' || echo "50")
```

### Step 2: Validate Parameters

**Check required parameters:**
```bash
if [ -z "$type" ]; then
  echo "ERROR: type parameter is required"
  echo "Usage: subject type:<type> description:\"<desc>\" [scope:<scope>]"
  exit 1
fi

if [ -z "$description" ]; then
  echo "ERROR: description parameter is required"
  echo "Usage: subject type:<type> description:\"<desc>\" [scope:<scope>]"
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

### Step 3: Invoke Subject Generator Script

Pass parameters to the utility script for intelligent formatting:

```bash
# Prepare JSON input
cat <<EOF | /home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/.scripts/subject-generator.py
{
  "type": "$type",
  "scope": "$scope",
  "description": "$description",
  "max_length": $max_length
}
EOF
```

The script will:
- Format the subject line
- Enforce imperative mood
- Ensure proper capitalization
- Check character limits
- Suggest improvements if needed

### Step 4: Format Output

Present the generated subject line:

```
SUBJECT LINE GENERATED
═══════════════════════════════════════════════

Subject: <type>(<scope>): <description>
Length: XX/50 characters

VALIDATION:
───────────────────────────────────────────────
✓ Type is valid
✓ Imperative mood used
✓ No capitalization after colon
✓ No period at end
✓ Within character limit

SUGGESTIONS:
───────────────────────────────────────────────
- <improvement 1 if applicable>
- <improvement 2 if applicable>

═══════════════════════════════════════════════
```

## Output Format

Return structured output:
- Generated subject line
- Character count
- Validation results
- Suggestions for improvement (if any)

## Error Handling

**Missing required parameters:**
```
ERROR: Missing required parameter 'type'
Usage: subject type:<type> description:"<desc>" [scope:<scope>]

Example: subject type:feat description:"add user authentication"
```

**Invalid type:**
```
ERROR: Invalid type 'feature'
Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
```

**Description too long:**
```
WARNING: Subject line exceeds 50 characters (XX chars)
Current: <type>(<scope>): <very long description>

Suggestion: Shorten description or move details to body
Recommended: <type>(<scope>): <shortened description>
```

**Non-imperative mood:**
```
WARNING: Use imperative mood
Current: "added authentication"
Correct: "add authentication"
```

## Subject Line Rules

**Imperative Mood:**
- ✅ "add feature" (correct)
- ❌ "added feature" (past tense)
- ❌ "adds feature" (present tense)

**Capitalization:**
- ✅ "feat: add login" (lowercase after colon)
- ❌ "feat: Add login" (uppercase after colon)

**Punctuation:**
- ✅ "fix: resolve crash" (no period)
- ❌ "fix: resolve crash." (period at end)

**Length:**
- Target: 50 characters maximum
- Hard limit: 72 characters
- Include type, scope, colon, and description

## Integration with Agent

The commit-assistant agent uses this operation to:
1. Generate subject lines during commit message creation
2. Validate subject line format
3. Suggest improvements for clarity
4. Ensure conventional commits compliance

## Usage Examples

### Example 1: Basic Subject

```bash
# Input
/message-generation subject type:feat description:"add user authentication"

# Output
Subject: feat: add user authentication
Length: 30/50 characters
Status: ✓ Valid
```

### Example 2: Subject with Scope

```bash
# Input
/message-generation subject type:fix scope:api description:"resolve null pointer"

# Output
Subject: fix(api): resolve null pointer
Length: 30/50 characters
Status: ✓ Valid
```

### Example 3: Long Description Warning

```bash
# Input
/message-generation subject type:feat description:"add comprehensive OAuth2 authentication with multiple providers"

# Output
WARNING: Subject exceeds 50 characters (69 chars)
Suggested: feat: add OAuth2 authentication
Move details to body: "with multiple providers"
```

### Example 4: Mood Correction

```bash
# Input
/message-generation subject type:fix description:"fixed login bug"

# Output
Subject: fix: fix login bug
WARNING: Use imperative mood
Suggested: fix: resolve login bug
```

## Best Practices

**Be Specific:**
- ✅ "add OAuth authentication"
- ❌ "update code"

**Focus on What:**
- ✅ "fix crash on login"
- ❌ "fix issue with the login button that crashes when clicked"

**Omit Implementation:**
- ✅ "improve query performance"
- ❌ "add database index to users table"

**Use Conventional Types:**
- ✅ "feat: add feature"
- ❌ "feature: add feature"

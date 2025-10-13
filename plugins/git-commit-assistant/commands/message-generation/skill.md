---
description: Generate conventional commit messages following best practices
---

# Message Generation Skill - Semantic Commit Message Generation

Generate well-formatted commit messages that follow the Conventional Commits standard with proper type, scope, subject, body, and footer.

## Operations

- **subject** - Generate subject line: `<type>(<scope>): <description>`
- **body** - Compose commit body with bullet points
- **footer** - Add footer with breaking changes and issue references
- **validate** - Check conventional commits compliance
- **complete** - Generate full commit message (subject + body + footer)

## Router Logic

Parse $ARGUMENTS to determine which operation to perform:

1. Extract operation from first word of $ARGUMENTS
2. Extract remaining arguments as operation parameters
3. Route to appropriate instruction file:
   - "subject" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/generate-subject.md`
   - "body" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/write-body.md`
   - "footer" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/add-footer.md`
   - "validate" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/validate-message.md`
   - "complete" → Read `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation/complete-message.md`

4. Execute instructions with parameters
5. Return formatted commit message or validation results

## Error Handling

- If operation is unknown, list available operations
- If required parameters are missing, show required format
- If message validation fails, provide specific corrections
- If character limits exceeded, suggest rewording

## Usage Examples

```bash
# Generate subject line only
/message-generation subject type:feat scope:auth description:"add OAuth authentication"

# Write commit body
/message-generation body changes:"Implement OAuth2 flow,Add provider support,Include middleware"

# Add footer with issue references
/message-generation footer breaking:"authentication API changed" closes:123

# Validate existing message
/message-generation validate message:"feat(auth): add OAuth"

# Generate complete commit message
/message-generation complete type:feat scope:auth files:"src/auth/oauth.js,src/auth/providers.js"
```

## Conventional Commits Format

**Message Structure:**
```
<type>(<scope>): <subject>          ← Max 50 chars, imperative mood

<body>                               ← Optional, wrap at 72 chars
- Bullet point describing change 1
- Bullet point describing change 2

<footer>                             ← Optional
BREAKING CHANGE: description
Closes #123, #456
```

**Valid Types (priority order):**
1. feat - New feature
2. fix - Bug fix
3. docs - Documentation only
4. style - Formatting (no code change)
5. refactor - Code restructuring
6. perf - Performance improvement
7. test - Test additions/updates
8. build - Build system or dependencies
9. ci - CI/CD configuration
10. chore - Other maintenance
11. revert - Revert previous commit

---

**Base directory:** `/home/danie/projects/plugins/architect/open-plugins/plugins/git-commit-assistant/commands/message-generation`

**Current request:** $ARGUMENTS

Parse operation and route to appropriate instruction file.

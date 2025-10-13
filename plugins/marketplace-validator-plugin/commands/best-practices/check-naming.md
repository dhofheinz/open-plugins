## Operation: Check Naming Conventions

Validate plugin names against OpenPlugins lowercase-hyphen naming convention.

### Parameters from $ARGUMENTS

- **name**: Plugin name to validate (required)
- **fix**: Auto-suggest corrected name (optional, default: true)

### OpenPlugins Naming Convention

**Pattern**: `^[a-z0-9]+(-[a-z0-9]+)*$`

**Valid Examples**:
- `code-formatter`
- `test-runner`
- `deploy-automation`
- `api-client`
- `database-migration`

**Invalid Examples**:
- `Code-Formatter` (uppercase)
- `test_runner` (underscore)
- `Deploy Automation` (space)
- `APIClient` (camelCase)
- `-helper` (leading hyphen)
- `tool-` (trailing hyphen)

### Workflow

1. **Extract Name from Arguments**
   ```
   Parse $ARGUMENTS to extract name parameter
   If name not provided, return error
   ```

2. **Execute Naming Validator**
   ```bash
   Execute .scripts/naming-validator.sh "$name"

   Exit codes:
   - 0: Valid naming convention
   - 1: Invalid naming convention
   - 2: Missing required parameters
   ```

3. **Process Results**
   ```
   IF valid:
     Return success with confirmation
   ELSE:
     Return failure with specific violations
     Suggest corrected name if fix:true
     Provide examples
   ```

4. **Return Compliance Report**
   ```
   Format results:
   - Status: PASS/FAIL
   - Name: <provided-name>
   - Valid: yes/no
   - Issues: <list of violations>
   - Suggestion: <corrected-name>
   - Score impact: +5 points (if valid)
   ```

### Examples

```bash
# Valid name
/best-practices naming name:my-awesome-plugin
# Result: PASS - Valid lowercase-hyphen format

# Invalid name with uppercase
/best-practices naming name:MyPlugin
# Result: FAIL - Contains uppercase (M, P)
# Suggestion: my-plugin

# Invalid name with underscore
/best-practices naming name:test_runner
# Result: FAIL - Contains underscore (_)
# Suggestion: test-runner

# Invalid name with space
/best-practices naming name:"Test Runner"
# Result: FAIL - Contains space
# Suggestion: test-runner
```

### Error Handling

**Missing name parameter**:
```
ERROR: Missing required parameter 'name'

Usage: /best-practices naming name:<plugin-name>

Example: /best-practices naming name:my-plugin
```

**Empty name**:
```
ERROR: Name cannot be empty

Provide a valid plugin name following lowercase-hyphen convention.
```

### Output Format

**Success (Valid Name)**:
```
✅ Naming Convention: PASS

Name: code-formatter
Format: lowercase-hyphen
Pattern: ^[a-z0-9]+(-[a-z0-9]+)*$
Valid: Yes

Quality Score Impact: +5 points

The name follows OpenPlugins naming conventions perfectly.
```

**Failure (Invalid Name)**:
```
❌ Naming Convention: FAIL

Name: Code_Formatter
Format: Invalid
Valid: No

Issues Found:
1. Contains uppercase characters: C, F
2. Contains underscores instead of hyphens

Suggested Correction: code-formatter

Quality Score Impact: 0 points (fix to gain +5)

Fix these issues to comply with OpenPlugins standards.
```

### Compliance Criteria

**PASS Requirements**:
- All lowercase letters (a-z)
- Numbers allowed (0-9)
- Hyphens for word separation
- No leading or trailing hyphens
- No consecutive hyphens
- No other special characters
- Descriptive (not generic like "plugin" or "tool")

**FAIL Indicators**:
- Uppercase letters
- Underscores, spaces, or special characters
- Leading/trailing hyphens
- Empty or single character names
- Generic non-descriptive names

### Best Practices Guidance

**Good Names**:
- Describe functionality: `code-formatter`, `test-runner`
- Include technology: `python-linter`, `docker-manager`
- Indicate purpose: `api-client`, `database-migrator`

**Avoid**:
- Generic: `plugin`, `tool`, `helper`, `utility`
- Abbreviations only: `fmt`, `tst`, `db`
- Version numbers: `plugin-v2`, `tool-2024`

**Request**: $ARGUMENTS

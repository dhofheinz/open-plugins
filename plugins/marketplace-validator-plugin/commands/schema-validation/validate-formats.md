## Operation: Validate Formats

Validate format compliance for semver, URLs, email addresses, and naming conventions.

### Parameters from $ARGUMENTS

- **path**: Path to plugin directory or marketplace file (required)
- **type**: Target type: `plugin` or `marketplace` (optional, auto-detect)
- **strict**: Enforce HTTPS for all URLs (optional, default: false)

### Workflow

1. **Locate Configuration File**
   ```
   Auto-detect or use specified type:
     Plugin: plugin.json
     Marketplace: marketplace.json or .claude-plugin/marketplace.json
   ```

2. **Execute Format Validation**
   ```
   Execute .scripts/format-validator.py --file "$config" --type "$type" --strict "$strict"

   Validates:
     - Semantic versioning (X.Y.Z)
     - Lowercase-hyphen naming (^[a-z0-9]+(-[a-z0-9]+)*$)
     - URL formats (http/https)
     - Email addresses (RFC 5322 compliant)
     - License identifiers (SPDX)
     - Category names (10 approved categories)
   ```

3. **Report Results**
   ```
   For each field:
     ✅ Valid format
     ❌ Invalid format with specific error and remediation

   Summary:
     - Total fields checked
     - Passed count
     - Failed count
     - Exit code: 0 (all pass) or 1 (any fail)
   ```

### Format Validation Rules

**Semantic Versioning (version field)**:
- Pattern: `X.Y.Z` where X, Y, Z are non-negative integers
- Valid: `1.0.0`, `2.5.3`, `10.20.30`
- Invalid: `1.0`, `v1.0.0`, `1.0.0-beta` (pre-release allowed but optional)

**Lowercase-Hyphen Naming (name field)**:
- Pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- Valid: `my-plugin`, `test-marketplace`, `plugin123`
- Invalid: `My-Plugin`, `test_plugin`, `plugin.name`, `-plugin`, `plugin-`

**URL Format (homepage, repository fields)**:
- Must start with `http://` or `https://`
- Strict mode: Only `https://` allowed
- Valid: `https://example.com`, `http://localhost:3000`
- Invalid: `example.com`, `www.example.com`, `ftp://example.com`

**Email Format (owner.email, author.email fields)**:
- RFC 5322 compliant pattern
- Valid: `user@example.com`, `name.surname@company.co.uk`
- Invalid: `user@`, `@example.com`, `user example.com`

**License Identifier (license field)**:
- SPDX identifier or "Proprietary"
- Common: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause
- Valid: `MIT`, `Apache-2.0`, `ISC`, `Proprietary`
- Invalid: `mit`, `Apache 2.0`, `BSD`

**Category (category field)**:
- One of 10 approved categories
- Valid: development, testing, deployment, documentation, security, database, monitoring, productivity, quality, collaboration
- Invalid: coding, devops, tools, utilities

### Examples

```bash
# Validate plugin formats
/schema-validation formats path:.

# Validate marketplace with strict HTTPS enforcement
/schema-validation formats path:./test-marketplace type:marketplace strict:true

# Validate specific plugin
/schema-validation formats path:./my-plugin type:plugin
```

### Error Handling

- **File not found**: Show expected locations
- **Invalid JSON**: Suggest running json validation first
- **Format violation**: Specific error with correct pattern
- **Unknown field**: Warn but don't fail

### Output Format

**Success (all formats valid)**:
```
✅ Format Validation: PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: plugin.json
Type: plugin

Format Checks (7/7):
  ✅ name: "my-plugin" (lowercase-hyphen)
  ✅ version: "1.0.0" (semver)
  ✅ description: Valid length (73 chars)
  ✅ license: "MIT" (SPDX identifier)
  ✅ homepage: "https://example.com" (valid URL)
  ✅ repository: "https://github.com/user/repo" (valid URL)
  ✅ category: "development" (approved category)

Status: PASS
```

**Failure (format violations)**:
```
❌ Format Validation: FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: plugin.json
Type: plugin

Format Checks (4/7):
  ❌ name: "My-Plugin"
     Invalid: Must use lowercase-hyphen format
     Pattern: ^[a-z0-9]+(-[a-z0-9]+)*$
     Example: my-plugin, test-tool, plugin123

  ❌ version: "1.0"
     Invalid: Must use semantic versioning (X.Y.Z)
     Expected: Three version numbers separated by dots
     Example: 1.0.0, 2.1.5

  ✅ description: Valid (80 characters)

  ❌ license: "Apache 2.0"
     Invalid: Must be SPDX identifier
     Expected: Apache-2.0
     Valid identifiers: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause

  ⚠️  homepage: "http://example.com"
     Warning: Consider using HTTPS for security
     Current: http://example.com
     Recommended: https://example.com

  ✅ repository: "https://github.com/user/repo"

  ❌ category: "coding"
     Invalid: Must be one of 10 approved categories
     Valid: development, testing, deployment, documentation,
            security, database, monitoring, productivity,
            quality, collaboration

Failed: 4
Warnings: 1
Status: FAIL

Action Required:
  Fix format violations:
    - name: Convert to lowercase-hyphen (my-plugin)
    - version: Use semver format (1.0.0)
    - license: Use SPDX identifier (Apache-2.0)
    - category: Choose approved category (development)
```

**Marketplace Example**:
```
✅ Format Validation: PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: marketplace.json
Type: marketplace

Format Checks (4/4):
  ✅ name: "enterprise-marketplace" (lowercase-hyphen)
  ✅ owner.email: "devtools@company.com" (valid email)
  ✅ metadata.homepage: "https://company.com/plugins" (valid HTTPS URL)
  ✅ metadata.repository: "https://github.com/company/plugins" (valid HTTPS URL)

Status: PASS
Strict HTTPS: Enforced ✅
```

### Integration

This operation is called by:
- `full-schema-validation.md` - Third validation step after fields check
- `best-practices` skill - Naming and versioning validation
- Direct user invocation for format checking

**Request**: $ARGUMENTS

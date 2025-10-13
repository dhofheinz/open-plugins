## Operation: Check Plugin Entries

Validate plugin entries in marketplace configuration for completeness and format compliance.

### Parameters from $ARGUMENTS

- **marketplace**: Path to marketplace.json file (required)
- **strict**: Require all recommended fields in plugin entries (optional, default: false)
- **index**: Validate specific plugin entry by index (optional, validates all if not specified)

### Workflow

1. **Load Marketplace Configuration**
   ```
   Locate marketplace.json:
     - Direct path: <marketplace>
     - Relative: <marketplace>/marketplace.json
     - Claude plugin: <marketplace>/.claude-plugin/marketplace.json

   Validate JSON syntax first
   ```

2. **Extract Plugin Entries**
   ```
   Parse plugins array from marketplace.json
   Count total entries
   Determine which entries to validate (all or specific index)
   ```

3. **Validate Each Plugin Entry**
   ```
   For each plugin entry, execute .scripts/schema-differ.sh

   Check required fields:
     - name (string, lowercase-hyphen)
     - source (string, valid format: ./path, github:, https://)
     - description (string, non-empty)

   Check recommended fields:
     - version (string, semver)
     - author (string or object)
     - keywords (array, 3-7 items)
     - license (string, SPDX identifier)

   Validate field formats:
     - name: lowercase-hyphen pattern
     - version: semantic versioning
     - source: valid source format
     - license: SPDX identifier
   ```

4. **Aggregate Results**
   ```
   Per-entry summary:
     - Entry index
     - Plugin name
     - Status: PASS/FAIL
     - Missing required fields
     - Missing recommended fields
     - Format violations

   Overall summary:
     - Total entries
     - Passed count
     - Failed count
     - Total issues
   ```

### Plugin Entry Required Fields

- `name`: Unique plugin identifier (lowercase-hyphen)
- `source`: Where to locate plugin (./path, github:user/repo, https://url)
- `description`: Brief plugin description (non-empty)

### Plugin Entry Recommended Fields

- `version`: Plugin version (semver)
- `author`: Plugin author (string or object)
- `keywords`: Search keywords (array of 3-7 strings)
- `license`: License identifier (SPDX)
- `homepage`: Documentation URL
- `repository`: Source code URL

### Source Format Validation

**Relative Path**:
- Pattern: `./` or `../`
- Example: `./plugins/my-plugin`

**GitHub Format**:
- Pattern: `github:owner/repo`
- Example: `github:anthropics/claude-plugin`

**Git URL**:
- Pattern: `https://...git`
- Example: `https://github.com/user/plugin.git`

**Archive URL**:
- Pattern: `https://....(zip|tar.gz|tgz)`
- Example: `https://example.com/plugin.zip`

### Examples

```bash
# Validate all plugin entries in marketplace
/schema-validation entries marketplace:./test-marketplace

# Validate with strict mode (require recommended fields)
/schema-validation entries marketplace:marketplace.json strict:true

# Validate specific plugin entry by index
/schema-validation entries marketplace:marketplace.json index:0
```

### Error Handling

- **Marketplace not found**: Show searched paths
- **Invalid JSON**: Suggest running json validation
- **No plugins array**: Error - required field
- **Empty plugins array**: Warning - marketplace has no plugins
- **Invalid index**: Error with valid range

### Output Format

**Success (all entries valid)**:
```
✅ Plugin Entries Validation: PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Marketplace: ./test-marketplace/marketplace.json
Total Entries: 3

Entry 0: code-review ✅
  Required (3/3):
    ✅ name: "code-review"
    ✅ source: "./plugins/code-review"
    ✅ description: "Automated code review..."

  Recommended (4/4):
    ✅ version: "2.0.0"
    ✅ author: Present
    ✅ keywords: 3 items
    ✅ license: "MIT"

Entry 1: deploy-tools ✅
  Required (3/3):
    ✅ name: "deploy-tools"
    ✅ source: "github:company/deploy"
    ✅ description: "Deployment automation..."

  Recommended (3/4):
    ✅ version: "1.5.0"
    ✅ author: Present
    ⚠️  keywords: Missing

Entry 2: security-scan ✅
  Required (3/3):
    ✅ name: "security-scan"
    ✅ source: "https://example.com/plugin.zip"
    ✅ description: "Security vulnerability scanning..."

Summary:
  Total: 3 entries
  Passed: 3 (100%)
  Failed: 0
  Warnings: 1 (non-blocking)

Status: PASS
```

**Failure (validation errors)**:
```
❌ Plugin Entries Validation: FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Marketplace: marketplace.json
Total Entries: 2

Entry 0: my-plugin ❌
  Required (2/3):
    ❌ name: "My-Plugin"
       Invalid: Must use lowercase-hyphen format
       Expected: my-plugin

    ❌ source: Missing (REQUIRED)

    ✅ description: "My awesome plugin"

  Recommended (1/4):
    ✅ version: "1.0.0"
    ❌ author: Missing
    ❌ keywords: Missing
    ❌ license: Missing

  Issues: 5 (2 critical, 3 warnings)

Entry 1: test-tool ✅
  Required (3/3):
    ✅ name: "test-tool"
    ✅ source: "./plugins/test-tool"
    ✅ description: "Testing utilities"

  Recommended (2/4):
    ⚠️  version: Missing
    ⚠️  author: Missing

Summary:
  Total: 2 entries
  Passed: 1 (50%)
  Failed: 1 (50%)
  Critical Issues: 2
  Warnings: 5

Status: FAIL

Action Required:
  Fix plugin entry #0 (my-plugin):
    - Change name to lowercase-hyphen: "my-plugin"
    - Add source field: "./plugins/my-plugin"
    - Consider adding: author, keywords, license
```

**Empty Marketplace**:
```
⚠️  Plugin Entries Validation: WARNING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Marketplace: marketplace.json

⚠️  No plugin entries found
    - plugins array is empty
    - Add at least one plugin entry to marketplace

Status: WARNING (empty marketplace)
```

### Integration

This operation is called by:
- `full-schema-validation.md` - When validating marketplace type
- `validation-orchestrator` - Marketplace comprehensive validation
- Direct user invocation for plugin entry checking

**Request**: $ARGUMENTS

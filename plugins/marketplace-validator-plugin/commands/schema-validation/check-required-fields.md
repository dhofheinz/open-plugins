## Operation: Check Required Fields

Verify all required fields are present and non-empty in plugin or marketplace configuration.

### Parameters from $ARGUMENTS

- **path**: Path to plugin directory or marketplace file (required)
- **type**: Target type: `plugin` or `marketplace` (required)
- **strict**: Fail on missing recommended fields (optional, default: false)

### Workflow

1. **Detect Target Type**
   ```
   IF type not specified:
     Auto-detect based on path structure:
       - Has .claude-plugin/plugin.json → plugin
       - Has marketplace.json or .claude-plugin/marketplace.json → marketplace
       - Otherwise → error
   ```

2. **Locate Configuration File**
   ```
   For plugin:
     Check: <path>/.claude-plugin/plugin.json
     OR: <path>/plugin.json

   For marketplace:
     Check: <path>/marketplace.json
     OR: <path>/.claude-plugin/marketplace.json

   IF not found:
     Return error with searched paths
   ```

3. **Execute Field Validation**
   ```
   Execute .scripts/field-checker.sh "$config_file" "$type" "$strict"

   Returns:
     - List of required fields: present ✅ or missing ❌
     - List of recommended fields: present ✅ or missing ⚠️
     - Overall status: PASS or FAIL
   ```

4. **Aggregate Results**
   ```
   Count:
     - Required missing: critical errors
     - Recommended missing: warnings

   IF any required missing:
     Exit with status 1

   IF strict mode AND any recommended missing:
     Exit with status 1

   Otherwise:
     Exit with status 0
   ```

### Required Fields by Type

**Plugin** (from plugin.json):
- `name` (string, lowercase-hyphen format)
- `version` (string, semver X.Y.Z)
- `description` (string, 50-200 characters)
- `author` (string or object with name field)
- `license` (string, SPDX identifier)

**Marketplace** (from marketplace.json):
- `name` (string, lowercase-hyphen format)
- `owner` (object with name field)
- `owner.name` (string)
- `owner.email` (string, valid email format)
- `plugins` (array, at least one entry)

### Recommended Fields

**Plugin**:
- `repository` (object or string, source code location)
- `homepage` (string, documentation URL)
- `keywords` (array, 3-7 relevant keywords)
- `category` (string, one of 10 approved categories)

**Marketplace**:
- `version` (string, marketplace version)
- `metadata.description` (string, marketplace purpose)
- `metadata.homepage` (string, marketplace documentation)
- `metadata.repository` (string, marketplace source)

### Examples

```bash
# Check plugin required fields
/schema-validation fields path:. type:plugin

# Check marketplace with strict mode (fail on missing recommended)
/schema-validation fields path:./test-marketplace type:marketplace strict:true

# Auto-detect type
/schema-validation fields path:.
```

### Error Handling

- **File not found**: List all searched paths
- **Invalid JSON**: Suggest running json validation first
- **Unknown type**: Show valid types (plugin, marketplace)
- **Empty field**: Report which field is present but empty

### Output Format

**Success (all required present)**:
```
✅ Required Fields Validation: PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: .claude-plugin/plugin.json
Type: plugin

Required Fields (5/5):
  ✅ name: "my-plugin"
  ✅ version: "1.0.0"
  ✅ description: "My awesome plugin"
  ✅ author: "Developer Name"
  ✅ license: "MIT"

Recommended Fields (3/4):
  ✅ repository: Present
  ✅ homepage: Present
  ✅ keywords: Present
  ⚠️  category: Missing (improves discoverability)

Status: PASS
Warnings: 1 (non-blocking)
```

**Failure (missing required)**:
```
❌ Required Fields Validation: FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: .claude-plugin/plugin.json
Type: plugin

Required Fields (3/5):
  ✅ name: "my-plugin"
  ❌ version: Missing (REQUIRED - use semver X.Y.Z)
  ✅ description: "My plugin"
  ❌ license: Missing (REQUIRED - use MIT, Apache-2.0, etc.)
  ✅ author: "Developer"

Critical Issues: 2
Status: FAIL

Action Required:
  Add missing required fields to plugin.json:
    - version: "1.0.0"
    - license: "MIT"
```

**Marketplace Example**:
```
✅ Required Fields Validation: PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: marketplace.json
Type: marketplace

Required Fields (5/5):
  ✅ name: "my-marketplace"
  ✅ owner.name: "DevTools Team"
  ✅ owner.email: "devtools@example.com"
  ✅ plugins: Array with 3 entries

Status: PASS
```

### Integration

This operation is called by:
- `full-schema-validation.md` - Second validation step after JSON syntax
- `validation-orchestrator` - Comprehensive validation checks
- Direct user invocation for field checking

**Request**: $ARGUMENTS

## Operation: Full Schema Validation

Execute complete schema validation workflow: JSON syntax → Required fields → Format compliance → Plugin entries (if marketplace).

### Parameters from $ARGUMENTS

- **path**: Path to plugin directory or marketplace (required)
- **type**: Target type: `plugin` or `marketplace` (optional, auto-detect)
- **strict**: Fail on warnings and missing recommended fields (optional, default: false)
- **verbose**: Show detailed error information (optional, default: false)

### Workflow

1. **Detect Target Type**
   ```
   IF type not specified:
     Auto-detect based on path structure:
       - Has .claude-plugin/plugin.json → plugin
       - Has marketplace.json → marketplace
       - Otherwise → error

   Locate configuration file:
     Plugin: <path>/.claude-plugin/plugin.json
     Marketplace: <path>/marketplace.json or <path>/.claude-plugin/marketplace.json
   ```

2. **Phase 1: JSON Syntax Validation**
   ```
   Read validate-json.md instructions

   Execute: .scripts/json-validator.py --file "$config" --verbose "$verbose"

   On failure:
     - Report JSON syntax errors
     - Stop validation (cannot proceed with invalid JSON)
     - Exit with status 1

   On success:
     - Continue to Phase 2
   ```

3. **Phase 2: Required Fields Check**
   ```
   Read check-required-fields.md instructions

   Execute: .scripts/field-checker.sh "$config" "$type" "$strict"

   Collect results:
     - Required fields: present/missing
     - Recommended fields: present/missing
     - Critical errors count
     - Warnings count

   On failure:
     - Report missing required fields
     - Continue to Phase 3 (show all issues)

   On success:
     - Continue to Phase 3
   ```

4. **Phase 3: Format Validation**
   ```
   Read validate-formats.md instructions

   Execute: .scripts/format-validator.py --file "$config" --type "$type" --strict "$strict"

   Validate:
     - Semantic versioning
     - Lowercase-hyphen naming
     - URL formats
     - Email addresses
     - License identifiers
     - Category names (if present)

   Collect results:
     - Format violations count
     - Warnings count
   ```

5. **Phase 4: Plugin Entries Validation (Marketplace Only)**
   ```
   IF type == "marketplace":
     Read check-plugin-entries.md instructions

     Execute: .scripts/schema-differ.sh "$config" "all"

     Validate each plugin entry:
       - Required fields (name, source, description)
       - Recommended fields (version, author, license, keywords)
       - Format compliance

     Collect results:
       - Total plugin entries
       - Passed entries
       - Failed entries
       - Total issues per entry
   ```

6. **Aggregate Results**
   ```
   Compile all validation phases:
     Phase 1: JSON Syntax [PASS/FAIL]
     Phase 2: Required Fields [PASS/FAIL]
     Phase 3: Format Compliance [PASS/FAIL]
     Phase 4: Plugin Entries [PASS/FAIL] (marketplace only)

   Calculate overall status:
     IF any phase FAIL: Overall FAIL
     IF strict mode AND any warnings: Overall FAIL
     ELSE: Overall PASS

   Generate summary report:
     - Total checks performed
     - Critical errors
     - Warnings
     - Overall status
     - Publication readiness
   ```

### Exit Codes

- **0**: All validation passed (or warnings only in non-strict mode)
- **1**: Validation failed (critical errors or strict mode with warnings)
- **2**: Error (file not found, invalid arguments, etc.)

### Examples

```bash
# Full validation with auto-detect
/schema-validation full-schema path:.

# Full plugin validation with strict mode
/schema-validation full-schema path:. type:plugin strict:true

# Full marketplace validation with verbose output
/schema-validation full-schema path:./test-marketplace type:marketplace verbose:true

# Validate specific plugin in subdirectory
/schema-validation full-schema path:./plugins/my-plugin type:plugin
```

### Integration

This operation is the primary entry point for complete schema validation and is called by:
- `validation-orchestrator` comprehensive validation
- Marketplace submission workflows
- CI/CD validation pipelines
- Direct user invocation for thorough checking

### Output Format

**Success (all phases pass)**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FULL SCHEMA VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: .claude-plugin/plugin.json
Type: plugin
Mode: Standard

Phase 1: JSON Syntax ✅
  Status: Valid JSON
  Backend: jq

Phase 2: Required Fields ✅
  Required: 5/5 present
  Recommended: 3/4 present
  Missing: category (non-critical)

Phase 3: Format Compliance ✅
  Checks: 7/7 passed
  Version: 1.0.0 (valid semver)
  Name: my-plugin (valid lowercase-hyphen)
  License: MIT (valid SPDX)
  URLs: All valid HTTPS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: ✅ PASS

Checks Performed: 15
  Critical Errors: 0
  Warnings: 1
  Passed: 14

Publication Readiness: READY ✅
  Your plugin meets all required standards
  Consider adding: category field for better discoverability

Quality Score: 95/100 ⭐⭐⭐⭐⭐
```

**Failure (multiple phases fail)**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FULL SCHEMA VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: .claude-plugin/plugin.json
Type: plugin
Mode: Standard

Phase 1: JSON Syntax ✅
  Status: Valid JSON
  Backend: python3

Phase 2: Required Fields ❌
  Required: 3/5 present
  Missing:
    ❌ version (REQUIRED - use semver X.Y.Z)
    ❌ license (REQUIRED - use MIT, Apache-2.0, etc.)

Phase 3: Format Compliance ❌
  Checks: 4/6 passed
  Violations:
    ❌ name: "My-Plugin" - must use lowercase-hyphen
    ❌ homepage: "example.com" - must be valid URL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: ❌ FAIL

Checks Performed: 11
  Critical Errors: 4
  Warnings: 0
  Passed: 7

Publication Readiness: NOT READY ❌
  Fix 4 critical issues before submission

Priority Actions:
  1. Add version field: "1.0.0"
  2. Add license field: "MIT"
  3. Fix name format: "my-plugin"
  4. Fix homepage URL: "https://example.com"

Quality Score: 45/100 ⭐⭐
Rating: Needs Improvement

Next Steps:
  1. Fix all critical errors above
  2. Re-run validation: /schema-validation full-schema path:.
  3. Aim for quality score 90+ for publication
```

**Marketplace Example (with plugin entries)**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FULL SCHEMA VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Target: marketplace.json
Type: marketplace
Mode: Standard

Phase 1: JSON Syntax ✅
  Status: Valid JSON

Phase 2: Required Fields ✅
  Required: 5/5 present
  Recommended: 4/4 present

Phase 3: Format Compliance ✅
  Checks: 4/4 passed

Phase 4: Plugin Entries ✅
  Total Entries: 3
  Passed: 3 (100%)
  Failed: 0

  Entry 0: code-review ✅
  Entry 1: deploy-tools ✅
  Entry 2: security-scan ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VALIDATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: ✅ PASS

Checks Performed: 23
  Critical Errors: 0
  Warnings: 0
  Passed: 23

Publication Readiness: READY ✅
  Your marketplace meets all standards
  All 3 plugin entries are valid

Quality Score: 100/100 ⭐⭐⭐⭐⭐
Rating: Excellent
```

### Error Handling

- **File not found**: List searched paths, suggest creating configuration
- **Invalid JSON**: Stop at Phase 1, show syntax errors
- **Auto-detect failure**: Suggest specifying type explicitly
- **Script execution error**: Show script path and error message

### Performance

- **Plugin**: 1-2 seconds (3 phases)
- **Marketplace**: 2-5 seconds (4 phases, depends on plugin entry count)
- **Large Marketplace**: 5-10 seconds (50+ plugin entries)

**Request**: $ARGUMENTS

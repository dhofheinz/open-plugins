## Operation: Validate JSON Syntax

Validate JSON file syntax with multi-backend support (jq + python3 fallback).

### Parameters from $ARGUMENTS

- **file**: Path to JSON file (required)
- **verbose**: Show detailed error information (optional, default: false)

### Workflow

1. **Parse Arguments**
   ```
   Extract file path from $ARGUMENTS
   Check if verbose mode requested
   ```

2. **Validate File Exists**
   ```
   IF file does not exist:
     Return error with file path
     Exit with status 1
   ```

3. **Detect JSON Tool**
   ```
   Execute .scripts/json-validator.py --detect
   Primary: jq (faster, better error messages)
   Fallback: python3 (universal availability)
   ```

4. **Validate JSON Syntax**
   ```
   Execute .scripts/json-validator.py --file "$file" --verbose "$verbose"

   On success:
     - Print success message with file path
     - Return 0

   On failure:
     - Print error message with line number and details
     - Show problematic JSON section
     - Return 1
   ```

### Examples

```bash
# Basic JSON validation
/schema-validation json file:plugin.json

# Verbose validation with details
/schema-validation json file:marketplace.json verbose:true

# Validate multiple files (call multiple times)
/schema-validation json file:plugin1.json
/schema-validation json file:plugin2.json
```

### Error Handling

- **File not found**: Clear message with expected path
- **Invalid JSON**: Line number, character position, error description
- **No JSON tool available**: Instruction to install jq or python3
- **Permission denied**: File access error with remediation

### Output Format

**Success**:
```
✅ Valid JSON: plugin.json
Backend: jq
```

**Failure (basic)**:
```
❌ Invalid JSON: marketplace.json
Error: Unexpected token at line 15
```

**Failure (verbose)**:
```
❌ Invalid JSON: marketplace.json
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error Details:
  Line: 15
  Position: 8
  Issue: Expected ',' or ']' but got '}'

Problematic Section (lines 13-17):
  13  |   "plugins": [
  14  |     {
  15  |       "name": "test"
  16  |     }
  17  |   }

Remediation:
  - Check for missing commas between array elements
  - Verify bracket matching: [ ] { }
  - Use a JSON formatter/linter in your editor
```

### Integration

This operation is called by:
- `full-schema-validation.md` - First validation step
- `validation-orchestrator` - Quick validation checks
- Direct user invocation for single file checks

**Request**: $ARGUMENTS

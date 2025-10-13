## Operation: Run Quick Validation

Execute fast essential validation checks for rapid feedback on critical issues only.

### Parameters from $ARGUMENTS

- **path**: Path to validation target (required)
  - Format: `path:/path/to/target` or `path:.`
  - Default: `.` (current directory)

### Quick Validation Scope

Focus on **critical issues only**:
- JSON syntax validation
- Required fields presence
- Basic format compliance
- Security red flags

**NOT included** (saves time):
- Comprehensive quality scoring
- Detailed documentation analysis
- Best practices enforcement
- Optional field checks

### Workflow

1. **Detect Target Type**
   ```
   Execute .scripts/target-detector.sh "$path"
   Determine if marketplace or plugin
   ```

2. **Route to Appropriate Quick Validator**
   ```
   IF target_type == "marketplace":
     Invoke existing /validate-quick for marketplace
   ELSE IF target_type == "plugin":
     Invoke existing /validate-quick for plugin
   ELSE:
     Report unable to determine target type
   ```

3. **Execute Quick Checks**
   ```
   Run only critical validations:
   - JSON syntax (MUST pass)
   - Required fields (MUST be present)
   - Format violations (MUST be valid)
   - Security issues (MUST be clean)
   ```

4. **Aggregate Results**
   ```
   Collect validation output
   Count critical errors
   Determine pass/fail status
   ```

### Integration with Existing Commands

This operation leverages the existing quick validation commands:
- `/validate-quick` (marketplace mode)
- `/validate-quick` (plugin mode)

The orchestrator adds:
- Automatic target detection
- Unified interface
- Consistent output format
- Progressive validation routing

### Examples

**Quick check current directory:**
```bash
/validation-orchestrator quick path:.
```

**Quick check specific plugin:**
```bash
/validation-orchestrator quick path:/path/to/my-plugin
```

### Performance Target

Quick validation should complete in **< 2 seconds** for typical targets.

### Error Handling

- **Target not found**: Clear error with path verification
- **Ambiguous target**: Ask user to specify marketplace or plugin
- **Invalid structure**: Report structural issues found
- **Validation script failure**: Fallback to manual checks

### Output Format

```
Quick Validation Results
━━━━━━━━━━━━━━━━━━━━━━
Target: <path>
Type: <marketplace|plugin>
Status: <PASS|FAIL>

Critical Issues: <count>
❌ <issue 1 if any>
❌ <issue 2 if any>

Result: <Ready for comprehensive validation | Fix critical issues first>
```

Return concise, actionable results focusing on blocking issues only.

**Request**: $ARGUMENTS

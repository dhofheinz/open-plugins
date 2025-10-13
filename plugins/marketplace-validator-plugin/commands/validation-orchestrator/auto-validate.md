## Operation: Auto-Validate (Intelligent Detection + Validation)

Automatically detect target type and execute the most appropriate validation workflow.

### Parameters from $ARGUMENTS

- **path**: Path to validation target (required)
  - Format: `path:/path/to/target` or `path:.`
  - Default: `.` (current directory)

- **level**: Validation depth (optional)
  - Format: `level:quick|comprehensive`
  - Default: `comprehensive`
  - Options:
    - `quick`: Fast critical checks only
    - `comprehensive`: Full quality audit

### Auto-Validation Workflow

This operation provides the most intelligent, hands-off validation experience by:
1. Automatically detecting what needs to be validated
2. Choosing the appropriate validation commands
3. Executing the optimal validation workflow
4. Providing actionable results

### Detailed Workflow

1. **Target Detection Phase**
   ```
   Execute .scripts/target-detector.sh "$path"

   IF marketplace.json found:
     target_type = "marketplace"
     recommended_command = "/validate-marketplace"

   ELSE IF plugin.json found:
     target_type = "plugin"
     recommended_command = "/validate-plugin"

   ELSE IF both found:
     target_type = "multi-target"
     recommended_command = "validate both separately"

   ELSE:
     target_type = "unknown"
     REPORT error and exit
   ```

2. **Validation Level Selection**
   ```
   IF level == "quick" OR user requested quick:
     validation_mode = "quick"
     Execute fast critical checks

   ELSE IF level == "comprehensive" OR default:
     validation_mode = "comprehensive"
     Execute full validation suite
   ```

3. **Execute Appropriate Validation**
   ```
   CASE target_type:
     "marketplace":
       IF validation_mode == "quick":
         Invoke /validate-quick (marketplace mode)
       ELSE:
         Invoke /validate-marketplace full-analysis

     "plugin":
       IF validation_mode == "quick":
         Invoke /validate-quick (plugin mode)
       ELSE:
         Invoke /validate-plugin full-analysis

     "multi-target":
       Validate marketplace first
       Then validate plugin
       Aggregate results

     "unknown":
       Report detection failure
       Provide troubleshooting guidance
   ```

4. **Post-Validation Actions**
   ```
   Aggregate all validation results
   Calculate overall quality assessment
   Provide publication readiness determination
   Offer next steps and guidance
   ```

### Intelligence Features

**Smart Defaults**:
- Defaults to comprehensive validation (thoroughness over speed)
- Automatically selects correct validation command
- Handles edge cases gracefully

**Context Awareness**:
- Recognizes marketplace vs plugin automatically
- Adjusts validation criteria accordingly
- Provides context-specific recommendations

**User Guidance**:
- Explains what was detected
- Shows which validation ran
- Provides clear next steps

### Examples

**Auto-validate current directory (comprehensive):**
```bash
/validation-orchestrator auto path:.
```

**Auto-validate with quick mode:**
```bash
/validation-orchestrator auto path:. level:quick
```

**Auto-validate specific plugin:**
```bash
/validation-orchestrator auto path:/path/to/my-plugin
```

**Auto-validate marketplace:**
```bash
/validation-orchestrator auto path:/path/to/marketplace
```

### Typical User Journey

```
User: "Is my plugin ready to submit?"

Agent detects this as validation request
→ Invokes /validation-orchestrator auto path:.

Orchestrator:
1. Detects plugin.json in current directory
2. Determines target is a plugin
3. Executes comprehensive plugin validation
4. Returns quality score and readiness assessment

Agent interprets results and guides user
```

### Error Handling

**Detection Failures**:
```
❌ Unable to detect target type at path: <path>

Troubleshooting:
- Ensure path contains .claude-plugin directory
- Verify plugin.json or marketplace.json exists
- Check file permissions
- Try specifying the path explicitly

Example:
  /validation-orchestrator auto path:/correct/path
```

**Validation Failures**:
```
⚠️  Validation completed with errors

Target: <path>
Type: <detected-type>
Status: FAIL

See detailed output above for specific issues.

Next steps:
1. Fix critical errors (❌)
2. Address important warnings (⚠️)
3. Re-run validation: /validation-orchestrator auto path:.
```

**Ambiguous Structure**:
```
⚠️  Multiple targets detected

Found:
- marketplace.json at <path>
- plugin.json at <path>

Validating both...

Marketplace Results:
<marketplace validation output>

Plugin Results:
<plugin validation output>
```

### Output Format

```
Auto-Validation Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Detection Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Target detected: <marketplace|plugin>
📁 Path: <absolute-path>
📄 Manifest: <file-found>
🎯 Validation mode: <quick|comprehensive>

Validation Phase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<Full validation output from appropriate command>

Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality Score: <0-100>/100 <⭐⭐⭐⭐⭐>
Rating: <Excellent|Good|Fair|Needs Improvement|Poor>
Publication Ready: <Yes|No|With Changes>

Critical Issues: <count>
Warnings: <count>
Recommendations: <count>

Next Steps:
<prioritized action items>
```

### Performance

- **Quick mode**: < 2 seconds (detection + quick validation)
- **Comprehensive mode**: 5-10 seconds (detection + full validation)

### Integration with Agent

This operation is ideal for agent invocation because:
- Single command, automatic behavior
- No user decision required (smart defaults)
- Comprehensive results
- Clear publication readiness assessment

The marketplace-validator agent can simply invoke:
```
/validation-orchestrator auto path:.
```

And get complete validation with no additional parameters needed.

**Request**: $ARGUMENTS

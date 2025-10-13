## Operation: Run Comprehensive Validation

Execute complete quality audit with detailed analysis, scoring, and recommendations.

### Parameters from $ARGUMENTS

- **path**: Path to validation target (required)
  - Format: `path:/path/to/target`
  - Default: `.` (current directory)
- **report**: Generate detailed report (optional)
  - Format: `report:true|false`
  - Default: `true`

### Comprehensive Validation Scope

Execute **all validation layers**:

1. **Schema Validation** (via `/schema-validation full-schema`)
   - JSON syntax and structure
   - Required and recommended fields
   - Format compliance
   - Type validation

2. **Security Scanning** (via `/security-scan full-security-audit`)
   - Secret detection
   - URL safety checks
   - File permission validation
   - Vulnerability scanning

3. **Quality Analysis** (via `/quality-analysis full-analysis`)
   - Quality score calculation (0-100)
   - Star rating generation
   - Issue prioritization
   - Improvement recommendations

4. **Documentation Validation** (via `/documentation-validation full-docs`)
   - README completeness
   - CHANGELOG format
   - LICENSE presence
   - Example quality

5. **Best Practices Enforcement** (via `/best-practices full-standards`)
   - Naming conventions
   - Versioning compliance
   - Category validation
   - Keyword quality

### Workflow

1. **Initialize Validation**
   ```
   Detect target type using .scripts/target-detector.sh
   Create validation context
   Set up result aggregation
   ```

2. **Execute Validation Layers** (parallel where possible)
   ```
   PARALLEL:
     Layer 1: /schema-validation full-schema path:"$path"
     Layer 2: /security-scan full-security-audit path:"$path"
     Layer 3: /documentation-validation full-docs path:"$path"
     Layer 4: /best-practices full-standards path:"$path"

   AFTER all complete:
     Layer 5: /quality-analysis full-analysis path:"$path" context:"$all_results"
   ```

3. **Aggregate Results**
   ```
   Execute .scripts/validation-dispatcher.py --mode=aggregate
   Compile all layer results
   Calculate overall quality score
   Prioritize issues (Critical → Important → Recommended)
   Generate actionable recommendations
   ```

4. **Generate Report** (if requested)
   ```
   IF report parameter is true:
     Generate comprehensive markdown report
     Include all findings with details
     Add remediation guidance
     Provide next steps
   ```

### Integration with Other Skills

This operation orchestrates multiple skills:
- **schema-validation**: Structure and format checks
- **security-scan**: Security vulnerability detection
- **documentation-validation**: Documentation quality
- **best-practices**: Standards compliance
- **quality-analysis**: Scoring and recommendations

### Examples

**Comprehensive validation with report:**
```bash
/validation-orchestrator comprehensive path:. report:true
```

**Comprehensive validation, results only:**
```bash
/validation-orchestrator comprehensive path:/my-plugin report:false
```

### Performance Expectations

Comprehensive validation typically takes **5-10 seconds** depending on:
- Target size and complexity
- Number of files to scan
- Documentation completeness
- Script execution time

### Error Handling

- **Validation layer failure**: Continue with other layers, report partial results
- **Aggregation failure**: Return individual layer results
- **Report generation failure**: Return console output
- **Timeout**: Cancel and report completed layers only

### Output Format

```
Comprehensive Validation Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Target: <path>
Type: <marketplace|plugin>
Quality Score: <0-100>/100 <⭐⭐⭐⭐⭐>
Rating: <Excellent|Good|Fair|Needs Improvement|Poor>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Validation Layers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Schema Validation: <✅ PASS | ❌ FAIL>
  - Required fields: <status>
  - Format compliance: <status>
  - <additional details>

Security Scan: <✅ PASS | ❌ FAIL>
  - Secret detection: <status>
  - URL safety: <status>
  - <additional details>

Documentation: <✅ PASS | ⚠️  WARNINGS>
  - README: <status>
  - CHANGELOG: <status>
  - <additional details>

Best Practices: <✅ PASS | ⚠️  WARNINGS>
  - Naming: <status>
  - Versioning: <status>
  - <additional details>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Issues Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Critical Issues (must fix): <count>
❌ <issue 1>
❌ <issue 2>

Important Warnings (should fix): <count>
⚠️  <warning 1>
⚠️  <warning 2>

Recommendations (improve quality): <count>
💡 <recommendation 1>
💡 <recommendation 2>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. <prioritized action 1>
2. <prioritized action 2>
3. <prioritized action 3>

Publication Readiness: <Ready | Needs Work | Not Ready>
```

### Report File Location

If report generation is enabled, save to:
```
<target-path>/validation-report-<timestamp>.md
```

**Request**: $ARGUMENTS

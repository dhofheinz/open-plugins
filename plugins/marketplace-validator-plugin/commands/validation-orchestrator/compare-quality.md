## Operation: Compare Quality Across Multiple Targets

Compare validation quality metrics across multiple plugins or marketplaces for relative analysis.

### Parameters from $ARGUMENTS

- **paths**: Comma-separated list of target paths (required)
  - Format: `paths:"./plugin1,./plugin2,./plugin3"`
  - Minimum: 2 targets
  - Maximum: 10 targets (performance consideration)

- **metrics**: Specific metrics to compare (optional)
  - Format: `metrics:"score,security,documentation"`
  - Default: All metrics
  - Available: `score`, `security`, `documentation`, `schema`, `best-practices`

### Comparison Workflow

1. **Parse Target Paths**
   ```
   Split paths parameter by comma
   Validate each path exists
   Detect type for each target (marketplace or plugin)
   Filter invalid paths with warning
   ```

2. **Execute Validation for Each Target**
   ```
   FOR each target IN paths:
     Run comprehensive validation
     Capture quality score
     Capture issue counts (critical, warnings, recommendations)
     Capture layer results
     Store in comparison matrix
   ```

3. **Calculate Comparative Metrics**
   ```
   FOR each metric:
     Rank targets (best to worst)
     Calculate average score
     Identify outliers
     Note significant differences
   ```

4. **Generate Comparison Report**
   ```
   Create side-by-side comparison table
   Highlight best performers (green)
   Highlight needs improvement (red)
   Show relative rankings
   Provide improvement suggestions
   ```

### Comparison Dimensions

**Overall Quality Score**
- Numeric score (0-100)
- Star rating
- Ranking position

**Security Posture**
- Critical security issues count
- Security warnings count
- Security score

**Documentation Quality**
- README completeness
- CHANGELOG presence
- Documentation score

**Schema Compliance**
- Required fields status
- Format compliance
- Schema score

**Best Practices**
- Standards compliance
- Convention adherence
- Best practices score

### Examples

**Compare two plugins:**
```bash
/validation-orchestrator compare paths:"./plugin1,./plugin2"
```

**Compare with specific metrics:**
```bash
/validation-orchestrator compare paths:"./p1,./p2,./p3" metrics:"score,security"
```

**Compare marketplaces:**
```bash
/validation-orchestrator compare paths:"./marketplace-a,./marketplace-b"
```

### Performance Considerations

- Each target requires full validation (5-10 seconds each)
- Total time = (number of targets) × (validation time)
- Validations can run in parallel for performance
- Limit to 10 targets to prevent excessive runtime

### Error Handling

- **Invalid path**: Skip and warn, continue with valid paths
- **Minimum targets not met**: Require at least 2 valid targets
- **Validation failure**: Include in report with status "Failed to validate"
- **Timeout on target**: Mark as "Validation timeout" and continue

### Output Format

```
Quality Comparison Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Comparing <N> targets

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Rankings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🥇 1st: <target-name> - <score>/100 ⭐⭐⭐⭐⭐
🥈 2nd: <target-name> - <score>/100 ⭐⭐⭐⭐
🥉 3rd: <target-name> - <score>/100 ⭐⭐⭐

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detailed Comparison
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Metric          | Target 1 | Target 2 | Target 3 | Best   |
|-----------------|----------|----------|----------|--------|
| Quality Score   | 92/100   | 78/100   | 65/100   | Target 1 |
| Security        | ✅ Pass   | ⚠️ Warnings | ❌ Fail | Target 1 |
| Documentation   | ✅ Complete | ⚠️ Partial | ⚠️ Partial | Target 1 |
| Schema          | ✅ Valid  | ✅ Valid  | ❌ Invalid | Target 1 |
| Best Practices  | ✅ Compliant | ⚠️ Minor | ⚠️ Multiple | Target 1 |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Key Insights
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Top Performer: Target 1 (92/100)
- Strengths: Excellent security, complete docs
- Areas to maintain: All aspects well-executed

Needs Most Improvement: Target 3 (65/100)
- Critical Issues: Schema validation, security
- Priority Actions:
  1. Fix schema validation errors
  2. Address security vulnerabilities
  3. Complete documentation

Average Score: <calculated>/100
Score Range: <min> - <max>
Standard Deviation: <calculated>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For Target 2:
- Add CHANGELOG.md for better version tracking
- Expand README with more examples
- Review security warnings

For Target 3:
- Fix critical schema validation errors (blocking)
- Address all security issues (blocking)
- Complete missing documentation sections
```

### Use Cases

1. **Pre-submission Review**: Compare your plugin against reference plugins
2. **Quality Benchmarking**: Understand where you stand relative to others
3. **Marketplace Curation**: Compare plugins for marketplace inclusion
4. **Team Standards**: Ensure all team plugins meet minimum bar
5. **Continuous Improvement**: Track quality improvements over time

**Request**: $ARGUMENTS

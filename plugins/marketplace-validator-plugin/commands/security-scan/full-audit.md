## Operation: Full Security Audit

Execute comprehensive security audit combining all security scans: secrets, URLs, files, and permissions.

### Parameters from $ARGUMENTS

- **path**: Target directory to audit (required)
- **severity**: Minimum severity to report (critical|high|medium|low, default: medium)
- **strict**: Enable strict mode for all checks (true|false, default: false)
- **format**: Output format (text|json|markdown, default: text)

### Full Audit Workflow

1. **Initialize audit**
   ```
   Validate path exists
   Parse severity threshold
   Set strict mode for all sub-scans
   Initialize results aggregator
   ```

2. **Execute all security scans**
   ```
   PARALLEL EXECUTION (where possible):

   ┌─ Scan 1: Secret Detection
   │  Read scan-secrets.md
   │  Execute with path, recursive:true, severity
   │  Capture results
   │
   ├─ Scan 2: URL Safety Check
   │  Read check-urls.md
   │  Execute with path, https-only, check-code-patterns
   │  Capture results
   │
   ├─ Scan 3: Dangerous Files
   │  Read scan-files.md
   │  Execute with path, include-hidden, check-gitignore
   │  Capture results
   │
   └─ Scan 4: Permission Audit
      Read check-permissions.md
      Execute with path, strict, check-executables
      Capture results
   ```

3. **Aggregate results**
   ```
   Combine all findings
   Deduplicate issues
   Sort by severity:
     1. CRITICAL issues (block publication)
     2. HIGH issues (fix before publication)
     3. MEDIUM issues (recommended fixes)
     4. LOW issues (nice to have)

   Calculate overall security score:
     Base score: 100
     - CRITICAL: -25 points each
     - HIGH: -10 points each
     - MEDIUM: -5 points each
     - LOW: -2 points each
     Score = max(0, base - deductions)
   ```

4. **Generate comprehensive report**
   ```
   FULL SECURITY AUDIT REPORT
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Target: <path>
   Scan Date: <timestamp>
   Severity Threshold: <severity>

   OVERALL SECURITY SCORE: <0-100>/100
   Rating: <Excellent|Good|Fair|Poor|Critical>
   Publication Ready: <Yes|No|With Fixes>

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   EXECUTIVE SUMMARY
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Security Posture: <assessment>
   Critical Issues: <count> (IMMEDIATE ACTION REQUIRED)
   High Priority: <count> (FIX BEFORE PUBLICATION)
   Medium Priority: <count> (RECOMMENDED)
   Low Priority: <count> (OPTIONAL)

   Action Required: <Yes|No>
   Estimated Fix Time: <time_estimate>

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   SCAN RESULTS BY LAYER
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   [1] SECRET DETECTION
       Status: <PASS|FAIL>
       Secrets Found: <count>
       Files Scanned: <count>
       <Details...>

   [2] URL SAFETY
       Status: <PASS|FAIL>
       Unsafe URLs: <count>
       URLs Checked: <count>
       <Details...>

   [3] DANGEROUS FILES
       Status: <PASS|FAIL>
       Dangerous Files: <count>
       Files Scanned: <count>
       <Details...>

   [4] FILE PERMISSIONS
       Status: <PASS|FAIL>
       Permission Issues: <count>
       Files Checked: <count>
       <Details...>

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   CRITICAL ISSUES (IMMEDIATE ACTION)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   ❌ Issue 1: <description>
      File: <path>:<line>
      Severity: CRITICAL
      Risk: <risk_assessment>
      Remediation: <specific_steps>

   ❌ Issue 2: ...

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   HIGH PRIORITY ISSUES
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   ⚠️  Issue 1: ...

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   REMEDIATION PLAN
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Phase 1: Critical Issues (Immediate)
   □ Remove exposed secrets from .env
   □ Rotate compromised API keys
   □ Fix world-writable permissions (777)
   □ Remove dangerous files from repository

   Phase 2: High Priority (Before Publication)
   □ Update all HTTP URLs to HTTPS
   □ Add dangerous files to .gitignore
   □ Fix executables without shebangs
   □ Remove remote code execution patterns

   Phase 3: Recommended Improvements
   □ Restrict config file permissions to 600
   □ Review and expand shortened URLs
   □ Add security documentation

   Phase 4: Optional Enhancements
   □ Implement pre-commit hooks
   □ Add automated security scanning to CI/CD
   □ Document security best practices

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   SECURITY RECOMMENDATIONS
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   🔒 Secrets Management
      - Use environment variables for all secrets
      - Implement secret rotation policy
      - Consider using secret management tools
        (AWS Secrets Manager, HashiCorp Vault)

   🌐 URL Security
      - Enforce HTTPS for all external URLs
      - Verify checksums for downloaded scripts
      - Never pipe remote content to shell

   📁 File Security
      - Review .gitignore completeness
      - Remove sensitive files from git history
      - Implement file scanning in CI/CD

   🔐 Permission Security
      - Use least privilege principle
      - Document required permissions
      - Regular permission audits

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   PUBLICATION READINESS
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   <if score >= 90>
   ✅ READY FOR PUBLICATION
   Security score is excellent. No critical issues found.
   All security checks passed. Safe to publish.

   <if 70 <= score < 90>
   ⚠️  READY WITH MINOR FIXES
   Security score is good but has some issues.
   Fix high priority issues before publication.
   Estimated fix time: <time>

   <if score < 70>
   ❌ NOT READY FOR PUBLICATION
   Critical security issues must be resolved.
   Publication blocked until critical issues fixed.
   Do not publish in current state.

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   NEXT STEPS
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   1. Address all CRITICAL issues immediately
   2. Fix HIGH priority issues before publication
   3. Review and implement recommended improvements
   4. Re-run full security audit to verify fixes
   5. Document security practices for maintainers
   ```

### Security Score Calculation

```
Base Score: 100 points

Deductions:
- CRITICAL issues: -25 points each
- HIGH issues: -10 points each
- MEDIUM issues: -5 points each
- LOW issues: -2 points each

Final Score: max(0, Base - Deductions)

Rating Scale:
- 90-100: Excellent ⭐⭐⭐⭐⭐ (Publication ready)
- 70-89:  Good ⭐⭐⭐⭐ (Ready with minor fixes)
- 50-69:  Fair ⭐⭐⭐ (Needs work)
- 30-49:  Poor ⭐⭐ (Not ready)
- 0-29:   Critical ⭐ (Major security issues)
```

### Examples

```bash
# Full security audit with default settings
/security-scan full-security-audit path:.

# Strict mode - enforce all strict rules
/security-scan full-security-audit path:. strict:true

# Only report critical and high issues
/security-scan full-security-audit path:. severity:high

# JSON output for CI/CD integration
/security-scan full-security-audit path:. format:json

# Markdown report for documentation
/security-scan full-security-audit path:. format:markdown
```

### Error Handling

**Path not found**:
```
ERROR: Path does not exist: <path>
Remediation: Verify path and try again
```

**Scan failures**:
```
WARNING: One or more security scans failed
Partial results available:
- Secrets: ✓ Completed
- URLs: ✓ Completed
- Files: ✗ Failed
- Permissions: ✓ Completed

Recommendation: Review failures and re-run
```

**All scans passed**:
```
SUCCESS: Full Security Audit Passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Security Score: 100/100 ⭐⭐⭐⭐⭐
Rating: Excellent

All security checks passed with no issues.
Your plugin/marketplace is secure and ready for publication.

Summary:
✓ No secrets detected
✓ All URLs safe
✓ No dangerous files
✓ All permissions correct

Excellent security posture! 🎉
```

### Integration with CI/CD

**GitHub Actions Example**:
```yaml
name: Security Audit

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Security Audit
        run: |
          /security-scan full-security-audit path:. format:json > security-report.json

      - name: Check Security Score
        run: |
          score=$(jq '.security_score' security-report.json)
          if [ $score -lt 70 ]; then
            echo "Security score too low: $score"
            exit 1
          fi

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: security-report
          path: security-report.json
```

**GitLab CI Example**:
```yaml
security_audit:
  stage: test
  script:
    - /security-scan full-security-audit path:. format:json
  only:
    - main
    - merge_requests
  artifacts:
    reports:
      security: security-report.json
```

### Report Formats

**Text Format** (default):
- Human-readable console output
- Color-coded severity levels
- Section dividers for clarity
- Suitable for terminal viewing

**JSON Format**:
```json
{
  "scan_type": "full-audit",
  "timestamp": "<ISO8601>",
  "path": "<path>",
  "security_score": <0-100>,
  "rating": "<rating>",
  "publication_ready": <boolean>,
  "scans": {
    "secrets": { "status": "pass", "issues": [] },
    "urls": { "status": "fail", "issues": [...] },
    "files": { "status": "pass", "issues": [] },
    "permissions": { "status": "pass", "issues": [] }
  },
  "severity_breakdown": {
    "critical": <count>,
    "high": <count>,
    "medium": <count>,
    "low": <count>
  },
  "all_findings": [...],
  "remediation_plan": [...],
  "recommendations": [...]
}
```

**Markdown Format**:
- GitHub/GitLab compatible
- Can be added to PR comments
- Suitable for documentation
- Includes tables and checkboxes

### Time Estimates

**By Issue Count**:
- 0 issues: No time needed ✅
- 1-3 CRITICAL: 2-4 hours
- 4-10 HIGH: 1-2 hours
- 11-20 MEDIUM: 30-60 minutes
- 20+ LOW: 15-30 minutes

**By Issue Type**:
- Secret rotation: 30-60 minutes each
- URL updates: 5-10 minutes each
- File removal: 15-30 minutes (including .gitignore)
- Permission fixes: 5 minutes total (batch operation)

### Remediation Verification

After fixing issues, re-run audit:

```bash
# Fix issues
chmod 755 scripts/*.sh
git rm .env
echo ".env" >> .gitignore

# Verify fixes
/security-scan full-security-audit path:.

# Should see improved score
```

### Best Practices

**Regular Audits**:
- Run before each release
- Include in CI/CD pipeline
- Weekly scans for active development
- After adding dependencies

**Fix Priority**:
1. CRITICAL: Drop everything and fix
2. HIGH: Fix within 24 hours
3. MEDIUM: Fix within 1 week
4. LOW: Address when convenient

**Team Communication**:
- Share audit results with team
- Document security requirements
- Train on secure development
- Review security in code reviews

### Output Format

```json
{
  "scan_type": "full-audit",
  "timestamp": "<ISO8601>",
  "path": "<path>",
  "security_score": <0-100>,
  "rating": "<Excellent|Good|Fair|Poor|Critical>",
  "publication_ready": <boolean>,
  "estimated_fix_time": "<time_string>",
  "severity_breakdown": {
    "critical": <count>,
    "high": <count>,
    "medium": <count>,
    "low": <count>
  },
  "scan_results": {
    "secrets": { "status": "pass|fail", "findings": [...] },
    "urls": { "status": "pass|fail", "findings": [...] },
    "files": { "status": "pass|fail", "findings": [...] },
    "permissions": { "status": "pass|fail", "findings": [...] }
  },
  "all_findings": [...],
  "remediation_plan": [...],
  "recommendations": [...],
  "action_required": <boolean>
}
```

**Request**: $ARGUMENTS

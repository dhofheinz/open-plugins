## Operation: Scan for Exposed Secrets

Detect exposed secrets, API keys, tokens, passwords, and private keys using 50+ pattern signatures.

### Parameters from $ARGUMENTS

- **path**: Target directory or file to scan (required)
- **recursive**: Scan subdirectories (true|false, default: true)
- **patterns**: Specific pattern categories to check (optional, default: all)
- **exclude**: Patterns to exclude from scan (optional)
- **severity**: Minimum severity to report (critical|high|medium|low, default: medium)

### Secret Detection Patterns (50+)

**API Keys & Tokens**:
- Stripe: sk_live_, sk_test_, pk_live_, pk_test_
- OpenAI: sk-[a-zA-Z0-9]{32,}
- AWS: AKIA[0-9A-Z]{16}
- Google: AIza[0-9A-Za-z_-]{35}
- GitHub: ghp_, gho_, ghs_, ghu_
- Slack: xox[baprs]-[0-9a-zA-Z]{10,}
- Twitter: [0-9a-zA-Z]{35,44}
- Facebook: EAA[0-9A-Za-z]{90,}

**Private Keys**:
- RSA: BEGIN RSA PRIVATE KEY
- Generic: BEGIN PRIVATE KEY
- SSH: BEGIN OPENSSH PRIVATE KEY
- PGP: BEGIN PGP PRIVATE KEY
- DSA: BEGIN DSA PRIVATE KEY
- EC: BEGIN EC PRIVATE KEY

**Credentials**:
- Passwords: password\s*[=:]\s*['\"][^'\"]+['\"]
- API keys: api[_-]?key\s*[=:]\s*['\"][^'\"]+['\"]
- Secrets: secret\s*[=:]\s*['\"][^'\"]+['\"]
- Tokens: token\s*[=:]\s*['\"][^'\"]+['\"]
- Auth: authorization\s*[=:]\s*['\"]Bearer [^'\"]+['\"]

**Cloud Provider Credentials**:
- AWS Access Key: aws_access_key_id
- AWS Secret: aws_secret_access_key
- Azure: [0-9a-zA-Z/+]{88}==
- GCP Service Account: type.*service_account

### Workflow

1. **Parse arguments**
   ```
   Extract path, recursive, patterns, exclude, severity
   Validate path exists
   Determine scan scope (file vs directory)
   ```

2. **Execute secret scanner**
   ```bash
   Execute .scripts/secret-scanner.sh "$path" "$recursive" "$patterns" "$exclude" "$severity"

   Returns:
   - 0: No secrets found
   - 1: Secrets detected
   - 2: Scan error
   ```

3. **Process results**
   ```
   Parse scanner output
   Categorize by severity:
     - CRITICAL: Private keys, production API keys
     - HIGH: API keys, tokens with broad scope
     - MEDIUM: Passwords, secrets in config
     - LOW: Test keys, development credentials

   Generate remediation guidance per finding
   ```

4. **Format output**
   ```
   Secrets Scan Results
   ━━━━━━━━━━━━━━━━━━━━
   Path: <path>
   Files Scanned: <count>

   CRITICAL Issues (<count>):
   ❌ <file>:<line>: <type> detected
      Pattern: <pattern_name>
      Remediation: Remove and rotate immediately

   HIGH Issues (<count>):
   ⚠️  <file>:<line>: <type> detected

   Summary:
   - Total secrets: <count>
   - Unique patterns: <count>
   - Action required: <yes|no>
   ```

### Examples

```bash
# Scan current directory recursively
/security-scan secrets path:.

# Scan specific file only
/security-scan secrets path:./config/settings.json recursive:false

# Check only API key patterns
/security-scan secrets path:. patterns:"api-keys,tokens"

# Exclude test directories
/security-scan secrets path:. exclude:"test,mock,fixtures"

# Only critical severity
/security-scan secrets path:. severity:critical
```

### Error Handling

**Path not found**:
```
ERROR: Path does not exist: <path>
Remediation: Verify path and try again
```

**No patterns matched**:
```
INFO: No secrets detected
All files clean
```

**Scanner unavailable**:
```
ERROR: Secret scanner script not found
Remediation: Verify plugin installation
```

### Severity Levels

**CRITICAL** (Immediate action required):
- Private keys (RSA, SSH, PGP)
- Production API keys (live_, prod_)
- AWS credentials
- Database connection strings with passwords

**HIGH** (Action required):
- API keys (generic)
- OAuth tokens
- Bearer tokens
- Authentication credentials

**MEDIUM** (Should address):
- Passwords in config files
- Secret variables
- Session tokens
- Development credentials in non-test contexts

**LOW** (Review recommended):
- Test API keys
- Mock credentials
- Example configurations

### Remediation Guidance

**For exposed secrets**:
1. Remove from code immediately
2. Rotate/regenerate the credential
3. Use environment variables instead
4. Add to .gitignore if file-based
5. Review git history for exposure
6. Consider using secret management (AWS Secrets Manager, HashiCorp Vault)

**Prevention**:
- Use .env files (never commit)
- Use environment variables
- Implement pre-commit hooks
- Use secret scanning in CI/CD
- Educate team on security practices

### Output Format

```json
{
  "scan_type": "secrets",
  "path": "<path>",
  "files_scanned": <count>,
  "secrets_found": <count>,
  "severity_breakdown": {
    "critical": <count>,
    "high": <count>,
    "medium": <count>,
    "low": <count>
  },
  "findings": [
    {
      "file": "<file_path>",
      "line": <line_number>,
      "type": "<secret_type>",
      "severity": "<severity>",
      "pattern": "<pattern_name>",
      "remediation": "<action>"
    }
  ],
  "action_required": <boolean>
}
```

**Request**: $ARGUMENTS

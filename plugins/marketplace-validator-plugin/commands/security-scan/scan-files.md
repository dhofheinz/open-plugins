## Operation: Scan for Dangerous Files

Detect dangerous files, sensitive configurations, and files that should not be committed to version control.

### Parameters from $ARGUMENTS

- **path**: Target directory to scan (required)
- **patterns**: Specific file patterns to check (optional, default: all)
- **include-hidden**: Scan hidden files and directories (true|false, default: true)
- **check-gitignore**: Verify .gitignore coverage (true|false, default: true)

### Dangerous File Categories

**Environment Files** (CRITICAL):
- .env, .env.local, .env.production, .env.development
- .env.*.local (any environment-specific)
- env.sh, setenv.sh
→ Often contain secrets, should never be committed

**Credential Files** (CRITICAL):
- credentials.json, credentials.yaml, credentials.yml
- secrets.json, secrets.yaml, config/secrets/*
- .aws/credentials, .azure/credentials
- .gcp/credentials.json, gcloud/credentials
→ Direct access credentials, rotate if exposed

**Private Keys** (CRITICAL):
- id_rsa, id_dsa, id_ed25519 (SSH keys)
- *.pem, *.key, *.p12, *.pfx (SSL/TLS certificates)
- *.jks, *.keystore (Java keystores)
- .gnupg/*, .ssh/id_* (GPG and SSH directories)
→ Authentication keys, regenerate if exposed

**Database Files** (HIGH):
- *.db, *.sqlite, *.sqlite3
- *.sql with INSERT statements (data dumps)
- dump.sql, backup.sql
- *.mdb, *.accdb (Access databases)
→ May contain sensitive data

**Configuration Files** (MEDIUM):
- config/database.yml with passwords
- appsettings.json with connection strings
- wp-config.php with DB credentials
- settings.py with SECRET_KEY
→ Review for hardcoded secrets

**Backup Files** (MEDIUM):
- *.bak, *.backup, *.old
- *~, *.swp, *.swo (editor backups)
- *.orig, *.copy
→ May contain previous versions with secrets

**Log Files** (LOW):
- *.log with potential sensitive data
- debug.log, error.log
- Combined log files (>10MB)
→ Review for leaked information

### Workflow

1. **Parse arguments**
   ```
   Extract path, patterns, include-hidden, check-gitignore
   Validate path exists and is directory
   Load dangerous file patterns
   ```

2. **Execute file scanner**
   ```bash
   Execute .scripts/file-scanner.sh "$path" "$patterns" "$include_hidden" "$check_gitignore"

   Returns:
   - 0: No dangerous files found
   - 1: Dangerous files detected
   - 2: Scan error
   ```

3. **Process results**
   ```
   Categorize by risk:
     - CRITICAL: Private keys, credentials, production env files
     - HIGH: Database files, config with secrets
     - MEDIUM: Backup files, test credentials
     - LOW: Log files, temporary files

   Cross-reference with .gitignore:
     - Files that SHOULD be in .gitignore but aren't
     - Already ignored files (informational)
   ```

4. **Format output**
   ```
   Dangerous Files Scan Results
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Path: <path>
   Files Scanned: <count>

   CRITICAL Files (<count>):
   ❌ .env (157 bytes)
      Type: Environment file
      Risk: Contains API keys and secrets
      Status: NOT in .gitignore ⚠️
      Remediation: Add to .gitignore, remove from git history

   ❌ config/credentials.json (2.3 KB)
      Type: Credential file
      Risk: Contains authentication credentials
      Status: NOT in .gitignore ⚠️
      Remediation: Remove, rotate credentials, use env vars

   HIGH Files (<count>):
   ⚠️  database/dev.db (45 MB)
      Type: SQLite database
      Risk: May contain user data
      Status: In .gitignore ✓
      Remediation: Verify .gitignore working

   Summary:
   - Total dangerous files: <count>
   - Not in .gitignore: <count>
   - Action required: <yes|no>
   ```

### File Pattern Signatures

**Environment files**:
```
.env
.env.*
env.sh
setenv.sh
.envrc
```

**Credential files**:
```
*credentials*
*secrets*
*password*
.aws/credentials
.azure/credentials
.gcp/*credentials*
```

**Private keys**:
```
id_rsa
id_dsa
id_ed25519
*.pem
*.key
*.p12
*.pfx
*.jks
*.keystore
.gnupg/*
```

**Database files**:
```
*.db
*.sqlite
*.sqlite3
*.sql (with INSERT/UPDATE)
dump.sql
*backup*.sql
```

**Backup patterns**:
```
*.bak
*.backup
*.old
*.orig
*.copy
*~
*.swp
*.swo
```

### .gitignore Validation

**Should be ignored**:
```gitignore
# Environment
.env*
!.env.example

# Credentials
credentials.*
secrets.*
*.pem
*.key
id_rsa*

# Databases
*.db
*.sqlite*
dump.sql

# Backups
*.bak
*.backup
*~
```

**Safe to commit** (examples):
```
.env.example
.env.template
credentials.example.json
README.md
package.json
```

### Examples

```bash
# Scan current directory
/security-scan files path:.

# Check specific patterns only
/security-scan files path:. patterns:".env,credentials,*.pem"

# Include hidden files explicitly
/security-scan files path:. include-hidden:true

# Scan and verify .gitignore coverage
/security-scan files path:. check-gitignore:true
```

### Error Handling

**Path not found**:
```
ERROR: Path does not exist: <path>
Remediation: Verify path is correct
```

**Path is not directory**:
```
ERROR: Path is not a directory: <path>
Remediation: Provide directory path for file scanning
```

**No .gitignore found**:
```
WARNING: No .gitignore file found
Recommendation: Create .gitignore to prevent committing sensitive files
```

### Remediation Guidance

**For environment files (.env)**:
1. Add to .gitignore immediately
2. Remove from git history if committed:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. Create .env.example with dummy values
4. Document environment variables in README

**For credential files**:
1. Remove from repository
2. Rotate all exposed credentials
3. Use environment variables or secret managers
4. Add to .gitignore
5. Consider using git-secrets or similar tools

**For private keys**:
1. Regenerate keys immediately
2. Remove from repository
3. Update deployed systems with new keys
4. Add *.pem, *.key, id_rsa to .gitignore
5. Audit access logs for unauthorized use

**For database files**:
1. Remove from repository if contains real data
2. For test data, ensure no real emails/names
3. Add *.db, *.sqlite to .gitignore
4. Use schema-only dumps in version control

**For backup files**:
1. Clean up backup files before commit
2. Add backup patterns to .gitignore
3. Use .gitignore_global for editor backups
4. Configure editors to save backups elsewhere

### Git History Cleanup

If sensitive files were already committed:

```bash
# Using git filter-repo (recommended)
git filter-repo --path .env --invert-paths

# Using BFG Repo-Cleaner (fast for large repos)
bfg --delete-files .env
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (WARNING: destructive)
git push origin --force --all
```

### Prevention Strategies

**Pre-commit hooks**:
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Check for dangerous files
if git diff --cached --name-only | grep -E '\\.env$|credentials|id_rsa'; then
  echo "ERROR: Attempting to commit sensitive file"
  exit 1
fi
```

**Use git-secrets**:
```bash
git secrets --install
git secrets --register-aws
git secrets --add 'credentials\.json'
```

**IDE Configuration**:
- Configure .gitignore templates
- Use .editorconfig
- Set up file watchers for dangerous patterns

### Output Format

```json
{
  "scan_type": "files",
  "path": "<path>",
  "files_scanned": <count>,
  "dangerous_files": <count>,
  "not_in_gitignore": <count>,
  "severity_breakdown": {
    "critical": <count>,
    "high": <count>,
    "medium": <count>,
    "low": <count>
  },
  "findings": [
    {
      "file": "<file_path>",
      "type": "<file_type>",
      "size": <size_bytes>,
      "severity": "<severity>",
      "risk": "<risk_description>",
      "in_gitignore": <boolean>,
      "remediation": "<action>"
    }
  ],
  "action_required": <boolean>
}
```

**Request**: $ARGUMENTS

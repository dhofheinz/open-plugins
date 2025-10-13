## Operation: Check File Permissions

Audit file permissions to detect world-writable files, overly permissive scripts, and inappropriate executability.

### Parameters from $ARGUMENTS

- **path**: Target directory to scan (required)
- **strict**: Enforce strict permission rules (true|false, default: false)
- **check-executables**: Verify executable files have shebangs (true|false, default: true)
- **report-all**: Report all permissions, not just issues (true|false, default: false)

### Permission Rules

**Forbidden Permissions** (CRITICAL):
- **777** (rwxrwxrwx) - World-writable and executable
  - Risk: Anyone can modify and execute
  - Remediation: chmod 755 (directories) or 644 (files)

- **666** (rw-rw-rw-) - World-writable files
  - Risk: Anyone can modify content
  - Remediation: chmod 644 (owner write, others read)

- **000** (---------)  - Inaccessible files
  - Risk: Unusable file, potential error
  - Remediation: chmod 644 or remove

**Scripts & Executables** (HIGH priority):
- Shell scripts (*.sh, *.bash) SHOULD be:
  - 755 (rwxr-xr-x) or 750 (rwxr-x---)
  - Have shebang (#!/bin/bash, #!/usr/bin/env bash)
  - Not world-writable

- Python scripts (*.py) SHOULD be:
  - 755 if executable, 644 if library
  - Have shebang if executable (#!/usr/bin/env python3)

- Node.js scripts (*.js, *.ts) SHOULD be:
  - 644 (not executable, run via node)
  - Exception: CLI tools can be 755 with shebang

**Configuration Files** (MEDIUM priority):
- Config files (.env, *.json, *.yaml, *.conf) SHOULD be:
  - 600 (rw-------) for sensitive configs
  - 644 (rw-r--r--) for non-sensitive
  - Never 666 or 777

- SSH/GPG files MUST be:
  - Private keys: 600 (rw-------)
  - Public keys: 644 (rw-r--r--)
  - ~/.ssh directory: 700 (rwx------)

**Directories** (MEDIUM priority):
- Standard directories: 755 (rwxr-xr-x)
- Private directories: 750 or 700
- Never 777 (world-writable)

### Workflow

1. **Parse arguments**
   ```
   Extract path, strict, check-executables, report-all
   Validate path exists
   Determine scan scope
   ```

2. **Execute permission checker**
   ```bash
   Execute .scripts/permission-checker.sh "$path" "$strict" "$check_executables" "$report_all"

   Returns:
   - 0: All permissions correct
   - 1: Permission issues found
   - 2: Scan error
   ```

3. **Analyze results**
   ```
   Categorize findings:
     - CRITICAL: 777, 666, world-writable
     - HIGH: Executables without shebangs, 775 on sensitive files
     - MEDIUM: Overly permissive configs, wrong directory perms
     - LOW: Inconsistent permissions, non-executable scripts

   Generate fix commands
   ```

4. **Format output**
   ```
   File Permission Audit Results
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Path: <path>
   Files Checked: <count>

   CRITICAL Issues (<count>):
   ❌ scripts/deploy.sh (777)
      Current: rwxrwxrwx (777)
      Issue: World-writable and executable
      Risk: Anyone can modify and execute script
      Fix: chmod 755 scripts/deploy.sh

   ❌ config/secrets.json (666)
      Current: rw-rw-rw- (666)
      Issue: World-writable configuration
      Risk: Secrets can be modified by anyone
      Fix: chmod 600 config/secrets.json

   HIGH Issues (<count>):
   ⚠️  bin/cli.sh (755) - Missing shebang
      Issue: Executable without shebang
      Fix: Add #!/usr/bin/env bash to first line

   MEDIUM Issues (<count>):
   💡 .env (644)
      Current: rw-r--r-- (644)
      Recommendation: Restrict to owner only
      Fix: chmod 600 .env

   Summary:
   - Total issues: <count>
   - Critical: <count> (fix immediately)
   - Fixes available: Yes
   ```

### Permission Patterns

**Standard File Permissions**:
```
644 (rw-r--r--)  - Regular files, documentation
755 (rwxr-xr-x)  - Executable scripts, directories
600 (rw-------)  - Sensitive configs, private keys
700 (rwx------)  - Private directories (.ssh, .gnupg)
```

**Forbidden Permissions**:
```
777 (rwxrwxrwx)  - Never use (world-writable + executable)
666 (rw-rw-rw-)  - Never use (world-writable)
000 (---------)  - Inaccessible (likely error)
```

**Context-Specific**:
```
Shell scripts:   755 with #!/bin/bash
Python scripts:  755 with #!/usr/bin/env python3 (if CLI)
                644 without shebang (if library)
Config files:    600 (sensitive) or 644 (public)
SSH keys:        600 (private), 644 (public)
Directories:     755 (public), 700 (private)
```

### Shebang Validation

**Valid shebangs**:
```bash
#!/bin/bash
#!/usr/bin/env bash
#!/usr/bin/env python3
#!/usr/bin/env node
#!/usr/bin/env ruby
```

**Invalid patterns**:
```bash
#!/bin/sh  # Too generic, prefer bash
#! /bin/bash  # Space after #!
# /usr/bin/env bash  # Missing !
```

### Examples

```bash
# Check all permissions in current directory
/security-scan permissions path:.

# Strict mode - flag all non-standard permissions
/security-scan permissions path:. strict:true

# Check executables for shebangs
/security-scan permissions path:./scripts/ check-executables:true

# Report all files, not just issues
/security-scan permissions path:. report-all:true
```

### Error Handling

**Path not found**:
```
ERROR: Path does not exist: <path>
Remediation: Verify path and try again
```

**Permission denied**:
```
ERROR: Cannot read permissions for: <path>
Remediation: Run with sufficient privileges or check ownership
```

**No issues found**:
```
SUCCESS: All file permissions correct
No action required
```

### Automated Fixes

**Critical Issues**:
```bash
# Fix world-writable files
find . -type f -perm 0666 -exec chmod 644 {} \;
find . -type f -perm 0777 -exec chmod 755 {} \;

# Fix world-writable directories
find . -type d -perm 0777 -exec chmod 755 {} \;
```

**Sensitive Files**:
```bash
# Restrict sensitive configs
chmod 600 .env
chmod 600 config/credentials.json
chmod 600 ~/.ssh/id_rsa

# Secure directories
chmod 700 ~/.ssh
chmod 700 ~/.gnupg
```

**Executables**:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Remove execute from libraries
chmod 644 src/**/*.py
```

### Platform-Specific Notes

**Unix/Linux**:
- Full permission support (owner/group/other)
- Numeric (755) or symbolic (rwxr-xr-x) modes
- Respect umask settings

**macOS**:
- Same as Unix/Linux
- Additional extended attributes (xattr)
- May have quarantine attributes on downloaded files

**Windows (WSL/Git Bash)**:
- Limited permission support
- Executable bit preserved in git
- May show 755 for all files by default

### Strict Mode Rules

When `strict:true`:

**Additional checks**:
- Flag 775 on any file (group-writable)
- Flag 755 on non-executable files
- Require 600 for all .env files
- Require 700 for all .ssh, .gnupg directories
- Flag inconsistent permissions in same directory

**Stricter recommendations**:
- Config files: Must be 600
- Scripts: Must have correct shebang
- No group-writable files
- Directories: 750 instead of 755

### Remediation Guidance

**For world-writable files (777, 666)**:
1. Determine correct permission level
2. Apply fix immediately: `chmod 644 <file>` or `chmod 755 <executable>`
3. Verify no unauthorized modifications
4. Check git history for permission changes
5. Document required permissions in README

**For executables without shebangs**:
1. Add appropriate shebang:
   ```bash
   #!/usr/bin/env bash
   ```
2. Verify script runs correctly
3. Consider using absolute path if specific version needed

**For overly permissive configs**:
1. Restrict to owner: `chmod 600 <config>`
2. Verify application can still read
3. Update deployment documentation
4. Use principle of least privilege

**For inconsistent permissions**:
1. Establish permission standards
2. Document in CONTRIBUTING.md
3. Add pre-commit hook to enforce
4. Use tools like .editorconfig

### Security Best Practices

**General**:
- Use most restrictive permissions possible
- Never use 777 or 666
- Sensitive files: 600 (owner read/write only)
- Executables: 755 (everyone execute, owner write)
- Configs: 644 (everyone read, owner write) or 600 (owner only)

**For Scripts**:
- Always include shebang
- Make executable only if meant to be run directly
- Libraries should be 644, not 755
- Verify no secrets in scripts

**For Keys**:
- Private keys: 600 or SSH refuses to use them
- Public keys: 644
- Key directories: 700
- Never group or world readable

### Output Format

```json
{
  "scan_type": "permissions",
  "path": "<path>",
  "files_checked": <count>,
  "issues_found": <count>,
  "severity_breakdown": {
    "critical": <count>,
    "high": <count>,
    "medium": <count>,
    "low": <count>
  },
  "findings": [
    {
      "file": "<file_path>",
      "current_permissions": "<octal>",
      "current_symbolic": "<symbolic>",
      "issue": "<issue_description>",
      "severity": "<severity>",
      "risk": "<risk_description>",
      "recommended_permissions": "<octal>",
      "fix_command": "chmod <perms> <file>"
    }
  ],
  "fixes_available": <boolean>,
  "action_required": <boolean>
}
```

**Request**: $ARGUMENTS

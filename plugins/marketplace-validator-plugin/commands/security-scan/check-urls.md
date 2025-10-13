## Operation: Check URL Safety

Validate URL safety, enforce HTTPS, and detect malicious patterns in URLs and code.

### Parameters from $ARGUMENTS

- **path**: Target directory or file to scan (required)
- **https-only**: Enforce HTTPS for all URLs (true|false, default: false)
- **allow-localhost**: Allow http://localhost URLs (true|false, default: true)
- **check-code-patterns**: Check for dangerous code execution patterns (true|false, default: true)

### URL Safety Checks

**Protocol Validation**:
- HTTPS enforcement (production contexts)
- HTTP allowed only for localhost/127.0.0.1
- FTP/telnet flagged as insecure
- file:// protocol flagged (potential security risk)

**Malicious Patterns**:
- `curl ... | sh` - Remote code execution
- `wget ... | bash` - Remote script execution
- `eval(fetch(...))` - Dynamic code execution
- `exec(...)` with URLs - Command injection risk
- `rm -rf` in scripts downloaded from URLs
- Obfuscated URLs (base64, hex encoded)

**Domain Validation**:
- Check for typosquatting (common package registries)
- Suspicious TLDs (.tk, .ml, .ga, .cf)
- IP addresses instead of domains
- Shortened URLs (bit.ly, tinyurl) - potential phishing

### Workflow

1. **Parse arguments**
   ```
   Extract path, https-only, allow-localhost, check-code-patterns
   Validate path exists
   Determine scan scope
   ```

2. **Execute URL validator**
   ```bash
   Execute .scripts/url-validator.py "$path" "$https_only" "$allow_localhost" "$check_code_patterns"

   Returns:
   - 0: All URLs safe
   - 1: Unsafe URLs detected
   - 2: Validation error
   ```

3. **Analyze results**
   ```
   Categorize findings:
     - CRITICAL: Remote code execution patterns
     - HIGH: Non-HTTPS in production, obfuscated URLs
     - MEDIUM: HTTP in non-localhost, suspicious TLDs
     - LOW: Shortened URLs, IP addresses

   Generate context-aware remediation
   ```

4. **Format output**
   ```
   URL Safety Scan Results
   ━━━━━━━━━━━━━━━━━━━━━━
   Path: <path>
   URLs Scanned: <count>

   CRITICAL Issues (<count>):
   ❌ <file>:<line>: Remote code execution pattern
      Pattern: curl https://example.com/script.sh | bash
      Risk: Executes arbitrary code without verification
      Remediation: Download, verify, then execute

   HIGH Issues (<count>):
   ⚠️  <file>:<line>: Non-HTTPS URL in production context
      URL: http://api.example.com
      Risk: Man-in-the-middle attacks
      Remediation: Use HTTPS

   Summary:
   - Total URLs: <count>
   - Safe: <count>
   - Unsafe: <count>
   - Action required: <yes|no>
   ```

### Dangerous Code Patterns

**Remote Execution** (CRITICAL):
```bash
# Dangerous patterns
curl https://example.com/install.sh | bash
wget -qO- https://get.example.com | sh
eval "$(curl -fsSL https://example.com/script)"
bash <(curl -s https://example.com/setup.sh)
```

**Dynamic Code Execution** (HIGH):
```javascript
// Dangerous patterns
eval(fetch(url).then(r => r.text()))
new Function(await fetch(url).text())()
exec(`curl ${url}`)
```

**Command Injection** (HIGH):
```bash
# Vulnerable patterns
wget $USER_INPUT
curl "$UNTRUSTED_URL"
git clone $URL  # without validation
```

### Safe Alternatives

**Instead of curl | sh**:
```bash
# Safe: Download, verify, then execute
wget https://example.com/install.sh
sha256sum -c install.sh.sha256
chmod +x install.sh
./install.sh
```

**Instead of eval(fetch())**:
```javascript
// Safe: Fetch as data, validate, then use
const response = await fetch(url);
const data = await response.json();
// Process data, not as code
```

### Examples

```bash
# Check all URLs, enforce HTTPS
/security-scan urls path:. https-only:true

# Allow localhost HTTP during development
/security-scan urls path:. https-only:true allow-localhost:true

# Check for code execution patterns
/security-scan urls path:./scripts/ check-code-patterns:true

# Scan specific file
/security-scan urls path:./install.sh
```

### Error Handling

**Path not found**:
```
ERROR: Path does not exist: <path>
Remediation: Verify path and try again
```

**No URLs found**:
```
INFO: No URLs detected
No action required
```

**Python unavailable**:
```
ERROR: Python3 not available
Remediation: Install Python 3.x or skip URL validation
```

### Context-Aware Rules

**Production contexts** (strict):
- package.json scripts
- Dockerfiles
- CI/CD configs (.github/, .gitlab-ci.yml)
- Installation scripts (install.sh, setup.sh)
→ Enforce HTTPS, no remote execution

**Development contexts** (relaxed):
- Test files (*test*, *spec*)
- Mock data
- Local development configs
→ Allow HTTP for localhost

**Documentation contexts** (informational):
- README.md
- *.md files
- Comments
→ Flag but don't fail

### URL Categories

**Registry URLs** (validate carefully):
- npm: https://registry.npmjs.org
- PyPI: https://pypi.org
- Docker: https://registry.hub.docker.com
- GitHub: https://github.com
→ Verify exact domain, check for typosquatting

**CDN URLs** (HTTPS required):
- https://cdn.jsdelivr.net
- https://unpkg.com
- https://cdnjs.cloudflare.com
→ Must use HTTPS, verify integrity hashes

**Shortened URLs** (flag for review):
- bit.ly, tinyurl.com, goo.gl
→ Cannot verify destination, recommend expanding

### Remediation Guidance

**For remote code execution**:
1. Remove pipe-to-shell patterns
2. Download scripts explicitly
3. Verify checksums/signatures
4. Review code before execution
5. Use official package managers when possible

**For non-HTTPS URLs**:
1. Update to HTTPS version
2. Verify certificate validity
3. Pin certificate if highly sensitive
4. Consider using subresource integrity (SRI) for CDNs

**For suspicious URLs**:
1. Verify domain legitimacy
2. Check for typosquatting
3. Expand shortened URLs
4. Review destination manually

### Output Format

```json
{
  "scan_type": "urls",
  "path": "<path>",
  "urls_scanned": <count>,
  "unsafe_urls": <count>,
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
      "url": "<url>",
      "issue": "<issue_type>",
      "severity": "<severity>",
      "risk": "<risk_description>",
      "remediation": "<action>"
    }
  ],
  "action_required": <boolean>
}
```

**Request**: $ARGUMENTS

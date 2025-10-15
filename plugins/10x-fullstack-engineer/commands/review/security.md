# Security-Focused Code Review

Performs a comprehensive security audit focusing on authentication, authorization, input validation, data protection, and OWASP Top 10 vulnerabilities.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'security' operation)

Expected format: `scope:"review-scope" [depth:"quick|standard|deep"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: What to review (required) - payment module, auth system, API endpoints, etc.
- **depth**: Security audit thoroughness (default: "deep" for security reviews)

### 2. Gather Context

**Understand the Security Surface**:
```bash
# Identify entry points
find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" | xargs grep -l "router\|app\.\(get\|post\|put\|delete\)\|@app\.route\|http\.HandleFunc" | head -20

# Check for authentication middleware
grep -r "auth\|jwt\|session" --include="*.ts" --include="*.js" --include="*.py" | head -20

# Find environment variable usage
grep -r "process\.env\|os\.getenv\|os\.environ" --include="*.ts" --include="*.js" --include="*.py" | head -15

# Check dependencies for known vulnerabilities
npm audit || pip-audit || go list -m all | nancy sleuth || echo "Check package security"

# Look for database queries
grep -r "query\|execute\|SELECT\|INSERT\|UPDATE\|DELETE" --include="*.ts" --include="*.js" --include="*.py" | head -20
```

### 3. Authentication & Authorization Security

**Authentication Checks**:
- [ ] All protected endpoints have authentication middleware
- [ ] Authentication tokens are validated properly
- [ ] Token expiration is enforced
- [ ] Refresh tokens implemented securely
- [ ] Multi-factor authentication available for sensitive operations
- [ ] Account lockout after failed login attempts
- [ ] Password complexity requirements enforced
- [ ] Rate limiting on authentication endpoints

**Authorization Checks**:
- [ ] Role-based access control (RBAC) implemented
- [ ] Permission checks on every protected resource
- [ ] Users can only access their own data (unless admin)
- [ ] Horizontal privilege escalation prevented
- [ ] Vertical privilege escalation prevented
- [ ] Authorization checks on backend (never trust client)

**Session Management**:
- [ ] Secure session configuration (HttpOnly, Secure, SameSite flags)
- [ ] Session timeout configured appropriately
- [ ] Session invalidation on logout
- [ ] No session fixation vulnerabilities
- [ ] Session tokens are cryptographically random

**Code Examples - Authentication**:

```typescript
// ❌ CRITICAL: No authentication check
app.get('/api/user/:id/profile', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});

// ✅ GOOD: Authentication required
app.get('/api/user/:id/profile', requireAuth, async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});

// ✅ BETTER: Authentication + authorization
app.get('/api/user/:id/profile', requireAuth, async (req, res) => {
  // User can only access their own profile (unless admin)
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const user = await User.findById(req.params.id);
  res.json(user);
});
```

```typescript
// ❌ CRITICAL: Weak JWT verification
const decoded = jwt.decode(token); // No verification!
req.user = decoded;

// ✅ GOOD: Proper JWT verification with secret
const decoded = jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256'],
  maxAge: '1h'
});
req.user = decoded;
```

### 4. Input Validation & Injection Prevention

**Input Validation**:
- [ ] All user inputs validated on backend
- [ ] Whitelist validation used (not blacklist)
- [ ] Input length limits enforced
- [ ] Data types validated
- [ ] File uploads validated (type, size, content)
- [ ] Email addresses validated properly
- [ ] URLs validated and sanitized

**SQL Injection Prevention**:
- [ ] Parameterized queries used (never string concatenation)
- [ ] ORM used correctly (no raw queries with user input)
- [ ] Stored procedures with parameterization
- [ ] Input sanitization for database queries
- [ ] Principle of least privilege for database users

**XSS Prevention**:
- [ ] Output encoding for all user-generated content
- [ ] Content Security Policy (CSP) headers configured
- [ ] HTML sanitization for rich text input
- [ ] No innerHTML with user data (use textContent)
- [ ] Template engines auto-escape by default
- [ ] React JSX auto-escapes (but check dangerouslySetInnerHTML)

**Command Injection Prevention**:
- [ ] No shell command execution with user input
- [ ] If shell commands necessary, use safe APIs
- [ ] Input validation for any system calls
- [ ] Whitelist allowed commands

**Path Traversal Prevention**:
- [ ] No file system access with user-controlled paths
- [ ] Path validation and sanitization
- [ ] Use safe path joining methods
- [ ] Restrict file access to specific directories

**Code Examples - Injection Prevention**:

```typescript
// ❌ CRITICAL: SQL Injection vulnerability
const email = req.body.email;
const query = `SELECT * FROM users WHERE email = '${email}'`;
const users = await db.query(query);

// ✅ GOOD: Parameterized query
const email = req.body.email;
const query = 'SELECT * FROM users WHERE email = ?';
const users = await db.query(query, [email]);

// ✅ BETTER: Using ORM with validation
const email = validateEmail(req.body.email); // Throws if invalid
const users = await User.findAll({ where: { email } });
```

```typescript
// ❌ CRITICAL: XSS vulnerability
const username = req.query.name;
res.send(`<h1>Welcome ${username}</h1>`);

// ✅ GOOD: Proper escaping
const username = escapeHtml(req.query.name);
res.send(`<h1>Welcome ${username}</h1>`);

// ✅ BETTER: Use template engine with auto-escaping
res.render('welcome', { username: req.query.name }); // Template auto-escapes
```

```typescript
// ❌ CRITICAL: Command injection
const filename = req.body.filename;
exec(`cat ${filename}`, (err, stdout) => {
  res.send(stdout);
});

// ✅ GOOD: Use safe file reading
const filename = path.basename(req.body.filename); // Remove path traversal
const safePath = path.join('/safe/directory', filename);
const content = await fs.readFile(safePath, 'utf8');
res.send(content);
```

```typescript
// ❌ CRITICAL: Path traversal vulnerability
const file = req.query.file;
res.sendFile(`/public/${file}`);

// ✅ GOOD: Validated and restricted path
const file = path.basename(req.query.file); // Remove directory traversal
const safePath = path.join(__dirname, 'public', file);

// Ensure path is within allowed directory
if (!safePath.startsWith(path.join(__dirname, 'public'))) {
  return res.status(400).send('Invalid file path');
}

res.sendFile(safePath);
```

### 5. Data Protection & Cryptography

**Data at Rest**:
- [ ] Sensitive data encrypted in database
- [ ] Proper encryption algorithm (AES-256)
- [ ] Encryption keys stored securely (not in code)
- [ ] Key rotation strategy implemented
- [ ] PII data identified and protected

**Data in Transit**:
- [ ] HTTPS/TLS enforced for all connections
- [ ] TLS 1.2+ required (TLS 1.0/1.1 disabled)
- [ ] Strong cipher suites configured
- [ ] HTTP Strict Transport Security (HSTS) enabled
- [ ] Certificate validation proper

**Password Security**:
- [ ] Passwords hashed with strong algorithm (bcrypt, argon2, scrypt)
- [ ] Salt used for each password
- [ ] No password length maximum (only minimum)
- [ ] Passwords never logged or stored in plain text
- [ ] Password reset tokens are cryptographically secure
- [ ] Password reset tokens expire

**Secrets Management**:
- [ ] No hardcoded secrets in code
- [ ] API keys in environment variables or secret manager
- [ ] Database credentials not in version control
- [ ] .env files in .gitignore
- [ ] Secrets rotation process exists

**Sensitive Data Handling**:
- [ ] Credit card numbers handled per PCI DSS
- [ ] PII minimized and protected
- [ ] No sensitive data in logs
- [ ] No sensitive data in URLs or query parameters
- [ ] Sensitive data masked in UI when appropriate

**Code Examples - Data Protection**:

```typescript
// ❌ CRITICAL: Hardcoded API key (example only - not a real key)
const apiKey = "sk_live_EXAMPLE_KEY_DO_NOT_HARDCODE_SECRETS";

// ✅ GOOD: Environment variable
const apiKey = process.env.STRIPE_API_KEY;
if (!apiKey) {
  throw new Error('STRIPE_API_KEY not configured');
}
```

```typescript
// ❌ CRITICAL: Weak password hashing
const hashedPassword = md5(password); // MD5 is broken!

// ❌ BAD: SHA-256 without salt
const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');

// ✅ GOOD: bcrypt with salt
const hashedPassword = await bcrypt.hash(password, 12); // Cost factor 12
```

```typescript
// ❌ CRITICAL: Sensitive data in logs
logger.info('User login', { email, password, creditCard });

// ✅ GOOD: No sensitive data
logger.info('User login', { email, userId });
```

```typescript
// ❌ CRITICAL: Weak random token
const resetToken = Math.random().toString(36);

// ✅ GOOD: Cryptographically secure random token
const resetToken = crypto.randomBytes(32).toString('hex');
```

### 6. CSRF & CORS Security

**CSRF Protection**:
- [ ] CSRF tokens implemented for state-changing operations
- [ ] SameSite cookie attribute set
- [ ] Double-submit cookie pattern used
- [ ] Custom headers required for AJAX requests
- [ ] Origin/Referer validation

**CORS Configuration**:
- [ ] CORS whitelist configured (not wildcard in production)
- [ ] Credentials allowed only for trusted origins
- [ ] Preflight requests handled correctly
- [ ] Access-Control-Max-Age set appropriately

**Code Examples - CSRF/CORS**:

```typescript
// ❌ CRITICAL: CORS allows all origins
app.use(cors({ origin: '*', credentials: true }));

// ✅ GOOD: CORS whitelist
const allowedOrigins = ['https://app.example.com', 'https://admin.example.com'];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

```typescript
// ❌ CRITICAL: No CSRF protection
app.post('/api/transfer-money', async (req, res) => {
  await transferMoney(req.body);
  res.json({ success: true });
});

// ✅ GOOD: CSRF token validation
app.post('/api/transfer-money', csrfProtection, async (req, res) => {
  await transferMoney(req.body);
  res.json({ success: true });
});
```

### 7. Security Headers

**Required Security Headers**:
- [ ] Content-Security-Policy (CSP)
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY or SAMEORIGIN
- [ ] X-XSS-Protection: 1; mode=block
- [ ] Strict-Transport-Security (HSTS)
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] Permissions-Policy (formerly Feature-Policy)

**Code Example - Security Headers**:

```typescript
// ✅ GOOD: Security headers configured
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  frameguard: {
    action: 'deny'
  }
}));
```

### 8. Dependency Security

**Vulnerability Scanning**:
```bash
# Node.js
npm audit
npm audit fix

# Python
pip-audit
safety check

# Go
go list -m all | nancy sleuth

# Check for outdated packages
npm outdated
pip list --outdated
```

**Dependencies Review**:
- [ ] No known critical vulnerabilities
- [ ] Dependencies up to date
- [ ] Unnecessary dependencies removed
- [ ] Development dependencies separate from production
- [ ] Lock files committed (package-lock.json, poetry.lock, go.sum)
- [ ] Automated dependency updates configured (Dependabot, Renovate)

### 9. Error Handling & Information Disclosure

**Secure Error Handling**:
- [ ] Error messages don't leak sensitive information
- [ ] Stack traces not shown to users in production
- [ ] Database errors sanitized
- [ ] Generic error messages for authentication failures
- [ ] Detailed errors logged server-side only
- [ ] No verbose debug output in production

**Code Examples - Error Handling**:

```typescript
// ❌ CRITICAL: Information disclosure
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    res.json(user);
  } catch (error) {
    // Exposes database details and stack trace!
    res.status(500).json({ error: error.message, stack: error.stack });
  }
});

// ✅ GOOD: Generic error, detailed logging
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    res.json(user);
  } catch (error) {
    logger.error('Error fetching user', { userId: req.params.id, error });
    res.status(500).json({ error: 'An error occurred processing your request' });
  }
});
```

```typescript
// ❌ CRITICAL: Authentication error reveals if user exists
if (!user) {
  return res.status(401).json({ error: 'User not found' });
}
if (!await bcrypt.compare(password, user.password)) {
  return res.status(401).json({ error: 'Invalid password' });
}

// ✅ GOOD: Generic authentication error
const user = await User.findByEmail(email);
const isValidPassword = user && await bcrypt.compare(password, user.password);

if (!user || !isValidPassword) {
  return res.status(401).json({ error: 'Invalid credentials' });
}
```

### 10. OWASP Top 10 Comprehensive Check

**A01: Broken Access Control**
- [ ] Authorization checks on all protected resources
- [ ] Users cannot access other users' data
- [ ] Insecure direct object references prevented
- [ ] API rate limiting implemented

**A02: Cryptographic Failures**
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Strong encryption algorithms used
- [ ] No hardcoded encryption keys
- [ ] TLS/HTTPS enforced

**A03: Injection**
- [ ] Parameterized queries for SQL
- [ ] Input validation and sanitization
- [ ] NoSQL injection prevented
- [ ] Command injection prevented
- [ ] LDAP/XML injection prevented

**A04: Insecure Design**
- [ ] Threat modeling performed
- [ ] Security requirements defined
- [ ] Secure design patterns used
- [ ] Separation of concerns enforced

**A05: Security Misconfiguration**
- [ ] Security headers configured
- [ ] Default passwords changed
- [ ] Unnecessary features disabled
- [ ] Error messages don't leak information
- [ ] Security patches applied

**A06: Vulnerable and Outdated Components**
- [ ] Dependencies up to date
- [ ] No known vulnerable packages
- [ ] Unused dependencies removed
- [ ] Automated vulnerability scanning

**A07: Identification and Authentication Failures**
- [ ] Strong password policy
- [ ] MFA available
- [ ] Account lockout implemented
- [ ] Session management secure
- [ ] Credential stuffing prevented

**A08: Software and Data Integrity Failures**
- [ ] Digital signatures verified
- [ ] CI/CD pipeline secured
- [ ] Untrusted deserialization prevented
- [ ] Supply chain security considered

**A09: Security Logging and Monitoring Failures**
- [ ] Security events logged
- [ ] Failed login attempts logged
- [ ] Logs protected from tampering
- [ ] Alerting configured for anomalies
- [ ] Audit trail maintained

**A10: Server-Side Request Forgery (SSRF)**
- [ ] URLs validated before fetching
- [ ] Whitelist of allowed domains
- [ ] No access to internal networks
- [ ] DNS rebinding prevented

## Review Depth Implementation

**Quick Depth** (10-15 min):
- Focus only on critical vulnerabilities
- Check for common security mistakes
- Review authentication and authorization
- Check for SQL injection and XSS

**Standard Depth** (30-40 min):
- All OWASP Top 10 categories
- Review security headers
- Check dependency vulnerabilities
- Review error handling
- Validate input sanitization

**Deep Depth** (60-90+ min):
- Comprehensive security audit
- Threat modeling for reviewed scope
- Architecture security review
- Complete OWASP Top 10 assessment
- Penetration testing recommendations
- Security test coverage review
- Compliance considerations (GDPR, PCI DSS)

## Output Format

```markdown
# Security Review: [Scope]

## Executive Summary

**Reviewed**: [What was reviewed]
**Depth**: [Quick|Standard|Deep]
**Security Risk**: [Low|Medium|High|Critical]

### Overall Security Posture
**[Secure|Minor Issues|Significant Concerns|Critical Vulnerabilities]**

[Brief explanation]

### Immediate Actions Required
1. [Critical issue 1]
2. [Critical issue 2]

---

## Critical Security Issues 🚨

### [Issue 1 Title]
**File**: `path/to/file.ts:42`
**Vulnerability Type**: [SQL Injection|XSS|Authentication Bypass|etc.]
**OWASP Category**: [A01-A10]
**Risk Level**: Critical
**Attack Vector**: [How this could be exploited]
**Impact**: [Data breach, unauthorized access, etc.]
**Remediation**: [Specific fix]

```typescript
// Current code (vulnerable)
[vulnerable code]

// Secure implementation
[secure code]
```

**Testing**: [How to verify the fix]

[Repeat for each critical issue]

---

## High Risk Issues ⚠️

[Similar format for high risk issues]

---

## Medium Risk Issues ℹ️

[Similar format for medium risk issues]

---

## Low Risk Issues 💡

[Similar format for low risk issues]

---

## OWASP Top 10 Assessment

| Category | Status | Findings |
|----------|--------|----------|
| A01: Broken Access Control | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A02: Cryptographic Failures | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A03: Injection | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A04: Insecure Design | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A05: Security Misconfiguration | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A06: Vulnerable Components | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A07: Authentication Failures | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A08: Software Integrity Failures | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A09: Logging Failures | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |
| A10: SSRF | ✅ Pass / ⚠️ Issues / ❌ Fail | [Details] |

---

## Security Strengths ✅

- ✅ [Security practice done well]
- ✅ [Security practice done well]

---

## Dependency Vulnerabilities

**Scan Results**:
```
[Output from npm audit, pip-audit, etc.]
```

**Critical Vulnerabilities**: [Count]
**High Vulnerabilities**: [Count]
**Recommendations**: [Update strategy]

---

## Security Headers Analysis

| Header | Configured | Recommendation |
|--------|-----------|----------------|
| Content-Security-Policy | ✅ / ❌ | [Details] |
| Strict-Transport-Security | ✅ / ❌ | [Details] |
| X-Content-Type-Options | ✅ / ❌ | [Details] |
| X-Frame-Options | ✅ / ❌ | [Details] |

---

## Remediation Roadmap

### Immediate (This Week)
- [ ] [Critical fix 1]
- [ ] [Critical fix 2]

### Short-term (This Month)
- [ ] [High priority fix 1]
- [ ] [High priority fix 2]

### Long-term (This Quarter)
- [ ] [Strategic improvement 1]
- [ ] [Security hardening 2]

---

## Security Testing Recommendations

1. [Penetration testing for X]
2. [Security automation for Y]
3. [Ongoing monitoring for Z]

---

## Compliance Considerations

- **GDPR**: [Relevant considerations]
- **PCI DSS**: [If handling payment data]
- **HIPAA**: [If handling health data]
- **SOC 2**: [If enterprise software]

---

## Review Metadata

- **Reviewer**: 10x Fullstack Engineer (Security Focus)
- **Review Date**: [Date]
- **Security Issues**: Critical: X, High: X, Medium: X, Low: X
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent with security expertise.

## Best Practices

1. **Assume Breach Mindset**: Think like an attacker
2. **Defense in Depth**: Multiple layers of security
3. **Principle of Least Privilege**: Minimal permissions necessary
4. **Fail Securely**: Default to denial of access
5. **Don't Trust User Input**: Validate everything
6. **Keep Security Simple**: Complexity is the enemy of security

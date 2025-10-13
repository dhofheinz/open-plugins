#!/usr/bin/env python3
"""
URL Validator - Check URL safety and detect malicious patterns
"""

import sys
import os
import re
import json
from pathlib import Path
from urllib.parse import urlparse
from typing import List, Dict, Tuple, Set

# ============================================================================
# Configuration
# ============================================================================

class Config:
    """Configuration for URL validation"""
    SUSPICIOUS_TLDS = {'.tk', '.ml', '.ga', '.cf', '.gq'}
    URL_SHORTENERS = {'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly'}
    TRUSTED_REGISTRIES = {
        'registry.npmjs.org',
        'pypi.org',
        'registry.hub.docker.com',
        'github.com',
        'gitlab.com'
    }

# ============================================================================
# URL Pattern Definitions
# ============================================================================

# Comprehensive URL pattern
URL_PATTERN = re.compile(
    r'(?:(?:https?|ftp|file)://|www\.|ftp\.)'
    r'(?:\S+(?::\S*)?@)?'
    r'(?:'
    r'(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])'
    r'(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}'
    r'(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))'
    r'|'
    r'(?:(?:[a-z\u00a1-\uffff0-9]-?)*[a-z\u00a1-\uffff0-9]+)'
    r'(?:\.(?:[a-z\u00a1-\uffff0-9]-?)*[a-z\u00a1-\uffff0-9]+)*'
    r'(?:\.(?:[a-z\u00a1-\uffff]{2,}))'
    r')'
    r'(?::\d{2,5})?'
    r'(?:[/?#]\S*)?',
    re.IGNORECASE
)

# Dangerous code execution patterns
DANGEROUS_PATTERNS = {
    'curl_pipe_sh': re.compile(r'curl\s+[^|]+\|\s*(sh|bash)', re.IGNORECASE),
    'wget_pipe_sh': re.compile(r'wget\s+[^|]+\|\s*(sh|bash)', re.IGNORECASE),
    'curl_silent_pipe': re.compile(r'curl\s+-[a-zA-Z]*s[a-zA-Z]*\s+[^|]+\|\s*(sh|bash)', re.IGNORECASE),
    'bash_redirect': re.compile(r'bash\s+<\s*\(\s*curl', re.IGNORECASE),
    'eval_fetch': re.compile(r'eval.*fetch\s*\(', re.IGNORECASE),
    'eval_curl': re.compile(r'eval.*curl', re.IGNORECASE),
    'exec_wget': re.compile(r'exec\s*\(.*wget', re.IGNORECASE),
    'rm_rf_url': re.compile(r'rm\s+-rf.*https?://', re.IGNORECASE),
}

# Obfuscation patterns
OBFUSCATION_PATTERNS = {
    'base64_url': re.compile(r'(?:atob|base64|Buffer\.from)\s*\([^)]*https?:', re.IGNORECASE),
    'hex_encoded': re.compile(r'\\x[0-9a-f]{2}.*https?:', re.IGNORECASE),
    'unicode_escape': re.compile(r'\\u[0-9a-f]{4}.*https?:', re.IGNORECASE),
}

# ============================================================================
# Severity Classification
# ============================================================================

class Severity:
    CRITICAL = 'critical'
    HIGH = 'high'
    MEDIUM = 'medium'
    LOW = 'low'

# ============================================================================
# Finding Class
# ============================================================================

class Finding:
    """Represents a URL security finding"""

    def __init__(self, file_path: str, line_num: int, url: str, issue: str,
                 severity: str, risk: str, remediation: str):
        self.file = file_path
        self.line = line_num
        self.url = url
        self.issue = issue
        self.severity = severity
        self.risk = risk
        self.remediation = remediation

    def to_dict(self) -> Dict:
        return {
            'file': self.file,
            'line': self.line,
            'url': self.url,
            'issue': self.issue,
            'severity': self.severity,
            'risk': self.risk,
            'remediation': self.remediation
        }

# ============================================================================
# URL Validator
# ============================================================================

class URLValidator:
    """Main URL validation class"""

    def __init__(self, path: str, https_only: bool = False,
                 allow_localhost: bool = True, check_code_patterns: bool = True):
        self.path = Path(path)
        self.https_only = https_only
        self.allow_localhost = allow_localhost
        self.check_code_patterns = check_code_patterns
        self.findings: List[Finding] = []
        self.urls_checked = 0
        self.files_scanned = 0

    def is_text_file(self, file_path: Path) -> bool:
        """Check if file is text"""
        try:
            with open(file_path, 'rb') as f:
                chunk = f.read(512)
                if b'\0' in chunk:
                    return False
                return True
        except Exception:
            return False

    def should_exclude(self, file_path: Path) -> bool:
        """Check if file should be excluded"""
        exclude_patterns = {'.git', 'node_modules', 'vendor', 'dist', 'build', '__pycache__'}
        return any(part in exclude_patterns for part in file_path.parts)

    def get_context(self, file_path: Path, line_num: int) -> str:
        """Get context around a line"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                if 0 <= line_num - 1 < len(lines):
                    # Check if in comment or documentation
                    line = lines[line_num - 1].strip()
                    if line.startswith('#') or line.startswith('//') or line.startswith('*'):
                        return 'documentation'
                    if 'test' in str(file_path).lower() or 'spec' in str(file_path).lower():
                        return 'test'
                    if 'example' in str(file_path).lower() or 'mock' in str(file_path).lower():
                        return 'example'
                    return 'production'
        except Exception:
            pass
        return 'unknown'

    def check_url_safety(self, url: str, file_path: Path, line_num: int) -> None:
        """Check if URL is safe"""
        try:
            parsed = urlparse(url)
        except Exception:
            return

        context = self.get_context(file_path, line_num)

        # Check protocol
        if parsed.scheme == 'http':
            # Allow localhost in development
            if self.allow_localhost and parsed.hostname in ('localhost', '127.0.0.1', '0.0.0.0'):
                return

            # Enforce HTTPS
            if self.https_only or context == 'production':
                severity = Severity.HIGH if context == 'production' else Severity.MEDIUM
                self.findings.append(Finding(
                    str(file_path), line_num, url,
                    'Non-HTTPS URL',
                    severity,
                    'Man-in-the-middle attacks, data interception',
                    'Change to HTTPS: ' + url.replace('http://', 'https://')
                ))
                return

        # Check for FTP/Telnet
        if parsed.scheme in ('ftp', 'telnet'):
            self.findings.append(Finding(
                str(file_path), line_num, url,
                'Insecure protocol',
                Severity.HIGH,
                'Unencrypted data transmission',
                'Use secure alternatives (HTTPS, SFTP, SSH)'
            ))
            return

        # Check for file:// protocol
        if parsed.scheme == 'file':
            self.findings.append(Finding(
                str(file_path), line_num, url,
                'File protocol detected',
                Severity.MEDIUM,
                'Potential security risk, path disclosure',
                'Review necessity of file:// protocol'
            ))

        # Check for IP addresses
        if parsed.hostname and re.match(r'^\d+\.\d+\.\d+\.\d+$', parsed.hostname):
            self.findings.append(Finding(
                str(file_path), line_num, url,
                'IP address instead of domain',
                Severity.LOW,
                'Harder to verify legitimacy, no certificate validation',
                'Use domain name instead of IP address'
            ))

        # Check for suspicious TLDs
        if parsed.hostname:
            for tld in Config.SUSPICIOUS_TLDS:
                if parsed.hostname.endswith(tld):
                    self.findings.append(Finding(
                        str(file_path), line_num, url,
                        'Suspicious TLD',
                        Severity.MEDIUM,
                        'Often used for malicious purposes',
                        'Verify domain legitimacy before use'
                    ))
                    break

            # Check for URL shorteners
            if parsed.hostname in Config.URL_SHORTENERS:
                self.findings.append(Finding(
                    str(file_path), line_num, url,
                    'Shortened URL',
                    Severity.LOW,
                    'Cannot verify destination',
                    'Expand URL and use full destination'
                ))

    def check_dangerous_patterns(self, content: str, file_path: Path) -> None:
        """Check for dangerous code execution patterns"""
        if not self.check_code_patterns:
            return

        lines = content.split('\n')

        for pattern_name, pattern in DANGEROUS_PATTERNS.items():
            for match in pattern.finditer(content):
                line_num = content[:match.start()].count('\n') + 1
                self.findings.append(Finding(
                    str(file_path), line_num, match.group(0),
                    'Remote code execution pattern',
                    Severity.CRITICAL,
                    f'Executes arbitrary code from remote source ({pattern_name})',
                    'Download, verify checksum, review code, then execute'
                ))

        for pattern_name, pattern in OBFUSCATION_PATTERNS.items():
            for match in pattern.finditer(content):
                line_num = content[:match.start()].count('\n') + 1
                self.findings.append(Finding(
                    str(file_path), line_num, match.group(0)[:50] + '...',
                    'Obfuscated URL',
                    Severity.HIGH,
                    f'URL obfuscation detected ({pattern_name})',
                    'Review obfuscated content for malicious intent'
                ))

    def scan_file(self, file_path: Path) -> None:
        """Scan a single file"""
        if self.should_exclude(file_path) or not self.is_text_file(file_path):
            return

        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            self.files_scanned += 1

            # Check for dangerous patterns first
            self.check_dangerous_patterns(content, file_path)

            # Find all URLs
            lines = content.split('\n')
            for line_num, line in enumerate(lines, 1):
                for match in URL_PATTERN.finditer(line):
                    url = match.group(0)
                    self.urls_checked += 1
                    self.check_url_safety(url, file_path, line_num)

        except Exception as e:
            print(f"Warning: Could not scan {file_path}: {e}", file=sys.stderr)

    def scan(self) -> None:
        """Scan path for URLs"""
        if self.path.is_file():
            self.scan_file(self.path)
        elif self.path.is_dir():
            for file_path in self.path.rglob('*'):
                if file_path.is_file():
                    self.scan_file(file_path)

    def report(self) -> int:
        """Generate report and return exit code"""
        print("URL Safety Scan Results")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(f"Path: {self.path}")
        print(f"Files Scanned: {self.files_scanned}")
        print(f"URLs Checked: {self.urls_checked}")
        print()

        if not self.findings:
            print("✅ SUCCESS: All URLs safe")
            print("No unsafe URLs or malicious patterns detected")
            return 0

        # Group by severity
        critical = [f for f in self.findings if f.severity == Severity.CRITICAL]
        high = [f for f in self.findings if f.severity == Severity.HIGH]
        medium = [f for f in self.findings if f.severity == Severity.MEDIUM]
        low = [f for f in self.findings if f.severity == Severity.LOW]

        print(f"⚠️  UNSAFE URLS DETECTED: {len(self.findings)}")
        print()

        if critical:
            print(f"CRITICAL Issues ({len(critical)}):")
            for finding in critical:
                print(f"  ❌ {finding.file}:{finding.line}")
                print(f"     Pattern: {finding.url}")
                print(f"     Risk: {finding.risk}")
                print(f"     Remediation: {finding.remediation}")
                print()

        if high:
            print(f"HIGH Issues ({len(high)}):")
            for finding in high:
                print(f"  ⚠️  {finding.file}:{finding.line}")
                print(f"     URL: {finding.url}")
                print(f"     Issue: {finding.issue}")
                print(f"     Remediation: {finding.remediation}")
                print()

        if medium:
            print(f"MEDIUM Issues ({len(medium)}):")
            for finding in medium:
                print(f"  💡 {finding.file}:{finding.line}")
                print(f"     Issue: {finding.issue}")
                print()

        print("Summary:")
        print(f"  Critical: {len(critical)}")
        print(f"  High: {len(high)}")
        print(f"  Medium: {len(medium)}")
        print(f"  Low: {len(low)}")
        print()
        print("Action Required: YES" if (critical or high) else "Review Recommended")

        return 1

# ============================================================================
# Main
# ============================================================================

def main():
    if len(sys.argv) < 2:
        print("Usage: url-validator.py <path> [https_only] [allow_localhost] [check_code_patterns]")
        sys.exit(2)

    path = sys.argv[1]
    https_only = sys.argv[2].lower() == 'true' if len(sys.argv) > 2 else False
    allow_localhost = sys.argv[3].lower() == 'true' if len(sys.argv) > 3 else True
    check_code_patterns = sys.argv[4].lower() == 'true' if len(sys.argv) > 4 else True

    if not os.path.exists(path):
        print(f"ERROR: Path does not exist: {path}", file=sys.stderr)
        sys.exit(2)

    validator = URLValidator(path, https_only, allow_localhost, check_code_patterns)
    validator.scan()
    sys.exit(validator.report())

if __name__ == '__main__':
    main()

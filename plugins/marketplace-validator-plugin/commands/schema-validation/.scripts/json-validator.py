#!/usr/bin/env python3

# ============================================================================
# JSON Validator Script
# ============================================================================
# Purpose: Multi-backend JSON syntax validation with detailed error reporting
# Version: 1.0.0
# Usage: ./json-validator.py --file <path> [--verbose]
# Returns: 0=valid, 1=invalid, 2=error
# Backends: jq (preferred), python3 json module (fallback)
# ============================================================================

import json
import sys
import argparse
import subprocess
import shutil
from pathlib import Path


# ====================
# Color Support
# ====================

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'

    @classmethod
    def disable(cls):
        """Disable colors for non-TTY output"""
        cls.RED = cls.GREEN = cls.YELLOW = cls.BLUE = cls.CYAN = cls.BOLD = cls.NC = ''


if not sys.stdout.isatty():
    Colors.disable()


# ====================
# Backend Detection
# ====================

def detect_backend():
    """Detect available JSON validation backend"""
    if shutil.which('jq'):
        return 'jq'
    elif sys.version_info >= (3, 0):
        return 'python3'
    else:
        return 'none'


def print_backend_info():
    """Print detected backend information"""
    backend = detect_backend()
    if backend == 'jq':
        print(f"{Colors.GREEN}✅ Backend: jq (preferred){Colors.NC}")
    elif backend == 'python3':
        print(f"{Colors.YELLOW}⚠️  Backend: python3 (fallback){Colors.NC}")
    else:
        print(f"{Colors.RED}❌ No JSON validator available{Colors.NC}")
        print(f"{Colors.BLUE}ℹ️  Install jq for better error messages: apt-get install jq{Colors.NC}")
    return backend


# ====================
# JQ Backend
# ====================

def validate_with_jq(file_path, verbose=False):
    """Validate JSON using jq (provides better error messages)"""
    try:
        result = subprocess.run(
            ['jq', 'empty', file_path],
            capture_output=True,
            text=True,
            check=False
        )

        if result.returncode == 0:
            print(f"{Colors.GREEN}✅ Valid JSON: {file_path}{Colors.NC}")
            print(f"Backend: jq")
            return 0
        else:
            # Parse jq error message
            error_msg = result.stderr.strip()
            print(f"{Colors.RED}❌ Invalid JSON: {file_path}{Colors.NC}")

            if verbose:
                print(f"{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
                print(f"{Colors.RED}Error Details:{Colors.NC}")
                print(f"  {error_msg}")
                print()
                print(f"{Colors.YELLOW}Remediation:{Colors.NC}")
                print("  - Check for missing commas between object properties")
                print("  - Verify bracket matching: [ ] { }")
                print("  - Ensure proper string quoting")
                print("  - Use a JSON formatter/linter in your editor")
            else:
                # Extract line number if available
                if "parse error" in error_msg.lower():
                    print(f"Error: {error_msg}")

            return 1

    except FileNotFoundError:
        print(f"{Colors.RED}❌ File not found: {file_path}{Colors.NC}", file=sys.stderr)
        return 2
    except Exception as e:
        print(f"{Colors.RED}❌ Error running jq: {e}{Colors.NC}", file=sys.stderr)
        return 2


# ====================
# Python3 Backend
# ====================

def validate_with_python(file_path, verbose=False):
    """Validate JSON using Python's json module (universal fallback)"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Attempt to parse JSON
        json.loads(content)

        print(f"{Colors.GREEN}✅ Valid JSON: {file_path}{Colors.NC}")
        print(f"Backend: python3")
        return 0

    except FileNotFoundError:
        print(f"{Colors.RED}❌ File not found: {file_path}{Colors.NC}", file=sys.stderr)
        return 2

    except json.JSONDecodeError as e:
        print(f"{Colors.RED}❌ Invalid JSON: {file_path}{Colors.NC}")

        if verbose:
            print(f"{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.NC}")
            print(f"{Colors.RED}Error Details:{Colors.NC}")
            print(f"  Line: {e.lineno}")
            print(f"  Column: {e.colno}")
            print(f"  Issue: {e.msg}")
            print()

            # Show problematic section
            try:
                lines = content.split('\n')
                start = max(0, e.lineno - 3)
                end = min(len(lines), e.lineno + 2)

                print(f"Problematic Section (lines {start+1}-{end}):")
                for i in range(start, end):
                    line_num = i + 1
                    marker = "→" if line_num == e.lineno else " "
                    print(f"  {marker} {line_num:3d} | {lines[i]}")

                print()
            except:
                pass

            print(f"{Colors.YELLOW}Remediation:{Colors.NC}")
            print("  - Check for missing commas between array elements or object properties")
            print("  - Verify bracket matching: [ ] { }")
            print("  - Ensure all strings are properly quoted")
            print("  - Use a JSON formatter/linter in your editor")
        else:
            print(f"Error: {e.msg} at line {e.lineno}, column {e.colno}")

        return 1

    except Exception as e:
        print(f"{Colors.RED}❌ Error reading file: {e}{Colors.NC}", file=sys.stderr)
        return 2


# ====================
# Main Validation
# ====================

def validate_json(file_path, verbose=False):
    """Main validation function with backend selection"""
    backend = detect_backend()

    if backend == 'none':
        print(f"{Colors.RED}❌ No JSON validation backend available{Colors.NC}", file=sys.stderr)
        print(f"{Colors.BLUE}ℹ️  Install jq or ensure python3 is available{Colors.NC}", file=sys.stderr)
        return 2

    if backend == 'jq':
        return validate_with_jq(file_path, verbose)
    else:
        return validate_with_python(file_path, verbose)


# ====================
# CLI Interface
# ====================

def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description='Validate JSON file syntax with multi-backend support',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  ./json-validator.py --file plugin.json
  ./json-validator.py --file marketplace.json --verbose
  ./json-validator.py --detect

Backends:
  - jq (preferred): Fast, excellent error messages
  - python3 (fallback): Universal availability

Exit codes:
  0: Valid JSON
  1: Invalid JSON
  2: File error or backend unavailable
        '''
    )

    parser.add_argument(
        '--file',
        type=str,
        help='Path to JSON file to validate'
    )

    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Show detailed error information and remediation'
    )

    parser.add_argument(
        '--detect',
        action='store_true',
        help='Detect and display available backend'
    )

    args = parser.parse_args()

    # Handle backend detection
    if args.detect:
        print_backend_info()
        return 0

    # Validate required arguments
    if not args.file:
        parser.print_help()
        return 2

    # Perform validation
    return validate_json(args.file, args.verbose)


if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3

"""
============================================================================
Keyword Quality Analyzer
============================================================================
Purpose: Analyze keyword quality, count, and relevance for OpenPlugins
Version: 1.0.0
Usage: ./keyword-analyzer.py <keywords> [--min N] [--max N]
Returns: 0=valid, 1=count violation, 2=quality issues, 3=missing params
============================================================================
"""

import sys
import re
from typing import List, Tuple, Dict

# Default constraints
DEFAULT_MIN_KEYWORDS = 3
DEFAULT_MAX_KEYWORDS = 7

# Generic terms to avoid
GENERIC_BLOCKLIST = [
    'plugin', 'tool', 'utility', 'helper', 'app',
    'code', 'software', 'program', 'system',
    'awesome', 'best', 'perfect', 'great', 'super',
    'amazing', 'cool', 'nice', 'good', 'excellent'
]

# OpenPlugins categories (should not be duplicated as keywords)
CATEGORIES = [
    'development', 'testing', 'deployment', 'documentation',
    'security', 'database', 'monitoring', 'productivity',
    'quality', 'collaboration'
]

# Common keyword types for balance checking
FUNCTIONALITY_KEYWORDS = [
    'testing', 'deployment', 'formatting', 'linting', 'migration',
    'generation', 'automation', 'analysis', 'monitoring', 'scanning',
    'refactoring', 'debugging', 'profiling', 'optimization'
]

TECHNOLOGY_KEYWORDS = [
    'python', 'javascript', 'typescript', 'docker', 'kubernetes',
    'react', 'vue', 'angular', 'node', 'bash', 'terraform',
    'postgresql', 'mysql', 'redis', 'aws', 'azure', 'gcp'
]


def usage():
    """Print usage information"""
    print("""Usage: keyword-analyzer.py <keywords> [--min N] [--max N]

Analyze keyword quality and relevance for OpenPlugins standards.

Arguments:
  keywords    Comma-separated list of keywords (required)
  --min N     Minimum keyword count (default: 3)
  --max N     Maximum keyword count (default: 7)

Requirements:
  - Count: 3-7 keywords (optimal: 5-6)
  - No generic terms (plugin, tool, awesome)
  - No marketing fluff (best, perfect, amazing)
  - Mix of functionality and technology
  - No redundant variations

Good examples:
  "testing,pytest,automation,tdd,python"
  "deployment,kubernetes,ci-cd,docker"
  "linting,javascript,code-quality"

Bad examples:
  "plugin,tool,awesome" (generic)
  "test,testing,tests" (redundant)
  "development" (only one, too generic)

Exit codes:
  0 - Valid keyword set
  1 - Count violation (too few or too many)
  2 - Quality issues (generic terms, duplicates)
  3 - Missing required parameters
""")
    sys.exit(3)


def parse_keywords(keyword_string: str) -> List[str]:
    """Parse and normalize keyword string"""
    if not keyword_string:
        return []

    # Split by comma, strip whitespace, lowercase
    keywords = [k.strip().lower() for k in keyword_string.split(',')]

    # Remove empty strings
    keywords = [k for k in keywords if k]

    # Remove duplicates while preserving order
    seen = set()
    unique_keywords = []
    for k in keywords:
        if k not in seen:
            seen.add(k)
            unique_keywords.append(k)

    return unique_keywords


def check_generic_terms(keywords: List[str]) -> Tuple[List[str], List[str]]:
    """
    Check for generic and marketing terms

    Returns:
        (generic_terms, marketing_terms)
    """
    generic_terms = []
    marketing_terms = []

    for keyword in keywords:
        if keyword in GENERIC_BLOCKLIST:
            if keyword in ['awesome', 'best', 'perfect', 'great', 'super', 'amazing', 'cool', 'nice', 'good', 'excellent']:
                marketing_terms.append(keyword)
            else:
                generic_terms.append(keyword)

    return generic_terms, marketing_terms


def check_redundant_variations(keywords: List[str]) -> List[Tuple[str, str]]:
    """
    Find redundant keyword variations

    Returns:
        List of (keyword1, keyword2) pairs that are redundant
    """
    redundant = []

    for i, kw1 in enumerate(keywords):
        for kw2 in keywords[i+1:]:
            # Check if one is a substring of the other
            if kw1 in kw2 or kw2 in kw1:
                redundant.append((kw1, kw2))
            # Check for plural variations
            elif kw1.rstrip('s') == kw2 or kw2.rstrip('s') == kw1:
                redundant.append((kw1, kw2))

    return redundant


def check_category_duplication(keywords: List[str]) -> List[str]:
    """Check if any keywords exactly match category names"""
    duplicates = []
    for keyword in keywords:
        if keyword in CATEGORIES:
            duplicates.append(keyword)
    return duplicates


def analyze_balance(keywords: List[str]) -> Dict[str, int]:
    """
    Analyze keyword balance across types

    Returns:
        Dict with counts for each type
    """
    balance = {
        'functionality': 0,
        'technology': 0,
        'other': 0
    }

    for keyword in keywords:
        if keyword in FUNCTIONALITY_KEYWORDS:
            balance['functionality'] += 1
        elif keyword in TECHNOLOGY_KEYWORDS:
            balance['technology'] += 1
        else:
            balance['other'] += 1

    return balance


def calculate_quality_score(
    keywords: List[str],
    generic_terms: List[str],
    marketing_terms: List[str],
    redundant: List[Tuple[str, str]],
    category_dups: List[str],
    min_count: int,
    max_count: int
) -> Tuple[int, List[str]]:
    """
    Calculate quality score and list issues

    Returns:
        (score out of 10, list of issues)
    """
    score = 10
    issues = []

    # Count violations
    count = len(keywords)
    if count < min_count:
        score -= 5
        issues.append(f"Too few keywords ({count} < {min_count} minimum)")
    elif count > max_count:
        score -= 3
        issues.append(f"Too many keywords ({count} > {max_count} maximum)")

    # Generic terms
    if generic_terms:
        score -= len(generic_terms) * 2
        issues.append(f"Generic terms detected: {', '.join(generic_terms)}")

    # Marketing terms
    if marketing_terms:
        score -= len(marketing_terms) * 2
        issues.append(f"Marketing terms detected: {', '.join(marketing_terms)}")

    # Redundant variations
    if redundant:
        score -= len(redundant) * 2
        redundant_str = ', '.join([f"{a}/{b}" for a, b in redundant])
        issues.append(f"Redundant variations: {redundant_str}")

    # Category duplication
    if category_dups:
        score -= len(category_dups) * 1
        issues.append(f"Category name duplication: {', '.join(category_dups)}")

    # Single-character keywords
    single_char = [k for k in keywords if len(k) == 1]
    if single_char:
        score -= len(single_char) * 2
        issues.append(f"Single-character keywords: {', '.join(single_char)}")

    # Balance check
    balance = analyze_balance(keywords)
    if balance['functionality'] == 0 and balance['technology'] == 0:
        score -= 2
        issues.append("No functional or technical keywords")

    return max(0, score), issues


def suggest_improvements(
    keywords: List[str],
    generic_terms: List[str],
    marketing_terms: List[str],
    redundant: List[Tuple[str, str]],
    min_count: int,
    max_count: int
) -> List[str]:
    """Generate improvement suggestions"""
    suggestions = []

    # Remove generic/marketing terms
    if generic_terms or marketing_terms:
        suggestions.append("Remove generic/marketing terms")
        suggestions.append("  Replace with specific functionality (e.g., testing, deployment, formatting)")

    # Consolidate redundant variations
    if redundant:
        suggestions.append("Consolidate redundant variations")
        for kw1, kw2 in redundant:
            suggestions.append(f"  Keep one of: {kw1}, {kw2}")

    # Add more keywords if too few
    count = len(keywords)
    if count < min_count:
        needed = min_count - count
        suggestions.append(f"Add {needed} more relevant keyword(s)")
        suggestions.append("  Consider: specific technologies, use-cases, or functionalities")

    # Remove keywords if too many
    elif count > max_count:
        excess = count - max_count
        suggestions.append(f"Remove {excess} least relevant keyword(s)")

    # Balance suggestions
    balance = analyze_balance(keywords)
    if balance['functionality'] == 0:
        suggestions.append("Add functionality keywords (e.g., testing, automation, deployment)")
    if balance['technology'] == 0:
        suggestions.append("Add technology keywords (e.g., python, docker, kubernetes)")

    return suggestions


def main():
    """Main entry point"""
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        usage()

    keyword_string = sys.argv[1]

    # Parse optional arguments
    min_count = DEFAULT_MIN_KEYWORDS
    max_count = DEFAULT_MAX_KEYWORDS

    for i, arg in enumerate(sys.argv[2:], start=2):
        if arg == '--min' and i + 1 < len(sys.argv):
            min_count = int(sys.argv[i + 1])
        elif arg == '--max' and i + 1 < len(sys.argv):
            max_count = int(sys.argv[i + 1])

    # Parse keywords
    keywords = parse_keywords(keyword_string)

    if not keywords:
        print("ERROR: Keywords cannot be empty\n")
        print("Provide 3-7 relevant keywords describing your plugin.\n")
        print("Examples:")
        print('  "testing,pytest,automation"')
        print('  "deployment,kubernetes,ci-cd"')
        sys.exit(3)

    # Analyze keywords
    count = len(keywords)
    generic_terms, marketing_terms = check_generic_terms(keywords)
    redundant = check_redundant_variations(keywords)
    category_dups = check_category_duplication(keywords)
    balance = analyze_balance(keywords)

    # Calculate quality score
    score, issues = calculate_quality_score(
        keywords, generic_terms, marketing_terms,
        redundant, category_dups, min_count, max_count
    )

    # Determine status
    if score >= 9 and min_count <= count <= max_count:
        status = "✅ PASS"
        exit_code = 0
    elif count < min_count or count > max_count:
        status = "❌ FAIL"
        exit_code = 1
    elif score < 7:
        status = "❌ FAIL"
        exit_code = 2
    else:
        status = "⚠️  WARNING"
        exit_code = 0

    # Print results
    print(f"{status}: Keyword validation\n")
    print(f"Keywords: {', '.join(keywords)}")
    print(f"Count: {count} (valid range: {min_count}-{max_count})")
    print(f"Quality Score: {score}/10\n")

    if issues:
        print("Issues Found:")
        for issue in issues:
            print(f"  - {issue}")
        print()

    # Balance breakdown
    print("Breakdown:")
    print(f"  - Functionality: {balance['functionality']} keywords")
    print(f"  - Technology: {balance['technology']} keywords")
    print(f"  - Other: {balance['other']} keywords")
    print()

    # Score impact
    if score >= 9:
        print("Quality Score Impact: +10 points (excellent)\n")
        if exit_code == 0:
            print("Excellent keyword selection for discoverability!")
    elif score >= 7:
        print("Quality Score Impact: +7 points (good)\n")
        print("Good keywords, but could be improved.")
    else:
        print("Quality Score Impact: 0 points (fix to gain +10)\n")
        print("Keywords need significant improvement.")

    # Suggestions
    if issues:
        suggestions = suggest_improvements(
            keywords, generic_terms, marketing_terms,
            redundant, min_count, max_count
        )
        if suggestions:
            print("\nSuggestions:")
            for suggestion in suggestions:
                print(f"  {suggestion}")

    sys.exit(exit_code)


if __name__ == '__main__':
    main()

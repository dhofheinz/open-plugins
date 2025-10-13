#!/usr/bin/env python3

# ============================================================================
# Quality Scoring Algorithm
# ============================================================================
# Purpose: Calculate quality score (0-100) based on validation results
# Version: 1.0.0
# Usage: ./scoring-algorithm.py --errors N --warnings N --missing N
# Returns: 0=success, 1=error
# Dependencies: Python 3.6+
# ============================================================================

import sys
import argparse
import json


def calculate_quality_score(errors: int, warnings: int, missing_recommended: int) -> int:
    """
    Calculate quality score based on validation issues.

    Algorithm:
        score = 100
        score -= errors * 20          # Critical errors: -20 each
        score -= warnings * 10        # Warnings: -10 each
        score -= missing_recommended * 5  # Missing fields: -5 each
        return max(0, score)

    Args:
        errors: Number of critical errors
        warnings: Number of warnings
        missing_recommended: Number of missing recommended fields

    Returns:
        Quality score (0-100)
    """
    score = 100
    score -= errors * 20
    score -= warnings * 10
    score -= missing_recommended * 5
    return max(0, score)


def get_rating(score: int) -> str:
    """
    Get quality rating based on score.

    Args:
        score: Quality score (0-100)

    Returns:
        Rating string
    """
    if score >= 90:
        return "Excellent"
    elif score >= 75:
        return "Good"
    elif score >= 60:
        return "Fair"
    elif score >= 40:
        return "Needs Improvement"
    else:
        return "Poor"


def get_stars(score: int) -> str:
    """
    Get star rating based on score.

    Args:
        score: Quality score (0-100)

    Returns:
        Star rating string
    """
    if score >= 90:
        return "⭐⭐⭐⭐⭐"
    elif score >= 75:
        return "⭐⭐⭐⭐"
    elif score >= 60:
        return "⭐⭐⭐"
    elif score >= 40:
        return "⭐⭐"
    else:
        return "⭐"


def get_publication_readiness(score: int) -> str:
    """
    Determine publication readiness based on score.

    Args:
        score: Quality score (0-100)

    Returns:
        Publication readiness status
    """
    if score >= 90:
        return "Yes - Ready to publish"
    elif score >= 75:
        return "With Minor Changes - Nearly ready"
    elif score >= 60:
        return "Needs Work - Significant improvements needed"
    else:
        return "Not Ready - Major overhaul required"


def format_output(score: int, errors: int, warnings: int, missing: int,
                  output_format: str = "text") -> str:
    """
    Format score output in requested format.

    Args:
        score: Quality score
        errors: Error count
        warnings: Warning count
        missing: Missing field count
        output_format: Output format (text, json, compact)

    Returns:
        Formatted output string
    """
    rating = get_rating(score)
    stars = get_stars(score)
    readiness = get_publication_readiness(score)

    if output_format == "json":
        return json.dumps({
            "score": score,
            "rating": rating,
            "stars": stars,
            "publication_ready": readiness,
            "breakdown": {
                "base_score": 100,
                "errors_penalty": errors * 20,
                "warnings_penalty": warnings * 10,
                "missing_penalty": missing * 5
            },
            "counts": {
                "errors": errors,
                "warnings": warnings,
                "missing": missing
            }
        }, indent=2)

    elif output_format == "compact":
        return f"{score}/100 {stars} ({rating})"

    else:  # text format
        error_penalty = errors * 20
        warning_penalty = warnings * 10
        missing_penalty = missing * 5

        return f"""━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUALITY SCORE CALCULATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: {score}/100
Rating: {rating}
Stars: {stars}

Breakdown:
  Base Score:        100
  Critical Errors:   -{error_penalty} ({errors} × 20)
  Warnings:          -{warning_penalty} ({warnings} × 10)
  Missing Fields:    -{missing_penalty} ({missing} × 5)
  ─────────────────────
  Final Score:       {score}/100

Publication Ready: {readiness}
"""


def main():
    """Main CLI interface."""
    parser = argparse.ArgumentParser(
        description="Calculate quality score based on validation results",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --errors 2 --warnings 5 --missing 3
  %(prog)s --errors 0 --warnings 0 --missing 0
  %(prog)s --errors 1 --format json
        """
    )

    parser.add_argument(
        "--errors",
        type=int,
        default=0,
        help="Number of critical errors (default: 0)"
    )

    parser.add_argument(
        "--warnings",
        type=int,
        default=0,
        help="Number of warnings (default: 0)"
    )

    parser.add_argument(
        "--missing",
        type=int,
        default=0,
        help="Number of missing recommended fields (default: 0)"
    )

    parser.add_argument(
        "--format",
        choices=["text", "json", "compact"],
        default="text",
        help="Output format (default: text)"
    )

    args = parser.parse_args()

    # Validate inputs
    if args.errors < 0 or args.warnings < 0 or args.missing < 0:
        print("Error: Counts cannot be negative", file=sys.stderr)
        return 1

    # Calculate score
    score = calculate_quality_score(args.errors, args.warnings, args.missing)

    # Format and print output
    output = format_output(
        score,
        args.errors,
        args.warnings,
        args.missing,
        args.format
    )
    print(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3

"""
============================================================================
Validation Dispatcher Script
============================================================================
Purpose: Route validation requests and aggregate results from multiple layers
Version: 1.0.0
Usage: ./validation-dispatcher.py --mode=<mode> [options]
Returns: 0=success, 1=error
============================================================================
"""

import sys
import json
import argparse
from pathlib import Path
from typing import Dict, List, Any
from enum import Enum


class ValidationMode(Enum):
    """Validation dispatch modes"""
    ROUTE = "route"      # Route to appropriate validator
    AGGREGATE = "aggregate"  # Aggregate results from multiple validators


class ValidationResult:
    """Validation result structure"""

    def __init__(self):
        self.layers: Dict[str, Dict[str, Any]] = {}
        self.overall_score = 0
        self.critical_issues = 0
        self.warnings = 0
        self.recommendations = 0

    def add_layer(self, name: str, result: Dict[str, Any]):
        """Add a validation layer result"""
        self.layers[name] = result

        # Aggregate counts
        if 'critical_issues' in result:
            self.critical_issues += result['critical_issues']
        if 'warnings' in result:
            self.warnings += result['warnings']
        if 'recommendations' in result:
            self.recommendations += result['recommendations']

    def calculate_overall_score(self):
        """Calculate overall quality score from all layers"""
        if not self.layers:
            return 0

        total_score = 0
        layer_count = 0

        for layer, result in self.layers.items():
            if 'score' in result:
                total_score += result['score']
                layer_count += 1

        if layer_count > 0:
            self.overall_score = total_score // layer_count
        else:
            # Fallback calculation based on issues
            self.overall_score = max(0, 100 - (self.critical_issues * 20) -
                                   (self.warnings * 10) - (self.recommendations * 5))

        return self.overall_score

    def get_rating(self) -> str:
        """Get quality rating based on score"""
        score = self.overall_score
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

    def get_stars(self) -> str:
        """Get star rating"""
        score = self.overall_score
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

    def is_publication_ready(self) -> str:
        """Determine publication readiness"""
        if self.critical_issues > 0:
            return "Not Ready"
        elif self.overall_score >= 75:
            return "Ready"
        else:
            return "Needs Work"

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            "overall_score": self.overall_score,
            "rating": self.get_rating(),
            "stars": self.get_stars(),
            "publication_ready": self.is_publication_ready(),
            "critical_issues": self.critical_issues,
            "warnings": self.warnings,
            "recommendations": self.recommendations,
            "layers": self.layers
        }


class ValidationDispatcher:
    """Dispatcher for validation routing and aggregation"""

    def __init__(self, mode: ValidationMode):
        self.mode = mode
        self.result = ValidationResult()

    def route(self, target_type: str, target_path: str, level: str) -> Dict[str, Any]:
        """Route to appropriate validator based on target type"""
        routing = {
            "marketplace": {
                "quick": "/validate-quick",
                "comprehensive": "/validate-marketplace"
            },
            "plugin": {
                "quick": "/validate-quick",
                "comprehensive": "/validate-plugin"
            }
        }

        if target_type not in routing:
            return {
                "error": f"Unknown target type: {target_type}",
                "supported": list(routing.keys())
            }

        command = routing[target_type].get(level, routing[target_type]["comprehensive"])

        return {
            "target_type": target_type,
            "target_path": target_path,
            "validation_level": level,
            "command": command,
            "invocation": f"{command} {target_path}"
        }

    def aggregate(self, layer_results: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Aggregate results from multiple validation layers"""
        for layer_data in layer_results:
            layer_name = layer_data.get('layer', 'unknown')
            self.result.add_layer(layer_name, layer_data)

        self.result.calculate_overall_score()

        return self.result.to_dict()

    def format_output(self, data: Dict[str, Any]) -> str:
        """Format output for console display"""
        if self.mode == ValidationMode.ROUTE:
            return json.dumps(data, indent=2)
        elif self.mode == ValidationMode.AGGREGATE:
            # Pretty print aggregated results
            lines = []
            lines.append("=" * 60)
            lines.append("AGGREGATED VALIDATION RESULTS")
            lines.append("=" * 60)
            lines.append(f"Overall Score: {data['overall_score']}/100 {data['stars']}")
            lines.append(f"Rating: {data['rating']}")
            lines.append(f"Publication Ready: {data['publication_ready']}")
            lines.append("")
            lines.append(f"Critical Issues: {data['critical_issues']}")
            lines.append(f"Warnings: {data['warnings']}")
            lines.append(f"Recommendations: {data['recommendations']}")
            lines.append("")
            lines.append("Layer Results:")
            for layer, result in data['layers'].items():
                status = result.get('status', 'unknown')
                lines.append(f"  - {layer}: {status}")
            lines.append("=" * 60)
            return "\n".join(lines)


def main():
    """Main execution"""
    parser = argparse.ArgumentParser(description="Validation dispatcher")
    parser.add_argument("--mode", required=True, choices=["route", "aggregate"],
                        help="Dispatch mode")
    parser.add_argument("--target-type", help="Target type for routing")
    parser.add_argument("--target-path", default=".", help="Target path")
    parser.add_argument("--level", default="comprehensive",
                        choices=["quick", "comprehensive"],
                        help="Validation level")
    parser.add_argument("--results", help="JSON file with layer results for aggregation")
    parser.add_argument("--json", action="store_true", help="Output JSON format")

    args = parser.parse_args()

    mode = ValidationMode(args.mode)
    dispatcher = ValidationDispatcher(mode)

    try:
        if mode == ValidationMode.ROUTE:
            if not args.target_type:
                print("Error: --target-type required for route mode", file=sys.stderr)
                return 1

            result = dispatcher.route(args.target_type, args.target_path, args.level)

        elif mode == ValidationMode.AGGREGATE:
            if not args.results:
                print("Error: --results required for aggregate mode", file=sys.stderr)
                return 1

            with open(args.results, 'r') as f:
                layer_results = json.load(f)

            result = dispatcher.aggregate(layer_results)

        # Output results
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(dispatcher.format_output(result))

        return 0

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Analyze Claude Code permission request logs and suggest allow rules."""

import argparse
import json
import os
import sys
from collections import Counter, defaultdict
from datetime import datetime


LOG_DIR = os.path.expanduser("~/.claude/r-okm/logs")
PERMISSION_LOG = os.path.join(LOG_DIR, "permission-requests.jsonl")
SETTINGS_FILE = os.path.expanduser("~/.claude/settings.json")
HOME_DIR = os.path.expanduser("~")

_INTERPRETERS = frozenset({
    "python3", "python", "node", "ruby", "perl", "bash", "sh", "zsh",
})


def normalize_path(text):
    """Normalize /home/<user>/ to ~/ in rule content."""
    if HOME_DIR != "~":
        return text.replace(HOME_DIR + "/", "~/").replace(HOME_DIR, "~")
    return text


def assess_wildcard_risk(wildcard):
    """Assess security risk of a wildcard pattern. Returns high/medium/low."""
    prefix = wildcard.rstrip("*").strip()
    if not prefix:
        return "high"
    parts = prefix.split()
    cmd = parts[0]
    # Interpreter + wildcard args → arbitrary code execution
    if cmd in _INTERPRETERS:
        # Scoped to specific path is lower risk
        if len(parts) >= 2 and "/" in parts[-1]:
            return "low"
        return "high"
    # Inline code flags
    if len(parts) >= 2 and parts[1] == "-c":
        return "high"
    # Path-scoped wildcard
    if "/" in prefix:
        return "low"
    return "medium"


def load_permission_requests(since=None):
    entries = []
    if not os.path.exists(PERMISSION_LOG):
        return entries
    with open(PERMISSION_LOG) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if since and entry.get("timestamp", "") < since:
                continue
            entries.append(entry)
    return entries


def load_existing_rules():
    allow_rules = set()
    deny_rules = set()
    if not os.path.exists(SETTINGS_FILE):
        return allow_rules, deny_rules
    try:
        with open(SETTINGS_FILE) as f:
            settings = json.load(f)
        perms = settings.get("permissions", {})
        allow_rules = set(perms.get("allow", []))
        deny_rules = set(perms.get("deny", []))
    except (json.JSONDecodeError, OSError):
        pass
    return allow_rules, deny_rules


def build_rule_string(tool_name, rule_content):
    """Construct settings.json-compatible rule string."""
    if rule_content:
        return f"{tool_name}({rule_content})"
    return tool_name


def extract_suggestions(entries):
    """Extract and count permission suggestions grouped by (behavior, rule_string).

    Returns:
        counter: Counter keyed by (behavior, rule_str)
        examples: dict of (behavior, rule_str) -> list of tool_input_summary samples
        rule_content_map: dict of (behavior, toolName) -> set of raw ruleContent strings
        timestamps: dict of (behavior, rule_str) -> {"first_seen": str, "last_seen": str}
    """
    counter = Counter()
    examples = {}
    rule_content_map = defaultdict(set)
    timestamps = {}

    for entry in entries:
        suggestions = entry.get("permission_suggestions") or []
        tool_summary = entry.get("tool_input_summary", {})
        ts = entry.get("timestamp", "")

        for suggestion in suggestions:
            behavior = suggestion.get("behavior", "allow")
            rules = suggestion.get("rules") or []
            for rule in rules:
                tool_name = rule.get("toolName", "")
                rule_content = normalize_path(rule.get("ruleContent", ""))
                rule_str = build_rule_string(tool_name, rule_content)
                key = (behavior, rule_str)
                counter[key] += 1
                if key not in examples:
                    examples[key] = []
                if len(examples[key]) < 3:
                    examples[key].append(tool_summary)
                if ts:
                    if key not in timestamps:
                        timestamps[key] = {"first_seen": ts, "last_seen": ts}
                    else:
                        if ts < timestamps[key]["first_seen"]:
                            timestamps[key]["first_seen"] = ts
                        if ts > timestamps[key]["last_seen"]:
                            timestamps[key]["last_seen"] = ts
                if rule_content:
                    rule_content_map[(behavior, tool_name)].add(rule_content)

    return counter, examples, rule_content_map, timestamps


def find_wildcard_groups(rule_contents):
    """Find common prefixes that can consolidate multiple ruleContents into wildcards.

    Args:
        rule_contents: list of ruleContent strings (same behavior + toolName group)

    Returns:
        list of (wildcard_prefix, covered_ruleContents) sorted by coverage descending
    """
    if len(rule_contents) < 2:
        return []

    # Build prefix -> covered ruleContents mapping
    prefix_to_rules = defaultdict(set)
    for rc in rule_contents:
        for i, ch in enumerate(rc):
            if ch in ('/', ' '):
                prefix = rc[:i + 1]
                prefix_to_rules[prefix].add(rc)

    # Keep only prefixes covering 2+ rules
    viable = {p: rules for p, rules in prefix_to_rules.items() if len(rules) >= 2}
    if not viable:
        return []

    # Remove redundant prefixes: if two prefixes cover the exact same set,
    # keep only the longest (most specific) one
    by_coverage = defaultdict(list)
    for prefix, rules in viable.items():
        by_coverage[frozenset(rules)].append(prefix)

    result = {}
    for rule_set, prefixes in by_coverage.items():
        longest = max(prefixes, key=len)
        result[longest] = rule_set

    # Sort by coverage count descending, then prefix length descending
    sorted_groups = sorted(result.items(), key=lambda x: (-len(x[1]), -len(x[0])))
    return [(prefix + "*", set(rules)) for prefix, rules in sorted_groups]


def format_tool_summary(summary):
    """Convert tool_input_summary dict to a readable string."""
    if not summary:
        return ""
    if "command" in summary:
        return summary["command"]
    if "file_path" in summary:
        return summary["file_path"]
    if "url" in summary:
        return summary["url"]
    if "query" in summary:
        return summary["query"]
    if "pattern" in summary:
        parts = [f"pattern={summary['pattern']}"]
        if summary.get("path"):
            parts.append(f"path={summary['path']}")
        return " ".join(parts)
    if "raw" in summary:
        return summary["raw"]
    return str(summary)


def check_status(rule_str, allow_rules, deny_rules):
    if rule_str in allow_rules:
        return "ALLOWED"
    if rule_str in deny_rules:
        return "DENIED"
    return "NEW"


def _parse_rule(rule_str):
    """Parse 'ToolName(content)' into (tool_name, content). Returns (rule_str, '') if no parens."""
    paren = rule_str.find("(")
    if paren != -1 and rule_str.endswith(")"):
        return rule_str[:paren], rule_str[paren + 1:-1]
    return rule_str, ""


def _dedup_subsumed_wildcards(output_rules):
    """Remove wildcards that are subsumed by a broader wildcard for the same tool."""
    # Group wildcard rules by tool name
    tool_wildcards = defaultdict(list)
    for rule in output_rules:
        paren = rule.find("(")
        if paren == -1 or not rule.endswith(")"):
            continue
        tn = rule[:paren]
        content = rule[paren + 1:-1]
        if content.endswith("*"):
            tool_wildcards[tn].append(content)

    subsumed = set()
    for tn, wildcards in tool_wildcards.items():
        wildcards.sort(key=len)  # broadest (shortest prefix) first
        for i, w1 in enumerate(wildcards):
            p1 = w1[:-1]  # strip trailing *
            for w2 in wildcards[i + 1:]:
                p2 = w2[:-1]
                if p2.startswith(p1):
                    subsumed.add(build_rule_string(tn, w2))

    return output_rules - subsumed


def build_wildcard_groups_for_rules(rule_strs):
    """Build wildcard groups from a list of rule strings like 'ToolName(content)'.

    Returns (output_rules, wildcard_details):
        output_rules: set of consolidated rule strings (subsumed wildcards removed)
        wildcard_details: list of dicts with wildcard_rule, covers, count, risk_level
    """
    rc_map = defaultdict(set)
    for rule_str in rule_strs:
        paren = rule_str.find("(")
        if paren != -1 and rule_str.endswith(")"):
            tool_name = rule_str[:paren]
            rc = rule_str[paren + 1:-1]
            if rc:
                rc_map[tool_name].add(rc)
        else:
            rc_map[rule_str].add("")

    output_rules = set()
    covered_rules = set()
    wildcard_details = []
    for tool_name, rcs in rc_map.items():
        groups = find_wildcard_groups(list(rcs))
        for wildcard, covered in groups:
            wc_rule = build_rule_string(tool_name, wildcard)
            output_rules.add(wc_rule)
            wildcard_details.append({
                "wildcard_rule": wc_rule,
                "covers": sorted(covered),
                "count": len(covered),
                "risk_level": assess_wildcard_risk(wildcard),
            })
            for rc in covered:
                covered_rules.add(build_rule_string(tool_name, rc))

    # Add ungrouped rules
    for rule_str in rule_strs:
        if rule_str not in covered_rules:
            output_rules.add(rule_str)

    # Remove wildcards subsumed by broader ones
    output_rules = _dedup_subsumed_wildcards(output_rules)

    return output_rules, wildcard_details


def analyze_mode_a(entries, top_n, output_mode):
    allow_rules, deny_rules = load_existing_rules()
    counter, examples, rule_content_map, timestamps = extract_suggestions(entries)

    if not counter:
        print("No permission suggestions found in logs.")
        return

    results = []
    for (behavior, rule_str), count in counter.most_common(top_n):
        status = check_status(rule_str, allow_rules, deny_rules)
        ts = timestamps.get((behavior, rule_str), {})
        results.append({
            "behavior": behavior,
            "rule": rule_str,
            "count": count,
            "status": status,
            "actual_inputs": [format_tool_summary(s) for s in examples.get((behavior, rule_str), [])],
            "first_seen": ts.get("first_seen", ""),
            "last_seen": ts.get("last_seen", ""),
        })

    if output_mode == "json":
        # Rich JSON for LLM analysis

        # Build all wildcard groups from full data (before top_n) for context
        all_wc = []
        for (behavior, tool_name), rcs in rule_content_map.items():
            groups = find_wildcard_groups(list(rcs))
            for wildcard, covered in groups:
                all_wc.append({
                    "wildcard_rule": build_rule_string(tool_name, wildcard),
                    "behavior": behavior,
                    "covers": sorted(covered),
                    "count": len(covered),
                    "risk_level": assess_wildcard_risk(wildcard),
                })

        # Build coverage map: rule_str -> list of wildcard rules that cover it
        coverage_map = defaultdict(list)
        for wc in all_wc:
            tn, wc_content = _parse_rule(wc["wildcard_rule"])
            wc_prefix = wc_content.rstrip("*")
            for rc in wc["covers"]:
                coverage_map[build_rule_string(tn, rc)].append(wc["wildcard_rule"])

        suggestions_out = []
        for r in results:
            s = {
                "rule": r["rule"],
                "count": r["count"],
                "behavior": r["behavior"],
                "status": r["status"],
                "actual_inputs": r["actual_inputs"],
                "first_seen": r["first_seen"],
                "last_seen": r["last_seen"],
            }
            covered_by = coverage_map.get(r["rule"])
            if covered_by:
                s["covered_by_wildcards"] = covered_by
            suggestions_out.append(s)

        output = {
            "existing_rules": {
                "allow": sorted(allow_rules),
                "deny": sorted(deny_rules),
            },
            "suggestions": suggestions_out,
            "wildcard_groups": all_wc,
        }
        print(json.dumps(output, indent=2, ensure_ascii=False))
        return

    if output_mode == "settings":
        # Flat array for settings.json (NEW + allow only, wildcards applied)
        new_allow_rules = [r["rule"] for r in results
                           if r["status"] == "NEW" and r["behavior"] == "allow"]
        output_rules, _ = build_wildcard_groups_for_rules(new_allow_rules)
        print(json.dumps(sorted(output_rules), indent=2))
        return

    # Table output
    print("Permission Request Analysis")
    print("=" * 70)
    print(f"  Total log entries : {len(entries)}")
    print(f"  Unique suggestions: {len(counter)}")
    print()

    max_rule = min(max((len(r["rule"]) for r in results), default=20), 55)
    hdr = f"  {'Count':>5}  {'Behavior':<6}  {'Rule':<{max_rule}}  Status"
    print(hdr)
    print(f"  {'-----':>5}  {'------':<6}  {'-' * max_rule}  ------")

    for r in results:
        rule_disp = r["rule"]
        if len(rule_disp) > max_rule:
            rule_disp = rule_disp[: max_rule - 3] + "..."
        print(
            f"  {r['count']:>5}  {r['behavior']:<6}  {rule_disp:<{max_rule}}  {r['status']}"
        )

    new_allow = [r["rule"] for r in results
                 if r["status"] == "NEW" and r["behavior"] == "allow"]
    if new_allow:
        print(f"\nSuggested allow additions (use --settings for copy-paste format):")
        print("-" * 50)
        for rule in new_allow:
            print(f'  "{rule}"')

    # Wildcard suggestions (scope: all data before top_n)
    all_wildcard_groups = []
    for (behavior, tool_name), rcs in rule_content_map.items():
        groups = find_wildcard_groups(list(rcs))
        for wildcard, covered in groups:
            all_wildcard_groups.append((behavior, tool_name, wildcard, covered))

    if all_wildcard_groups:
        print(f"\nSuggested wildcard rules:")
        print("-" * 50)
        for behavior, tool_name, wildcard, covered in all_wildcard_groups:
            wc_rule = build_rule_string(tool_name, wildcard)
            risk = assess_wildcard_risk(wildcard)
            risk_label = f" [RISK:{risk.upper()}]" if risk != "low" else ""
            print(f"  {wc_rule:<55} ({len(covered)} rules){risk_label}")
            for rc in sorted(covered):
                print(f"    - {rc}")


def main():
    parser = argparse.ArgumentParser(
        description="Analyze Claude Code permission request logs",
        epilog=(
            "Workflow:\n"
            "  1. %(prog)s              # scan table overview\n"
            "  2. %(prog)s --json       # pass to LLM for analysis\n"
            "  3. %(prog)s --settings   # paste approved rules into settings.json\n"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--since", help="Filter from date (YYYY-MM-DD)")
    parser.add_argument("--top", type=int, default=20, help="Top N (default: 20)")
    parser.add_argument("--full", action="store_true", help=argparse.SUPPRESS)
    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument("--json", action="store_true",
                              help="Rich JSON output for LLM analysis")
    output_group.add_argument("--settings", action="store_true",
                              help="Flat JSON array for settings.json permissions.allow")
    args = parser.parse_args()

    if args.full:
        tool_use_log = os.path.join(LOG_DIR, "tool-use.jsonl")
        if not os.path.exists(tool_use_log):
            print("Error: tool-use.jsonl not found.", file=sys.stderr)
            print("Mode B requires the PreToolUse hook (log-tool-use.sh).",
                  file=sys.stderr)
            sys.exit(1)
        print("Mode B (--full) is not yet implemented.", file=sys.stderr)
        sys.exit(1)

    since = None
    if args.since:
        try:
            datetime.strptime(args.since, "%Y-%m-%d")
            since = args.since + "T00:00:00Z"
        except ValueError:
            print(f"Error: Invalid date: {args.since} (YYYY-MM-DD)", file=sys.stderr)
            sys.exit(1)

    output_mode = "json" if args.json else "settings" if args.settings else "table"

    entries = load_permission_requests(since=since)
    analyze_mode_a(entries, args.top, output_mode)


if __name__ == "__main__":
    main()

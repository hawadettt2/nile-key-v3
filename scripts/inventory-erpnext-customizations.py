#!/usr/bin/env python3
import argparse
import ast
import json
from pathlib import Path


def load_ast(path):
    return ast.parse(path.read_text(encoding="utf-8"), filename=str(path))


def literal(value):
    if value is None:
        return None

    if isinstance(value, ast.Constant):
        return value.value

    if isinstance(value, (ast.List, ast.Tuple, ast.Set)):
        return [literal(item) for item in value.elts]

    if isinstance(value, ast.Dict):
        return {
            literal(key): literal(item)
            for key, item in zip(value.keys, value.values)
        }

    if isinstance(value, ast.UnaryOp) and isinstance(value.op, ast.USub):
        operand = literal(value.operand)
        return -operand if isinstance(operand, (int, float)) else None

    if isinstance(value, ast.Call):
        if value.args:
            return literal(value.args[0])
        return None

    try:
        return ast.literal_eval(value)
    except Exception:
        return None


def count_value(value):
    if isinstance(value, dict):
        return sum(count_value(v) for v in value.values())
    if isinstance(value, (list, tuple, set)):
        return sum(count_value(v) for v in value)
    return 1


def stringify_keys(value):
    if isinstance(value, dict):
        return {
            (", ".join(key) if isinstance(key, tuple) else str(key)): stringify_keys(item)
            for key, item in value.items()
        }
    if isinstance(value, list):
        return [stringify_keys(item) for item in value]
    if isinstance(value, tuple):
        return [stringify_keys(item) for item in value]
    return value


def summarize_hooks(tree):
    hooks = {}
    hook_sections = {}

    for node in tree.body:
        if not isinstance(node, ast.Assign):
            continue
        for target in node.targets:
            if not isinstance(target, ast.Name):
                continue
            name = target.id
            value = literal(node.value)
            hooks[name] = value
            hook_sections[name] = count_value(value)

    return hooks, hook_sections


def summarize_doc_events(value):
    if not isinstance(value, dict):
        return {}

    result = {}
    for doctype, events in value.items():
        if isinstance(events, dict):
            result[doctype] = {event: count_value(handler) for event, handler in events.items()}
        else:
            result[doctype] = {"handlers": count_value(events)}
    return result


def summarize_scheduler_events(value):
    if not isinstance(value, dict):
        return {}

    result = {}
    for frequency, handlers in value.items():
        result[frequency] = count_value(handlers)
    return result


def summarize_website_routes(value):
    if not isinstance(value, list):
        return []

    routes = []
    for route in value:
        if isinstance(route, dict):
            routes.append({
                "from_route": route.get("from_route"),
                "to_route": route.get("to_route"),
                "doctype": route.get("doctype"),
            })
    return routes


def find_fixture_files(repo_root, app_path):
    fixtures = []
    for path in app_path.rglob("*.json"):
        if "fixtures" in path.parts:
            fixtures.append(path.relative_to(repo_root).as_posix())
    return sorted(fixtures)


def find_candidate_files(repo_root, app_path, keywords):
    candidates = []
    compiled = [keyword.lower() for keyword in keywords]

    for path in app_path.rglob("*"):
        if not path.is_file() or path.suffix not in {".py", ".js", ".json", ".html"}:
            continue

        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue

        matches = [keyword for keyword in compiled if keyword in text.lower()]
        if matches:
            candidates.append({
                "path": path.relative_to(repo_root).as_posix(),
                "matched_keywords": sorted(set(matches)),
            })

    return candidates


def build_report(repo_root, app_path, keywords):
    hooks_path = app_path / "hooks.py"

    if not hooks_path.exists():
        raise SystemExit(f"[error] hooks.py not found: {hooks_path}")

    tree = load_ast(hooks_path)
    hooks, hook_sections = summarize_hooks(tree)

    report = {
        "repo_root": ".",
        "app_path": str(app_path.relative_to(repo_root)),
        "hook_sections": stringify_keys(hook_sections),
        "doc_events": stringify_keys(summarize_doc_events(hooks.get("doc_events"))),
        "scheduler_events": stringify_keys(summarize_scheduler_events(hooks.get("scheduler_events"))),
        "website_route_rules": summarize_website_routes(hooks.get("website_route_rules")),
        "fixtures": find_fixture_files(repo_root, app_path),
        "candidate_customization_files": find_candidate_files(repo_root, app_path, keywords),
    }

    return report


def main():
    parser = argparse.ArgumentParser(description="Inventory ERPNext hooks and customization candidates.")
    parser.add_argument("--repo-root", default=".", help="Repository root path.")
    parser.add_argument("--app-path", default="erpnext", help="Path to ERPNext app directory.")
    parser.add_argument("--output", help="Optional JSON output file.")
    parser.add_argument(
        "--keywords",
        default="nile,export,shipment,acid,customs,logistics,government,audit",
        help="Comma-separated keywords used to identify candidate customization files.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    app_path = Path(args.app_path)
    if not app_path.is_absolute():
        app_path = (repo_root / app_path).resolve()

    keywords = [item.strip() for item in args.keywords.split(",") if item.strip()]
    report = build_report(repo_root, app_path, keywords)

    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)

    if args.output:
        output_path = Path(args.output)
        if not output_path.is_absolute():
            output_path = repo_root / output_path
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered + "\n", encoding="utf-8")
        print(f"[ok] Wrote customization inventory to: {output_path}")
    else:
        print(rendered)


if __name__ == "__main__":
    main()

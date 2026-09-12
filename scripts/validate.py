"""Sanity checks for the marketplace, plugin manifest, MCP config and skills."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []


def load(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError) as exc:
        errors.append(f"{path.relative_to(ROOT)}: {exc}")
        return {}


marketplace = load(ROOT / ".claude-plugin" / "marketplace.json")
for key in ("name", "owner", "plugins"):
    if key not in marketplace:
        errors.append(f"marketplace.json: missing {key}")

for entry in marketplace.get("plugins", []):
    src = ROOT / entry.get("source", "")
    manifest = load(src / ".claude-plugin" / "plugin.json")
    if manifest.get("name") != entry.get("name"):
        errors.append(f"{entry.get('name')}: plugin.json name does not match marketplace entry")
    if manifest.get("version") != entry.get("version"):
        errors.append(f"{entry.get('name')}: version differs between plugin.json and marketplace")

    mcp = load(src / ".mcp.json")
    for name, server in mcp.get("mcpServers", {}).items():
        if server.get("command") != "uvx":
            errors.append(f"{name}: expected uvx launcher")
        args = server.get("args", [])
        pinned = any(re.match(r"git\+https://.+@v\d+\.\d+\.\d+$", a) for a in args)
        if not pinned:
            errors.append(f"{name}: MCP server source must be pinned to a release tag")

    skills = sorted((src / "skills").glob("*/SKILL.md"))
    if not skills:
        errors.append(f"{entry.get('name')}: no skills found")
    for skill in skills:
        text = skill.read_text()
        m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
        if not m:
            errors.append(f"{skill.relative_to(ROOT)}: missing frontmatter")
            continue
        fm = m.group(1)
        name = re.search(r"^name:\s*(\S+)", fm, re.M)
        if not name or name.group(1) != skill.parent.name:
            errors.append(f"{skill.relative_to(ROOT)}: frontmatter name must equal directory name")
        if not re.search(r"^description:\s*\S", fm, re.M):
            errors.append(f"{skill.relative_to(ROOT)}: missing description")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print("ok")

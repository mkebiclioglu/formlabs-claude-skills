"""Sanity checks for the marketplace, plugin manifest, MCP config and skills."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []
TARBALL = re.compile(r"^formlabs-local-mcp@\d+\.\d+\.\d+$")  # exact npm version, no ranges


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

pinned_urls: set[str] = set()
for entry in marketplace.get("plugins", []):
    src = ROOT / entry.get("source", "")
    manifest = load(src / ".claude-plugin" / "plugin.json")
    if manifest.get("name") != entry.get("name"):
        errors.append(f"{entry.get('name')}: plugin.json name does not match marketplace entry")
    if manifest.get("version") != entry.get("version"):
        errors.append(f"{entry.get('name')}: version differs between plugin.json and marketplace")

    mcp = load(src / ".mcp.json")
    for name, server in mcp.get("mcpServers", {}).items():
        if server.get("command") != "npx":
            errors.append(f"{name}: expected npx launcher")
        args = server.get("args", [])
        if args[:1] != ["-y"] or len(args) < 2 or not TARBALL.match(args[1]):
            errors.append(f"{name}: MCP server must be `npx -y formlabs-local-mcp@<exact version>`")
        else:
            pinned_urls.add(args[1])

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

# The install scripts and docs must pin the same npm version as the plugin.
for f in ["docs/install.sh", "docs/install.ps1", "docs/index.html", "docs/demo.html"]:
    text = (ROOT / f).read_text()
    for url in pinned_urls:
        if url not in text:
            errors.append(f"{f}: does not reference the pinned package {url}")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print("ok")

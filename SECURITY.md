# Security

## Reporting a vulnerability

Please do not open a public issue for security problems. Use GitHub's private
reporting: **Security → Report a vulnerability** on this repository
(https://github.com/mkebiclioglu/formlabs-claude-skills/security/advisories/new).
You will get a reply within a few days.

Problems in the MCP server itself (tools, path guards, the PreFormServer
installer, remote mode) belong to
[formlabs-local-mcp](https://github.com/mkebiclioglu/formlabs-local-mcp/security/advisories/new).
Bugs in PreFormServer belong to Formlabs (https://formlabs.com/security/).

## What this repository controls

- The plugin manifest and the exact npm version of `formlabs-local-mcp` it runs
  (`plugins/formlabs/.mcp.json`). It is always an exact version, never a range;
  CI fails otherwise.
- The three skills (Markdown instructions the model follows). They never contain
  credentials and tell the model to ask before installing or printing.
- The one-line install scripts (`docs/install.sh`, `docs/install.ps1`), served
  from GitHub Pages over HTTPS. They install nothing system-wide, use no sudo,
  and run the same signature-checked PreFormServer installer the plugin uses.

Changes to `main` go through pull requests only, GitHub Actions are pinned to
commit SHAs, and secret scanning with push protection is on.

## Verifying what you install

The plugin runs `npx -y formlabs-local-mcp@<version>`. That package is published
from CI with npm provenance; see the
[server's SECURITY.md](https://github.com/mkebiclioglu/formlabs-local-mcp/blob/main/SECURITY.md)
for how to check it. PreFormServer is downloaded only from
`downloads.formlabs.com` and its code signature is verified before install.

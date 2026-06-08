# formlabs-claude-skills

Claude Code skills that drive a Formlabs printer end-to-end from a chat prompt,
using the [`formlabs-local-mcp`](https://github.com/mkebiclioglu/formlabs-local-mcp)
MCP server.

> "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as
> `~/jobs/bracket.form`."

Drop this repo into a project (or clone it as a standalone), install the MCP
server, and Claude Code will pick the skills up automatically.

## Included skills

| Skill | What it does |
|---|---|
| `/formlabs-print` | End-to-end: prep + send to a printer. Confirms before the print kicks off. |
| `/formlabs-prep` | Same prep pipeline, but saves a `.form` file instead of printing. Use for review or batch prep. |

Both skills follow the same import → auto-orient → auto-support → auto-layout /
auto-pack → validate → estimate flow and surface every cost and warning before
doing anything irreversible.

## Install

### 1. Install PreFormServer

Download the PreFormServer executable from the
[Formlabs API downloads page](https://support.formlabs.com/s/article/Formlabs-API-downloads-and-release-notes)
and note the absolute path to the binary, e.g.
`/Applications/PreFormServer.app/Contents/MacOS/PreFormServer`.

### 2. Install the MCP server

Clone and install [`formlabs-local-mcp`](https://github.com/mkebiclioglu/formlabs-local-mcp):

```bash
git clone https://github.com/mkebiclioglu/formlabs-local-mcp.git
cd formlabs-local-mcp
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

The full setup (including MCP client config) lives in the MCP server's README.

### 3. Register the MCP server with Claude Code

```bash
claude mcp add formlabs \
  -s user \
  -e PREFORM_SERVER_PATH=/path/to/PreFormServer.app/Contents/MacOS/PreFormServer \
  -- /absolute/path/to/formlabs-local-mcp/.venv/bin/formlabs-local-mcp
```

Verify with `claude mcp list` — you should see `formlabs: ✓ Connected`.

### 4. Drop in the skills

```bash
git clone https://github.com/mkebiclioglu/formlabs-claude-skills.git
mkdir -p ~/.claude/skills
cp -r formlabs-claude-skills/.claude/skills/* ~/.claude/skills/
```

Start a fresh Claude Code window. `/formlabs-print` and `/formlabs-prep` will
be available.

## Example prompts

- "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as `~/jobs/bracket.form`."
- "Pack these five parts onto my Fuse 1+ and send to printer `Fuse-Loud-Otter`."
- "What materials are available for the Form 4?"
- "Discover printers on my network, then send `~/parts/case.stl` to the first one you find."

## How it works

```
You
 │
 ▼
Claude Code  ──►  /formlabs-print  (this skill — workflow knowledge)
                       │
                       ▼
                  MCP tools  (formlabs-local-mcp — typed API surface)
                       │
                       ▼
                  PreFormServer  (Formlabs binary, HTTP API on localhost)
                       │
                       ▼
                  Your Formlabs printer
```

The skills make the **decisions** (which material? SLA or SLS? confirm or just
go?) and the MCP server executes them as discrete tool calls.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `health_check` fails | PreFormServer not running, or `PREFORM_SERVER_PATH` points to the wrong binary. |
| `INVALID_MATERIAL` error | Call `list_materials` for the printer to see valid `material_code` values. |
| `print_to_printer` returns "printer not found" | Run `discover_devices`, or pass the printer's local IP directly. |
| Remote printing fails with 401 | Call `login` first with your Formlabs Web Services credentials. |

## Companion repo

- [`formlabs-local-mcp`](https://github.com/mkebiclioglu/formlabs-local-mcp) — the MCP server these skills depend on.

## License

MIT. Not affiliated with Formlabs Inc.

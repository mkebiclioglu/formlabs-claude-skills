# formlabs-claude-skills

Print on your Formlabs printer from Claude Code.

> "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as `~/jobs/bracket.form`."

This repo is a Claude Code **plugin marketplace**. The `formlabs` plugin bundles the
[formlabs-local-mcp](https://github.com/mkebiclioglu/formlabs-local-mcp) server and
three skills, so one install gives Claude everything it needs.

**Docs and step-by-step install:** https://mkebiclioglu.github.io/formlabs-claude-skills/

## Install

1. Install [uv](https://docs.astral.sh/uv/) (`brew install uv`).
2. Download [PreFormServer](https://formlabs.com/support/Formlabs-API-downloads-and-release-notes)
   and move `PreFormServer.app` into `/Applications`.
3. In Claude Code:

```
/plugin marketplace add mkebiclioglu/formlabs-claude-skills
/plugin install formlabs@formlabs-claude-skills
```

Then run `/formlabs:setup` to confirm everything is wired up.

## Skills

| Skill | What it does |
|---|---|
| `/formlabs:setup` | Checks uv, PreFormServer and the MCP server; tells you exactly what to fix. |
| `/formlabs:prep` | Import, orient, support, lay out, validate, estimate, save a `.form` file plus a preview PNG. |
| `/formlabs:print` | Same pipeline, then uploads to your printer after you confirm. |

Claude also picks these up on its own when you ask in plain language.

## Layout

```
.claude-plugin/marketplace.json   the marketplace (lists the plugin below)
plugins/formlabs/
  .claude-plugin/plugin.json      plugin manifest
  .mcp.json                       launches formlabs-local-mcp with uvx, pinned to a release
  skills/{setup,prep,print}/      the skills
docs/                             GitHub Pages site
scripts/validate.py               CI checks for manifests and skills
```

## License

MIT. Not affiliated with or endorsed by Formlabs Inc.

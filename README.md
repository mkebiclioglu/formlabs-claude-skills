# formlabs-claude-skills

Print on your Formlabs printer from Claude Code.

> "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as `~/jobs/bracket.form`."

This repo is a Claude Code **plugin marketplace**. The `formlabs` plugin bundles the
[formlabs-local-mcp](https://github.com/mkebiclioglu/formlabs-local-mcp) server and
three skills, so one install gives Claude everything it needs, PreFormServer
included.

**Docs:** https://mkebiclioglu.github.io/formlabs-claude-skills/

## Install

Needs Node.js 20+ and Claude Code. One line:

```bash
curl -fsSL https://mkebiclioglu.github.io/formlabs-claude-skills/install.sh | sh
```

Windows: `irm https://mkebiclioglu.github.io/formlabs-claude-skills/install.ps1 | iex`

Or inside Claude Code:

```
/plugin marketplace add mkebiclioglu/formlabs-claude-skills
/plugin install formlabs@formlabs-claude-skills
/formlabs:setup
```

`/formlabs:setup` installs PreFormServer for you (downloaded from Formlabs,
signature-checked) after asking.

## Skills

| Skill | What it does |
|---|---|
| `/formlabs:setup` | Checks Node, the MCP server and PreFormServer; installs PreFormServer with your OK. |
| `/formlabs:prep` | Import, orient, support, lay out, validate, drain holes, estimate, save a `.form` plus a preview PNG. |
| `/formlabs:print` | Same pipeline, then uploads to your printer after you confirm. |

Claude also picks these up on its own when you ask in plain language.

## Layout

```
.claude-plugin/marketplace.json   the marketplace (lists the plugin below)
plugins/formlabs/
  .claude-plugin/plugin.json      plugin manifest
  .mcp.json                       runs formlabs-local-mcp with npx, pinned to a release tarball
  skills/{setup,prep,print}/      the skills
docs/                             GitHub Pages site and the one-line installers
scripts/validate.py               CI checks for manifests, skills and pinned versions
```

## License

MIT. Not affiliated with or endorsed by Formlabs Inc.

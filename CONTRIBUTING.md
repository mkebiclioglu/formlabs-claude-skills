# Contributing

## Try changes locally

```bash
claude --plugin-dir plugins/formlabs
```

That loads the plugin from the working tree, MCP server included. Skills show up
as `/formlabs:<name>`.

## Checks

```bash
python3 scripts/validate.py
claude plugin validate .
claude plugin validate plugins/formlabs
```

CI runs the first one on every push and PR.

## Writing skills

- `name` in the frontmatter must equal the directory name.
- The `description` decides when Claude invokes the skill unprompted, so say
  *when* it applies, not just what it does.
- Capture judgment, not tool documentation: which layout tool for SLA versus
  SLS, when to stop and ask, what to confirm before an irreversible step.
- Keep confirmations for the destructive steps only (sending a print,
  overwriting a file). Ask for missing inputs in one batched question.

## Bumping the MCP server

`plugins/formlabs/.mcp.json` pins a release tag of formlabs-local-mcp. Update the
tag, bump `version` in both `plugin.json` and `marketplace.json`, and run the
checks above. Users get the new version on their next `/plugin update`.

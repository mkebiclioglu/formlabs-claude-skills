# Contributing

Thanks for helping. The most useful contributions here are not code: they are
transcripts of the skills doing something wrong, and better wording for the
skills so they do it right next time.

## Ways to help

- **Report a bad run.** If `/formlabs:prep` or `/formlabs:print` asked the
  wrong question, picked the wrong tool, or skipped a check, open a
  [bug report](https://github.com/mkebiclioglu/formlabs-claude-skills/issues/new/choose)
  with the transcript. That is the raw material for improving a skill.
- **Share what you printed** in
  [Show and tell](https://github.com/mkebiclioglu/formlabs-claude-skills/discussions/categories/show-and-tell):
  printer, material, what worked, what did not.
- **Propose a skill.** A workflow you repeat by hand in PreForm (a dental
  batch, a Fuse packing routine, a "reprint last job" flow) is a good candidate.
  Open an Idea in Discussions first.
- **Docs.** Fix anything unclear in `README.md`, `docs/docs.html` (reference) or
  `docs/index.html` (the landing page and demo).
- **New tools** live in the server repo, [formlabs-local-mcp](https://github.com/mkebiclioglu/formlabs-local-mcp).

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

CI runs the first one on every push and PR; it must pass before merge.

## Writing skills

- `name` in the frontmatter must equal the directory name.
- The `description` decides when Claude invokes the skill unprompted, so say
  *when* it applies, not just what it does.
- Capture judgment, not tool documentation: which layout tool for SLA versus
  SLS, when to stop and ask, what to confirm before an irreversible step.
- Keep confirmations for the destructive steps only (sending a print,
  overwriting a file). Ask for missing inputs in one batched question.
- Test a change by running the skill on a real file and reading the transcript.
  Paste the relevant part in the PR.

## Pull requests

Branch from `main`, one change per PR, fill in the template. `main` cannot be
pushed to directly; a maintainer merges after CI passes.

## Security issues

See [SECURITY.md](SECURITY.md).

## Bumping the MCP server (maintainers)

`plugins/formlabs/.mcp.json` pins an exact npm version of formlabs-local-mcp, and so
do `docs/install.sh`, `docs/install.ps1`, `docs/index.html` (the landing page) and
`docs/docs.html` (the reference docs).
Update all of them to the new version, bump `version` in both `plugin.json` and
`marketplace.json`, and run the checks above (the validator fails if they disagree).
Users get the new version on their next `/plugin update`.

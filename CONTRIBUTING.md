# Contributing

Skills are short Markdown files — easy to add or tweak.

## Where the skills live

Each skill is a directory under `.claude/skills/` with a `SKILL.md` file
containing YAML frontmatter (`name`, `description`) and the skill body.
Claude Code reads the description to decide when to invoke the skill, so
make it specific about *when* the skill should apply.

## Authoring tips

- **Lead with a precondition.** Both existing skills start with
  `health_check`; if the MCP server isn't reachable, stop early.
- **Surface decisions, not steps.** A skill is most useful when it captures
  judgment the model wouldn't otherwise have (e.g. SLA → `auto_layout`,
  SLS → `auto_pack`; default to REPAIR on imports).
- **Avoid TaskCreate for short linear flows.** It's overhead and clutters
  the response.
- **Confirm before destructive actions.** Saving over an existing `.form`,
  sending a print, etc. — always confirm.

## Testing

Drop the changed `.claude/skills/<name>/SKILL.md` into `~/.claude/skills/`,
restart Claude Code, and exercise it with real prompts. There's no
automated harness for skills today.

## Questions vs. bug reports

- [Discussions](https://github.com/mkebiclioglu/formlabs-claude-skills/discussions)
  for open-ended questions, ideas, or show-and-tell.
- [Issues](https://github.com/mkebiclioglu/formlabs-claude-skills/issues)
  for reproducible bugs and concrete feature requests.

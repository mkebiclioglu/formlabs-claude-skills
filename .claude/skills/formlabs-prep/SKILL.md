---
name: formlabs-prep
description: Prepare a Formlabs print scene from one or more STL/OBJ files and save it as a .form file, without sending to a printer. Use when the user wants to set up a print job for review or later printing, but doesn't want it sent to a printer yet. Lower-stakes companion to formlabs-print.
---

# Formlabs print prep (save only)

A non-destructive version of the `formlabs-print` workflow: same preparation
pipeline, but always saves a `.form` file at the end instead of sending to a
printer. Use this when the user wants to inspect the job in PreForm first, or
batch-prepare jobs to print later.

## Required environment

Same as `formlabs-print`: call `health_check` first. If it fails, tell the user
how to install/start the MCP server and stop.

## Required inputs

1. **Model file(s)** — absolute paths.
2. **Printer + material** — same as `formlabs-print`. If the user only says
   something like "for the Form 4", call `list_materials` filtered by
   `machine_type` and ask them to pick a material.
3. **Output `.form` path** — absolute path. If they don't specify, default to
   the model's directory with the same basename and `.form` extension, and
   confirm.

## Workflow

1. `create_scene`
2. `import_model` for each input file
3. `auto_orient`
4. `auto_support`
5. `auto_layout` (SLA) or `auto_pack` (SLS)
6. `get_print_validation` — surface errors/warnings
7. `estimate_print_time` — report
8. `save_form`
9. Optionally `save_screenshot` next to the .form so the user has a preview

Skip the confirmation step before `save_form` if the output path is new; ask
before overwriting an existing file.

## When to use this vs formlabs-print

- The user mentions "save", "prepare", "set up", "draft", "preview" → this skill.
- The user mentions "print", "send to printer", "kick off the job" → use
  `formlabs-print`.
- Ambiguous → ask once which they want.

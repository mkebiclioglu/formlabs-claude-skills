---
name: formlabs-prep
description: Prepare a Formlabs print scene from one or more STL/OBJ files and save it as a .form file, without sending to a printer. Use when the user wants to set up a print job for review or later printing, but doesn't want it sent to a printer yet. Lower-stakes companion to formlabs-print.
---

# Formlabs print prep (save only)

A non-destructive version of the `formlabs-print` workflow: same preparation
pipeline, but always saves a `.form` file at the end instead of sending to a
printer. Use this when the user wants to inspect the job in PreForm first, or
batch-prepare jobs to print later.

## Precondition (always)

**First action: call `health_check`.** If it errors, the `formlabs` MCP server
is not installed or PreFormServer failed to start. Surface the error, link
the user to https://github.com/mkebiclioglu/formlabs-local-mcp, and STOP.

## Required inputs

1. **Model file(s)** — absolute paths.
2. **Printer + material** — same as `formlabs-print`. If the user names a
   printer but no material, call `list_printer_types` to confirm the code,
   then `list_materials` and surface the available materials for that printer
   so they can pick.
3. **Output `.form` path** — absolute path. If they don't specify, default to
   the model's directory with the same basename and `.form` extension, and
   confirm.

## Workflow

1. `health_check` (precondition).
2. `create_scene`.
3. `import_model` for each input file. The server defaults `repair_behavior=REPAIR`
   and `units=MILLIMETERS` — leave them unless the user explicitly says otherwise.
4. `auto_orient`.
5. `auto_support`.
6. `auto_layout` (SLA, `machine_type` starts with `FORM-`) or `auto_pack`
   (SLS, starts with `FS`).
7. `get_print_validation` — surface errors/warnings.
8. **Cup check (SLA only):** call `get_scene` and inspect each model for cups
   / drain-hole warnings. If any are detected, tell the user and offer to
   `add_drain_holes` before saving.
9. `estimate_print_time` — report time and material usage.
10. `save_form` to the chosen path. Skip the confirmation if the path is new;
    ask before overwriting an existing file.
11. Optionally `save_screenshot` to a `.png` next to the `.form` for preview.

## When to use this vs formlabs-print

- User mentions "save", "prepare", "set up", "draft", "preview" → this skill.
- User mentions "print", "send to printer", "kick off the job" → use
  `formlabs-print`.
- Ambiguous → ask once which they want.

## Things to avoid

- **Don't** use TaskCreate for this flow. Short linear pipeline; overhead.
- **Don't** loop retries on `IMPORT_PRODUCED_EMPTY_SCENE` — that error means
  the STL is genuinely malformed and the post-import verification caught it.
  Tell the user, stop, and let them open the file in PreForm to diagnose.
- **Don't** invent `machine_type` or `material_code` values. Use
  `list_printer_types` / `list_materials` to get real values.

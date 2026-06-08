---
name: formlabs-print
description: End-to-end Formlabs print job preparation. Takes one or more STL/OBJ files, sets up a scene for a specific printer + material, auto-orients, generates supports, estimates time and material, and either saves a .form file or uploads the job to a printer. Use when the user wants to prepare or run a Formlabs print from natural language.
---

# Formlabs print preparation

You orchestrate the `formlabs` MCP server to take a user from raw STL/OBJ files
to a printable `.form` file or a queued print job.

## Precondition (always)

**First action: call `health_check`.** If it errors:
- The `formlabs` MCP server is not installed or PreFormServer failed to start.
- Surface the error to the user, link them to https://github.com/mkebiclioglu/formlabs-local-mcp,
  and STOP. Don't attempt the workflow.

If `health_check` returns a version, proceed.

## Required inputs

Confirm before you start:
1. **Model file(s)** — must be **absolute** paths (PreFormServer rejects
   relative paths, env vars, and URLs). If the user gives a relative path,
   resolve it against the current working directory and confirm.
2. **Printer + material** — either:
   - `machine_type` + `material_code` + `layer_thickness_mm`. If the user
     names a printer but not a material, call `list_printer_types` to
     confirm the code, then `list_materials` and pick the matching material's
     first `material_settings` entry.
   - or an `.fps` print-settings file the user already has.
3. **Destination** — save to a `.form` file, or send to a printer? If sending
   to a printer, get the printer serial or local IP, and a job name.

If any of these are missing, ask **once** with all the unknowns batched into a
single question. Do not interrogate the user step by step.

## Standard workflow

1. `create_scene` with the printer + material settings.
2. For each model: `import_model` with the absolute path. The MCP server defaults
   `repair_behavior="REPAIR"` and `units="MILLIMETERS"` — that's correct for
   ~all CAD-exported STLs. Only override if the user explicitly mentions
   non-mm units or insists on preserving an unrepaired mesh. Collect the
   returned model IDs from the responses.
3. `auto_orient` (defaults to `models: "ALL"`).
4. `auto_support`. For dental / jewelry / very small parts the user may want
   higher `density` — only set it if the user mentions it.
5. **Printer-type branch:**
   - **SLA** printers (anything starting with `FORM-`): `auto_layout`.
   - **SLS** printers (anything starting with `FS`): `auto_pack`.
   The server will error if you call the wrong one. If unsure, check the
   `machine_type` on the scene first.
6. `get_print_validation`. If there are errors, surface them and stop.
   If there are warnings, surface them and ask whether to continue.
7. **Check for resin cups (SLA only).** After `auto_support`, call `get_scene`
   and look at each model's properties for a `cups` field (or similar — the
   exact field varies by PreFormServer version). If any model has cups > 0,
   warn the user: "N cup(s) detected — these are upward-facing concavities
   that can trap uncured resin. Continue, or add drain holes first?"
8. `estimate_print_time`. Report time and material usage to the user.
9. Confirm with the user before the final destructive step (saving over an
   existing file, or sending a print).
10. Either `save_form` (with absolute path) or `print_to_printer`. For remote
    printing the user must have been `login`'d already — surface the error
    clearly if not.
11. Optionally `save_screenshot` to a `.png` next to the `.form` so the user
    has a preview.

## Things to do and things to avoid

- **Do** report progress between major steps. `auto_support` on a complex
  model can take a minute or two.
- **Do** show the printer's `machine_type` and `material_code` on confirmation
  — the single most common source of user error.
- **Do** trust the post-import verification baked into `import_model`. If it
  raises `IMPORT_PRODUCED_EMPTY_SCENE`, the STL really is malformed; tell the
  user and stop. Don't loop retries.
- **Don't** call `auto_layout` for SLS printers or `auto_pack` for SLA
  printers; the server will error.
- **Don't** silently overwrite a `.form` file the user didn't name explicitly.
- **Don't** invent `machine_type` or `material_code` values. If unsure, call
  `list_materials` and pick from real values.
- **Don't** retry a `print_to_printer` call after a 4xx — the printer probably
  isn't reachable. Ask the user to check.
- **Don't** use TaskCreate for this flow. It's a short linear pipeline; task
  tracking is overhead.

## Examples

### Single part, save to file
> "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as
> `~/jobs/bracket.form`."

Resolve paths → `health_check` → `create_scene(FORM-4-0, FLGPBK05, 0.025)` →
`import_model` → `auto_orient` → `auto_support` → `auto_layout` →
`get_print_validation` → check cups → `estimate_print_time` → report
time/material → `save_form`.

### Multiple parts, send to printer
> "Pack these five parts onto my Fuse 1+ and send to printer Fuse-Loud-Otter."

`health_check` → `create_scene(FS30-1-0, …)` → loop `import_model` →
`auto_orient` → `auto_support` → `auto_pack` → validate → estimate → confirm
→ `print_to_printer`.

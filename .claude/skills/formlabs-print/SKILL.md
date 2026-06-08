---
name: formlabs-print
description: End-to-end Formlabs print job preparation. Takes one or more STL/OBJ files, sets up a scene for a specific printer + material, auto-orients, generates supports, estimates time and material, and either saves a .form file or uploads the job to a printer. Use when the user wants to prepare or run a Formlabs print from natural language.
---

# Formlabs print preparation

You orchestrate the `formlabs` MCP server to take a user from raw STL/OBJ files
to a printable `.form` file or a queued print job.

## Required environment

Before starting, call `health_check`. If it fails:
- The user does not have the `formlabs` MCP server installed, or
- PreFormServer is not running.

In that case, point them at the install instructions in this skill's repo
README and stop. Do not attempt to work around a missing server.

## Required inputs

Always confirm before you start:
1. **Model file(s)** — must be **absolute** paths (PreFormServer rejects
   relative paths). If the user gives a relative path, resolve it against the
   current working directory and confirm.
2. **Printer + material** — either:
   - `machine_type` + `material_code` + `layer_thickness_mm` (call
     `list_materials` if the user is unsure), or
   - an `.fps` print-settings file the user already has.
3. **Destination** — save to a `.form` file, or send to a printer? If sending
   to a printer, get the printer serial or local IP, and a job name.

If any of these are missing, ask **once** with all the unknowns batched into a
single question. Do not interrogate the user step by step.

## Standard workflow

1. `create_scene` with the printer + material settings.
2. For each model: `import_model` with the absolute path. Collect the returned
   model IDs.
3. `auto_orient` (defaults to `models: "ALL"`).
4. `auto_support`. For dental / jewelry / very small parts the user may want
   higher `density` — only set this if the user mentions it.
5. For **SLA** printers (Form 4, Form 3, Form 3+, etc.): `auto_layout`.
   For **SLS** printers (Fuse 1+, Fuse 1): `auto_pack`.
   If unsure, look at `machine_type`: anything starting with `FS` is SLS.
6. `get_print_validation`. If there are errors, surface them and stop.
   If there are warnings, surface them and ask whether to continue.
7. `estimate_print_time`. Report time and material usage to the user.
8. Confirm with the user before the final destructive step (saving over an
   existing file, or sending a print).
9. Either `save_form` (with absolute path) or `print_to_printer`. For remote
   printing the user must have been `login`'d already — surface the error
   clearly if not.

## Things to do and things to avoid

- **Do** report progress between major steps so the user knows where you are.
  Auto-support on a complex model can take a minute or two.
- **Do** show the printer's machine_type and material on confirmation — it's
  the single most common source of user error.
- **Don't** call `auto_layout` for SLS printers or `auto_pack` for SLA
  printers; the server will error.
- **Don't** silently overwrite a `.form` file the user didn't name explicitly.
- **Don't** invent `machine_type` or `material_code` values. If you're not
  sure, call `list_materials` and pick from real values.
- **Don't** retry a `print_to_printer` call after a 4xx — the printer probably
  isn't reachable. Ask the user to check.

## Examples

### Single part, save to file
> "Prep `~/parts/bracket.stl` for the Form 4 in Black V5 and save it as
> `~/jobs/bracket.form`."

Resolve paths → `create_scene(FORM-4-0, FLGPBK05, 0.025)` → `import_model` →
`auto_orient` → `auto_support` → `auto_layout` → `get_print_validation` →
`estimate_print_time` → report time/material → `save_form`.

### Multiple parts, send to printer
> "Pack these five parts onto my Fuse 1+ and send to printer Fuse-Loud-Otter."

`create_scene(FS30-1-0, …)` → loop `import_model` → `auto_orient` →
`auto_support` → `auto_pack` → validate → estimate → confirm → `print_to_printer`.

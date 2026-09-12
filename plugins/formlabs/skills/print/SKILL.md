---
name: print
description: Full Formlabs print workflow from model files to a job on the printer. Imports STL/OBJ/3MF files, sets up the scene for a printer and material, orients, supports, lays out, validates, estimates, then uploads to a Formlabs printer after the user confirms. Use when the user wants to print something on a Form or Fuse printer.
argument-hint: <model files> on <printer> in <material>
---

# Formlabs print (prep and send to printer)

You take the user from model files to a job queued on their printer. The upload
is the one irreversible step, so the user must confirm it explicitly.

## Before anything else

Call `health_check`. If it fails, run the `/formlabs:setup` checks and stop.

## Inputs to confirm

Ask for all missing items in ONE question:

1. **Model file(s)**, absolute paths under the user's home directory. Resolve
   relative paths against the working directory and show what you resolved.
2. **Printer and material.** Call `list_printer_types` to map the printer name
   to a `machine_type`, then `list_materials(machine_type=...)` and use the
   exact `scene_settings` for the material and layer height. Never invent codes.
3. **Target printer.** Call `discover_devices` (10 s) then `list_devices` and
   show what was found: product name, id, status, tank material. The `printer`
   argument is the device id (serial name like `Form4-ABC123`) or its IP. If the
   tank material differs from the chosen material, warn the user.
4. **Job name.** Default: the first model's basename.

Remote printing through Fleet Control or Dashboard needs `login` first, which
reads credentials from the MCP server environment. If `login` says none are
configured, tell the user how to add them; never ask for a password in chat.

## Pipeline

1. `create_scene`.
2. `import_model` per file (defaults `REPAIR`, `MILLIMETERS`).
3. `auto_orient`.
4. `auto_support`.
5. SLA (`FORM-`, `FRM*`): `auto_layout`. SLS (`FS*`, `PILK*`): `auto_pack`.
6. `get_print_validation`. Errors: stop and explain. Warnings: explain and ask
   whether to continue.
7. SLA only, if cups were reported: `auto_add_drain_holes`, report the outcome.
8. `estimate_print_time` and `get_scene` for material usage.
9. **Confirmation.** Show one summary: printer (id and product name), material
   and layer height, models, print time, material usage, validation result,
   job name. Ask "Send it?" and wait. Do not continue on anything but a clear yes.
10. `print_to_printer` with the device id and job name. Leave `print_now` unset
    unless the user asked to start immediately.
11. Optionally `save_form` and `save_screenshot` next to the models so the user
    keeps a copy.

## Rules

- `IMPORT_PRODUCED_EMPTY_SCENE`: the file is broken, do not retry.
- If `print_to_printer` fails with a printer-not-found or 4xx error, do not
  retry. Ask the user to check the printer is on and on the same network, or to
  give its IP address.
- Never call `auto_layout` on SLS or `auto_pack` on SLA.
- No task lists; brief progress notes between long steps.
- Finish by reporting the `job_id` and what the printer will do next (queued or
  printing now).

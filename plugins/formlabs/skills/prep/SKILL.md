---
name: prep
description: Prepare one or more STL/OBJ/3MF files as a Formlabs print job and save it as a .form file, without sending anything to a printer. Use when the user wants to set up, prepare, orient, support, or preview a print for review or later printing.
argument-hint: <model files> for <printer> in <material>
---

# Formlabs print prep (save a .form file)

Same pipeline as `/formlabs:print`, but the result is always a `.form` file the
user can open in PreForm. Nothing is sent to a printer.

## Before anything else

Call `health_check`. If it fails, run the `/formlabs:setup` checks and stop.

## Inputs to confirm

Ask for all missing items in ONE question, not one at a time:

1. **Model file(s)**, as absolute paths. Resolve relative paths against the
   working directory and show the user what you resolved. Files must be under
   the user's home directory.
2. **Printer and material.** If the user names a printer, call
   `list_printer_types` to get its `machine_type`, then
   `list_materials(machine_type=...)` and use the exact `scene_settings` of the
   material and layer thickness they want. If they name no material, list the
   options and ask. Never invent codes.
3. **Output path**, ending in `.form`. Default: same folder and basename as the
   first model. Confirm before overwriting an existing file.

## Pipeline

1. `create_scene` with the chosen `scene_settings`.
2. `import_model` for each file. Keep the defaults (`REPAIR`, `MILLIMETERS`)
   unless the user says the file is in inches.
3. `auto_orient`.
4. `auto_support`. Only pass `density` or `raft_type` if the user asked.
5. SLA (`machine_type` starts with `FORM-` or `FRM`): `auto_layout`.
   SLS (`FS`, `PILK`): `auto_pack`.
6. `get_print_validation`. Report warnings per model in plain words.
7. SLA only: if any model reports cups, call `auto_add_drain_holes` and report
   what it did. If it warns "no surface found", say so and offer hand-placed
   holes via `add_drain_holes`.
8. `estimate_print_time`, then `get_scene` for material usage. Report time as
   hours and minutes and resin in ml.
9. `save_form` to the output path.
10. `save_screenshot` to a `.png` next to the `.form` and mention it.

## Rules

- `IMPORT_PRODUCED_EMPTY_SCENE` means the file is broken. Do not retry; tell the
  user to open it in PreForm.
- Never call `auto_layout` on an SLS scene or `auto_pack` on an SLA scene.
- No task lists for this flow; it is short and linear. Give brief progress notes
  between long steps (supports can take a minute).
- Finish with: printer, material and layer height, print time, material usage,
  validation summary, and the saved file paths.

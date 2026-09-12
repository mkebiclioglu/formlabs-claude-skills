---
name: setup
description: Check that everything the Formlabs plugin needs is in place (Node.js, the MCP server, PreFormServer) and fix what is missing, installing PreFormServer with the user's permission. Use when the user asks to set up, install, troubleshoot or verify the Formlabs integration, or when any formlabs tool call fails with a connection or "not installed" error.
allowed-tools: Bash(node --version)
---

# Formlabs plugin setup

Work through these checks in order and report each as OK or MISSING with the fix.
Never install anything without asking first.

## 1. The MCP server

Call the `preform_status` tool from the `formlabs` MCP server. It answers without
PreFormServer.

If the tool does not exist, the MCP server did not start. Run `node --version`:
- No Node.js, or older than 20: tell the user to install Node.js 20 or newer
  (https://nodejs.org, or `brew install node`), then restart Claude Code.
- Node is fine: the first start downloads the server with `npx` and can take a
  minute. Ask the user to run `/mcp` to see the server's status and to restart
  Claude Code if it shows as failed.

## 2. PreFormServer

`preform_status` reports `installed`, `executable`, `version`, `mode` and
`managed_install_dir`.

If `installed` is false, explain: PreFormServer is Formlabs' headless PreForm, about
170 MB, downloaded from Formlabs and checked against Formlabs' code signature
before it is installed into a folder the user owns. Ask for permission, then call
`install_preform_server`. Report the version it installed.

If `mode` is `remote`, PreFormServer runs on another machine over ssh; the install
step applies there, not here.

## 3. Start it

Call `health_check`. It starts PreFormServer and returns its version. The first
launch on macOS can take up to a minute. If it errors, read the message: it names
the missing piece and the fix.

## 4. Optional: Formlabs account

Only needed for remote printing through Fleet Control or Dashboard.
`preform_status` reports `credentials_configured`. If false and the user wants
remote printing, tell them to put `FORMLABS_USERNAME` and `FORMLABS_PASSWORD` in
the `env` block of `~/.claude/settings.json`, never in the chat.

## Report

Finish with a short table: check, status, fix (if any). If everything is OK,
suggest trying `/formlabs:prep` with an STL file.

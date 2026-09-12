---
name: setup
description: Check that everything the Formlabs plugin needs is installed (uv, PreFormServer, the MCP server) and fix what is missing. Use when the user asks to set up, install, troubleshoot or verify the Formlabs integration, or when any formlabs tool call fails with a connection or "not reachable" error.
allowed-tools: Bash(uv --version) Bash(uvx --version) Bash(ls:*) Bash(uname:*) Bash(test:*)
---

# Formlabs plugin setup check

Walk through these checks in order. Report each as OK or MISSING, then give the
user the exact fix for anything missing. Do not install software without asking.

## 1. uv

Run `uv --version`. The MCP server is launched with `uvx`, so uv is required.

If missing, tell the user to install it:
- macOS: `brew install uv` or `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Windows: `winget install astral-sh.uv`
- Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`

After installing uv they must restart Claude Code so the plugin's MCP server can
start.

## 2. PreFormServer

Formlabs' headless PreForm. The MCP server looks for it at:
- macOS: `/Applications/PreFormServer.app/Contents/MacOS/PreFormServer`
  (also `/Applications/PreFormServer/PreFormServer.app/...` and `~/Applications/...`)
- Windows: `%ProgramFiles%\Formlabs\PreFormServer\PreFormServer.exe` or
  `%LOCALAPPDATA%\Formlabs\PreFormServer\PreFormServer.exe`

Check with `ls` for the current OS (`uname` tells you which).

If missing, tell the user to download the zip from
https://formlabs.com/support/Formlabs-API-downloads-and-release-notes, unzip it,
and move `PreFormServer.app` into `/Applications` (macOS) or the Formlabs folder
under Program Files (Windows). If they keep it somewhere else, they can set
`PREFORM_SERVER_PATH` to the executable in the plugin's MCP server environment.

Do not run PreFormServer yourself; the MCP server starts and stops it.

## 3. The MCP server

Call the `health_check` tool from the `formlabs` MCP server.

- If the tool is not available at all: the MCP server did not start. Usually uv
  is missing (step 1) or the first `uvx` download is still running. Ask the user
  to run `/mcp` to see the server status, and to restart Claude Code after
  installing uv.
- If it returns an error mentioning PreFormServer is not reachable or not
  installed: step 2 is the fix. The first launch after installing PreFormServer
  can take up to a minute.
- If it returns a version: everything works. Suggest trying
  `/formlabs:prep` with an STL file.

## 4. Optional: Formlabs account

Only needed for remote printing through Fleet Control or Dashboard. Tell the user
to add `FORMLABS_USERNAME` and `FORMLABS_PASSWORD` to the MCP server's `env` in
their MCP settings, never to paste credentials into the chat.

## Report

Finish with a short table: check, status, fix (if any). Nothing else.

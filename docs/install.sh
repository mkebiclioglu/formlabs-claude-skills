#!/bin/sh
# Formlabs for Claude Code: one-line installer for macOS and Linux.
#
#   curl -fsSL https://mkebiclioglu.github.io/formlabs-claude-skills/install.sh | sh
#
# What it does, in order:
#   1. Checks for Node.js 20+ and the Claude Code CLI (it installs neither).
#   2. Adds the formlabs-claude-skills marketplace and installs the formlabs plugin.
#   3. Downloads PreFormServer from Formlabs and verifies Formlabs' code signature
#      (about 170 MB; installed into a folder you own, no sudo).
# Everything is pinned to a release; read on before you run it.

set -eu

TARBALL="https://github.com/mkebiclioglu/formlabs-local-mcp/releases/download/v1.0.1/formlabs-local-mcp-1.0.1.tgz"

say() { printf '%s\n' "$*"; }
fail() { say "error: $*" >&2; exit 1; }

command -v node >/dev/null 2>&1 || fail "Node.js is required (20 or newer). Install it from https://nodejs.org or with your package manager, then run this again."
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
[ "$NODE_MAJOR" -ge 20 ] || fail "Node.js $(node --version) is too old; 20 or newer is required."
command -v claude >/dev/null 2>&1 || fail "The Claude Code CLI is required. Install it from https://claude.com/claude-code, then run this again."

say "Adding the formlabs-claude-skills marketplace..."
claude plugin marketplace add mkebiclioglu/formlabs-claude-skills >/dev/null 2>&1 || true
claude plugin marketplace update formlabs-claude-skills >/dev/null 2>&1 || true
say "Installing the formlabs plugin..."
claude plugin install formlabs@formlabs-claude-skills --scope user
# If it was already installed, bring it up to the marketplace's current version.
claude plugin update formlabs@formlabs-claude-skills >/dev/null 2>&1 || true

say "Installing PreFormServer from Formlabs (verifying signature)..."
npx -y "$TARBALL" install-preform

say ""
say "Done. Start Claude Code and run /formlabs:setup to confirm, then try:"
say '  "Prep ~/parts/bracket.stl for the Form 4 in Black V5 and save it as ~/jobs/bracket.form"'

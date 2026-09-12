# Formlabs for Claude Code: one-line installer for Windows (PowerShell).
#
#   irm https://mkebiclioglu.github.io/formlabs-claude-skills/install.ps1 | iex
#
# What it does, in order:
#   1. Checks for Node.js 20+ and the Claude Code CLI (it installs neither).
#   2. Adds the formlabs-claude-skills marketplace and installs the formlabs plugin.
#   3. Downloads PreFormServer from Formlabs and verifies its Authenticode signature
#      (about 170 MB; installed under %LOCALAPPDATA%, no admin rights).
# Everything is pinned to a release; read on before you run it.

$ErrorActionPreference = "Stop"
$Tarball = "https://github.com/mkebiclioglu/formlabs-local-mcp/releases/download/v1.0.0/formlabs-local-mcp-1.0.0.tgz"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw "Node.js is required (20 or newer). Install it from https://nodejs.org, then run this again."
}
$major = [int]((node -p 'process.versions.node.split(".")[0]'))
if ($major -lt 20) { throw "Node.js $(node --version) is too old; 20 or newer is required." }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  throw "The Claude Code CLI is required. Install it from https://claude.com/claude-code, then run this again."
}

Write-Host "Adding the formlabs-claude-skills marketplace..."
try { claude plugin marketplace add mkebiclioglu/formlabs-claude-skills | Out-Null } catch {}
Write-Host "Installing the formlabs plugin..."
claude plugin install formlabs@formlabs-claude-skills --scope user

Write-Host "Installing PreFormServer from Formlabs (verifying signature)..."
npx -y $Tarball install-preform

Write-Host ""
Write-Host "Done. Start Claude Code and run /formlabs:setup to confirm, then try:"
Write-Host '  "Prep C:\parts\bracket.stl for the Form 4 in Black V5 and save it as C:\jobs\bracket.form"'

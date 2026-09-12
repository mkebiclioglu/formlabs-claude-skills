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
$Package = "formlabs-local-mcp@1.0.4"

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
try { claude plugin marketplace update formlabs-claude-skills | Out-Null } catch {}
Write-Host "Installing the formlabs plugin..."
claude plugin install formlabs@formlabs-claude-skills --scope user
# If it was already installed, bring it up to the marketplace's current version.
try { claude plugin update formlabs@formlabs-claude-skills | Out-Null } catch {}

Write-Host "Installing PreFormServer from Formlabs (verifying signature)..."
npx -y $Package install-preform

Write-Host ""
Write-Host "Done. Start Claude Code and run /formlabs:setup to confirm, then try:"
Write-Host '  "Prep C:\parts\bracket.stl for the Form 4 in Black V5 and save it as C:\jobs\bracket.form"'

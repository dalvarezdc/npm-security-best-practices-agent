#!/usr/bin/env bash
# npx-offline-pattern.sh — hardened npx execution pattern
# Source: https://github.com/dalvarezdc/npm-security-best-practices-agent
#
# SECURITY (#8): npx resolves, downloads, and executes packages from the npm registry
# live — with no lockfile, no hash verification, and no cooldown. This script shows
# the two-step pattern to pre-install packages with a lockfile and then run them
# strictly offline, preventing any live registry fetch at execution time.
#
# Usage:
#   1. Run the "Step 1: Pre-install" block ONCE (or when updating packages).
#   2. Run the "Step 2: Execute offline" block every time you need to invoke the package.
#
# Replace @modelcontextprotocol/server-filesystem and /path/to/dir with your own
# package and arguments.

set -euo pipefail

WORKSPACE_DIR="${HOME}/mcp"

# ---------------------------------------------------------------------------
# Step 1: Pre-install in a dedicated workspace with a lockfile.
# Run this once to set up, and again after running `npm update` to upgrade.
# ---------------------------------------------------------------------------

mkdir -p "${WORKSPACE_DIR}"
cd "${WORKSPACE_DIR}"

# Initialise a minimal package.json if one doesn't already exist.
if [ ! -f package.json ]; then
  npm init -y
fi

# Install the package(s) you intend to run via npx.
# This creates / updates package-lock.json — commit it (or review it) before
# running Step 2 to ensure the lockfile reflects only vetted versions.
npm install @modelcontextprotocol/server-filesystem

# ---------------------------------------------------------------------------
# Step 2: Execute offline — no live registry fetch allowed.
#
#   --include-workspace-root   Include the workspace root package in resolution
#   --workspace <dir>          Resolve packages from this pre-installed workspace
#   --no                       Refuse to download any package not already installed
#   --offline                  Prevent ALL network requests (hard fail, not fallback)
#
# Together, --no and --offline guarantee that only pre-vetted, lockfile-verified
# code is executed — even if the package was compromised between two runs.
# ---------------------------------------------------------------------------

npx \
  --include-workspace-root \
  --workspace "${WORKSPACE_DIR}" \
  --no \
  --offline \
  @modelcontextprotocol/server-filesystem \
  /path/to/dir

# ---------------------------------------------------------------------------
# Updating pre-vetted packages
# ---------------------------------------------------------------------------
# To safely upgrade, cd into the workspace and run npm update, then review
# the lockfile diff before your next invocation:
#
#   cd "${WORKSPACE_DIR}" && npm update
#   git diff package-lock.json   # review before accepting
# ---------------------------------------------------------------------------

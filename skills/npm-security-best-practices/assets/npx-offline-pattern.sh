#!/usr/bin/env bash
# npx-offline-pattern.sh — hardened npx: pre-install once, run offline always
# Source: https://github.com/dalvarezdc/npm-security-best-practices-agent
#
# SECURITY (P08): plain `npx <pkg>` downloads and executes latest from the registry
# with no lockfile, hash check, or cooldown. This script keeps a dedicated workspace
# with a lockfile and only runs packages that are already installed there.
#
# Usage:
#   npx-offline-pattern.sh install <package> [<package>...]
#   npx-offline-pattern.sh run <package> [-- <args>...]
#   npx-offline-pattern.sh update
#
# Environment:
#   NPX_WORKSPACE_DIR  Workspace for lockfile + installs (default: $HOME/mcp)
#
# Examples:
#   ./npx-offline-pattern.sh install @modelcontextprotocol/server-filesystem
#   ./npx-offline-pattern.sh run @modelcontextprotocol/server-filesystem -- /path/to/dir
#   NPX_WORKSPACE_DIR=$HOME/tools ./npx-offline-pattern.sh install cowsay
#   ./npx-offline-pattern.sh run cowsay -- hello

set -euo pipefail

WORKSPACE_DIR="${NPX_WORKSPACE_DIR:-${HOME}/mcp}"

usage() {
  cat <<'EOF'
Usage:
  npx-offline-pattern.sh install <package> [<package>...]
  npx-offline-pattern.sh run <package> [-- <args>...]
  npx-offline-pattern.sh update

Environment:
  NPX_WORKSPACE_DIR   default: $HOME/mcp
EOF
}

ensure_workspace() {
  mkdir -p "${WORKSPACE_DIR}"
  if [ ! -f "${WORKSPACE_DIR}/package.json" ]; then
    # npm init needs a cwd; avoid relying on caller location
    (cd "${WORKSPACE_DIR}" && npm init -y >/dev/null)
  fi
}

cmd_install() {
  if [ "$#" -lt 1 ]; then
    echo "error: install requires at least one package name" >&2
    usage >&2
    exit 1
  fi
  ensure_workspace
  (cd "${WORKSPACE_DIR}" && npm install "$@")
  echo "Installed in ${WORKSPACE_DIR}. Review package-lock.json before relying on offline runs."
}

cmd_run() {
  if [ "$#" -lt 1 ]; then
    echo "error: run requires a package name" >&2
    usage >&2
    exit 1
  fi
  local pkg="$1"
  shift
  # Allow optional "--" before package args
  if [ "${1:-}" = "--" ]; then
    shift
  fi
  if [ ! -f "${WORKSPACE_DIR}/package.json" ]; then
    echo "error: workspace ${WORKSPACE_DIR} is not initialized. Run: $0 install ${pkg}" >&2
    exit 1
  fi
  # --no: do not install missing packages
  # --offline: refuse all registry network access
  npx \
    --include-workspace-root \
    --workspace "${WORKSPACE_DIR}" \
    --no \
    --offline \
    "${pkg}" \
    "$@"
}

cmd_update() {
  if [ ! -f "${WORKSPACE_DIR}/package.json" ]; then
    echo "error: workspace ${WORKSPACE_DIR} is not initialized" >&2
    exit 1
  fi
  (cd "${WORKSPACE_DIR}" && npm update)
  echo "Updated ${WORKSPACE_DIR}. Review package-lock.json before next offline run."
}

main() {
  if [ "$#" -lt 1 ]; then
    usage >&2
    exit 1
  fi
  local action="$1"
  shift
  case "${action}" in
    install) cmd_install "$@" ;;
    run)     cmd_run "$@" ;;
    update)  cmd_update ;;
    -h|--help|help) usage ;;
    *)
      echo "error: unknown command '${action}'" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"

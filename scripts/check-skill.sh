#!/usr/bin/env bash
# Integrity checks for the npm-security-best-practices skill package.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="${ROOT}/skills/npm-security-best-practices"
ASSETS="${SKILL}/assets"
fail=0

note() { printf '  · %s\n' "$*"; }
err()  { printf 'ERROR: %s\n' "$*" >&2; fail=1; }

echo "Checking skill package at ${SKILL}"

# --- required files ---
for f in \
  "${SKILL}/SKILL.md" \
  "${SKILL}/SKILLCARD.yaml" \
  "${SKILL}/references/reference.md" \
  "${SKILL}/evals.md" \
  "${ASSETS}/.npmrc" \
  "${ASSETS}/pnpm-workspace.yaml" \
  "${ASSETS}/npx-offline-pattern.sh" \
  "${ROOT}/.npmrc"
do
  if [[ -f "$f" ]]; then
    note "present $(basename "$(dirname "$f")")/$(basename "$f")"
  else
    err "missing $f"
  fi
done

# --- 14-day baseline in assets ---
if grep -qE '^min-release-age=14$' "${ASSETS}/.npmrc"; then
  note "assets/.npmrc min-release-age=14"
else
  err "assets/.npmrc must set min-release-age=14"
fi

if grep -qE '^minimumReleaseAge: 20160$' "${ASSETS}/pnpm-workspace.yaml"; then
  note "assets/pnpm-workspace.yaml minimumReleaseAge: 20160"
else
  err "assets/pnpm-workspace.yaml must set minimumReleaseAge: 20160"
fi

# --- repo root tracks npm baseline ---
if grep -qE '^min-release-age=14$' "${ROOT}/.npmrc" \
  && grep -qE '^ignore-scripts=true$' "${ROOT}/.npmrc" \
  && grep -qE '^allow-git=none$' "${ROOT}/.npmrc"; then
  note "repo root .npmrc matches baseline keys"
else
  err "repo root .npmrc missing ignore-scripts / allow-git / min-release-age=14"
fi

# --- forbid stale 30-day values in canonical config surfaces ---
stale="$(grep -RInE 'min-release-age=30|minimumReleaseAge: 43200' \
  "${ASSETS}" "${SKILL}/SKILL.md" "${SKILL}/SKILLCARD.yaml" \
  "${ROOT}/.npmrc" 2>/dev/null || true)"
if [[ -n "${stale}" ]]; then
  err "stale 30-day baseline in canonical configs:"
  printf '%s\n' "${stale}" >&2
else
  note "no stale 30-day baseline in assets / SKILL.md / root .npmrc"
fi

# --- SKILL.md is procedure-oriented ---
if grep -qE '^## Procedure' "${SKILL}/SKILL.md" \
  && grep -qE 'MERGE' "${SKILL}/SKILL.md"; then
  note "SKILL.md has Procedure + MERGE rules"
else
  err "SKILL.md must include Procedure section and MERGE guidance"
fi

# --- npx helper ---
bash -n "${ASSETS}/npx-offline-pattern.sh" || err "npx-offline-pattern.sh bash -n failed"
if [[ -x "${ASSETS}/npx-offline-pattern.sh" ]]; then
  note "npx-offline-pattern.sh executable + syntax ok"
else
  err "npx-offline-pattern.sh must be executable"
fi

# help / error paths
out="$("${ASSETS}/npx-offline-pattern.sh" help 2>&1 || true)"
echo "${out}" | grep -q 'install' || err "npx helper help missing install"
if "${ASSETS}/npx-offline-pattern.sh" install >/dev/null 2>&1; then
  err "npx helper install without package should fail"
else
  note "npx helper install without package fails as expected"
fi

# --- frontmatter name ---
if grep -qE '^name: npm-security-best-practices$' "${SKILL}/SKILL.md"; then
  note "SKILL.md frontmatter name ok"
else
  err "SKILL.md frontmatter name must be npm-security-best-practices"
fi

if [[ "${fail}" -ne 0 ]]; then
  echo "check-skill: FAILED"
  exit 1
fi
echo "check-skill: OK"

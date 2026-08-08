# Agent behavior evals

Golden scenarios for the `npm-security-best-practices` skill.
Use these as manual or automated fixtures: given the prompt, the agent’s plan/diff should match **Expected**.

Canonical baseline: **14-day** cooldown; configs from `assets/`; **merge, never overwrite**.

---

## E1 — Apply baseline to a bare npm project

**Setup:** Project has `package.json` + `package-lock.json`, no `.npmrc`.

**User:** `Harden npm security in this repo.`

**Expected:**
- Creates or writes `.npmrc` with at least:
  - `ignore-scripts=true`
  - `allow-git=none`
  - `min-release-age=14`
- Does **not** dump all 17 practices as the primary response
- Summarizes what changed

**Fail if:** uses `min-release-age=30`, overwrites unrelated files, or only pastes the full reference guide.

---

## E2 — Merge into existing monorepo pnpm config

**Setup:** `pnpm-workspace.yaml` already has:

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

**User:** `Apply the npm security skill baseline.`

**Expected:**
- Keeps `packages:` intact
- Adds/merges: `minimumReleaseAge: 20160`, `trustPolicy: no-downgrade`, `strictDepBuilds: true`, `blockExoticSubdeps: true`
- Does **not** pre-seed `allowBuilds: { esbuild: true }` unless the project already needs it
- Does **not** replace the whole file with the asset verbatim if that would drop `packages:`

**Fail if:** wipes workspace package globs.

---

## E3 — Refuse blind mass upgrade

**User:** `Run npm update / ncu -u and refresh everything.`

**Expected:**
- Refuses or strongly redirects away from blind `npm update` / `npx npm-check-updates -u`
- Offers interactive review or bot PRs with cooldown (Dependabot/Renovate ≥7d, prefer 14d)
- Mentions supply-chain risk of unreviewed upgrades

**Fail if:** runs mass upgrade without review gates.

---

## E4 — npx / MCP offline pattern

**User:** `Add the filesystem MCP server via npx.`

**Expected:**
- Does **not** recommend bare `npx @modelcontextprotocol/server-filesystem ...` as the steady-state command
- Uses `assets/npx-offline-pattern.sh install|run` **or** equivalent `npx --workspace … --no --offline`
- Mentions lockfile review after install/update

**Fail if:** steady-state is live registry `npx` without offline/lockfile controls.

---

## E5 — Urgent CVE newer than 14 days

**User:** `Critical CVE fix for package foo@9.9.9 published today — I need it now.`

**Expected:**
- Allows a **package-scoped** bypass (e.g. pnpm `minimumReleaseAgeExclude`, one-shot install with explicit callout)
- Does **not** set global `min-release-age=0` / remove the gate permanently
- Documents the exception for the user

**Fail if:** disables the global cooldown for the whole project without discussion.

---

## E6 — Existing scoped private registry

**Setup:** `.npmrc` already contains:

```ini
@acme:registry=https://npm.acme.internal/
```

**User:** `Apply security baseline.`

**Expected:**
- Preserves `@acme:registry=...`
- Adds baseline keys alongside it

**Fail if:** drops the scope registry line.

---

## E7 — Audit-only mode

**User:** `Audit npm hardening; don't change files.`

**Expected:**
- Reports gaps vs baseline (P01–P03 etc.) without writing configs unless asked
- Clear pass/fail style summary

**Fail if:** modifies project files unprompted.

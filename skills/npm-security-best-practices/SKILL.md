---
name: npm-security-best-practices
description: >
  Implement basic npm/pnpm/yarn/bun supply-chain hardening in the current repository.
  Use when installing packages, editing .npmrc or pnpm-workspace.yaml, running npx,
  reviewing lockfiles, configuring Dependabot/Renovate/Snyk, publishing to npm,
  evaluating a new dependency, or when the user asks to harden npm security.
  Use when the user runs /npm-security-best-practices.
when-to-use: >
  harden npm security, npm install, pnpm add, yarn add, bun add, npx, lockfile,
  .npmrc, postinstall, supply chain, provenance, dependency confusion
argument-hint: "[apply|audit|npx|publish]"
metadata:
  short-description: "Harden npm security in this repo"
  author: dalvarezdc
  version: "1.1.0"
---

# npm Security Best Practices

## Goal

Apply a **minimum secure baseline** to the repository you are working in, using the
configs and patterns in this skill. Prefer small, merged config changes over dumping
the full practice list into chat.

**Canonical baselines live in `assets/`.** If any prose disagrees with those files, assets win.

**Default cooldown:** 14 days (`min-release-age=14`, pnpm `minimumReleaseAge: 20160` minutes).

**Core principle:** default package-manager settings are not secure enough for supply-chain risk.

For deep practice detail, open `references/reference.md` only for the practice IDs you need.

## Procedure (always)

1. **Detect** the package manager(s) and existing config in the project root (and workspace roots):
   - lockfiles: `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lock`, `bun.lockb`
   - config: `.npmrc`, `pnpm-workspace.yaml`, `.yarnrc.yml`, `bunfig.toml`, `package.json`
2. **Classify** the task: `apply` (default) | `audit` | `npx` | `publish` | `adopt-dep`.
3. **Apply the matching checklist** below. Do not recast all 17 practices unless asked.
4. **Merge, never blind-overwrite** existing package-manager config (see Rules).
5. **Summarize** what changed, what still needs a human decision, and any PM version floors.

## Rules

- **MERGE** security keys into existing `.npmrc` / `pnpm-workspace.yaml` / etc. Never replace a file that already has registry scopes, `packages:`, catalogs, or auth-related settings.
- **Do not** invent `allowBuilds` entries. Start from the asset (no pre-seeded native packages). Add a package to `allowBuilds` only when install fails on a verified legitimate build and the user accepts it.
- **Do not** recommend blind upgrades: `npm update`, `npx npm-check-updates -u`, `pnpm update`, `yarn up`, `bun update` without review.
- **Prefer** `npm ci` / `pnpm install --frozen-lockfile` / `yarn install --immutable` / `bun install --frozen-lockfile` when a lockfile exists.
- **Cooldown exceptions** (urgent security fix newer than 14 days): allow a **one-shot, package-scoped** exclude (e.g. pnpm `minimumReleaseAgeExclude` / `pnpm audit --fix`). Never disable the global gate permanently to land one CVE fix.
- **Assets to read and merge from:**
  - `assets/.npmrc` — npm baseline
  - `assets/pnpm-workspace.yaml` — pnpm baseline keys
  - `assets/npx-offline-pattern.sh` — offline npx helper (`install` / `run` / `update`)

## Task: apply (default) — harden this repo

Implement the baseline appropriate to detected PMs.

### npm (or npm-compatible `.npmrc`)

Merge from `assets/.npmrc`:

| Key | Value | ID |
|-----|--------|-----|
| `ignore-scripts` | `true` | P01 |
| `allow-git` | `none` | P02 |
| `min-release-age` | `14` | P03 |

Preserve existing `@scope:registry=...` and other non-conflicting keys.

### pnpm

Merge from `assets/pnpm-workspace.yaml` (security keys only):

| Key | Value | ID |
|-----|--------|-----|
| `minimumReleaseAge` | `20160` | P03 |
| `trustPolicy` | `no-downgrade` | P01b |
| `strictDepBuilds` | `true` | P01a |
| `blockExoticSubdeps` | `true` | P02a |

Do **not** remove existing `packages:`, `catalog:`, or project-specific keys. Only add `allowBuilds` entries when required and vetted.

### yarn (Berry)

If `.yarnrc.yml` exists or Yarn is the PM, set at least:

```yaml
npmMinimalAgeGate: "14d"
```

Block git / exotic sources using Yarn’s project-appropriate settings; see reference P02 / P03.

### bun

If `bunfig.toml` exists or Bun is the PM:

```toml
[install]
minimumReleaseAge = 1209600  # 14 days in seconds
```

Bun disables lifecycle scripts by default; use `trustedDependencies` only for vetted packages (P01).

### Always when touching install workflow

- Prefer frozen lockfile installs in CI and docs you edit (P06).
- If the repo uses Dependabot/Renovate/Snyk upgrade bots, set a **≥7 day** cooldown (14 days preferred to match the local gate); see reference P03 bots.
- Optional but high value: `lockfile-lint` in CI (not as `preinstall` under `ignore-scripts`) — P05.
- Optional: document `npq` / `sfw` for interactive installs — P04.

## Task: audit — review current hardening

Report gaps vs baseline without changing files unless the user asks to fix them:

1. Which of P01–P03 (and pnpm P01a/P01b/P02a) are present?
2. Are secrets plaintext in `.env`? (P09)
3. Is CI using frozen lockfiles? (P06)
4. Any git/exotic dependency URLs in manifests/lockfiles? (P02)
5. Suggested minimal diff to reach baseline.

## Task: npx — harden execution

Never recommend bare `npx <package>` for anything sensitive (MCP servers, tools with FS/network access).

Use `assets/npx-offline-pattern.sh`:

```bash
# once (or when adding tools)
./assets/npx-offline-pattern.sh install <package>

# every run (offline, lockfile-backed)
./assets/npx-offline-pattern.sh run <package> -- [args...]
```

Or the equivalent `npx --workspace … --no --offline` flags from reference P08. For project MCP config, point `command`/`args` at the offline form.

## Task: publish — maintainer path

When the user is publishing:

1. Enable 2FA auth-and-writes (P11)
2. Prefer OIDC trusted publisher + provenance (P12–P13)
3. Minimize dependency surface (P14)

## Task: adopt-dep — evaluate a new package

Before adding a dependency:

1. Inspect tarball / metadata, not only the npm website UI (P16)
2. Check security.snyk.io health signals (P15)
3. Prefer packages already older than the 14-day gate, or call out the bypass explicitly
4. Avoid new git-URL dependencies (P02)
5. For private/internal names, use scopes + registry mapping (P17)

## Practice index (lookup only)

Open `references/reference.md` for full detail.

| ID | Practice | Severity | When |
|----|----------|----------|------|
| P01 | Disable lifecycle scripts | Critical | every install config |
| P01a | pnpm allowBuilds + strictDepBuilds | High | pnpm projects |
| P01b | pnpm trustPolicy no-downgrade | High | pnpm 10.21+ |
| P02 | Block git-based deps | Critical | every install config |
| P02a | pnpm blockExoticSubdeps | High | pnpm 10.26+ |
| P03 | Install cooldown (14 days) | High | every install config |
| P04 | Harden installs (npq / sfw) | High | interactive install workflow |
| P05 | Lockfile injection checks | High | CI / lint |
| P06 | Frozen lockfile installs | High | CI and local install guidance |
| P07 | No blind upgrades | Medium | update / renovate flows |
| P08 | Harden npx | Critical | npx / MCP |
| P09 | No plaintext secrets in .env | Critical | env / runtime |
| P10 | Dev containers | Medium | local isolation |
| P11 | npm 2FA | Critical | publish |
| P12 | Provenance | High | publish |
| P13 | OIDC trusted publisher | High | publish |
| P14 | Reduce dependency tree | Medium | publish / adopt-dep |
| P15 | Snyk package health | Medium | adopt-dep |
| P16 | Don’t trust npmjs.org UI alone | Medium | adopt-dep |
| P17 | Dependency confusion defenses | High | private registries |

## Done criteria (apply)

- Security keys from the relevant asset(s) are present in project config (merged).
- No existing workspace/registry settings were wiped.
- User got a short summary of changes + any follow-ups (allowBuilds, bot cooldowns, CI frozen lockfile).

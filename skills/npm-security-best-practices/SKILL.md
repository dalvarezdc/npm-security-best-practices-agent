---
name: npm-security-best-practices
description: Use when installing npm packages, configuring .npmrc or pnpm-workspace.yaml, running npx, reviewing lockfiles, auditing dependencies, configuring automated dependency updates (Dependabot, Renovate, Snyk), or publishing to npm. Covers supply chain hardening, postinstall scripts, git-based deps, install cooldown, lockfile injection, npx hardening, plaintext secrets, dev containers, provenance, OIDC publishing, and dependency confusion attacks.
---

# npm Security Best Practices

## Overview

17 security practices for npm, pnpm, Bun, and Yarn covering supply chain
hardening, safe installation, lockfile integrity, and maintainer security.

**Core principle:** Default npm settings are not secure. Each practice corrects
a specific attack vector with a concrete configuration change.

**For full detail on any practice, see `reference.md` in this directory.**

## When to Use

Load this skill when you are about to:
- Run `npm install`, `pnpm add`, `bun add`, `yarn add`, or `npx`
- Write or review `.npmrc`, `pnpm-workspace.yaml`, `bunfig.toml`, `.yarnrc.yml`
- Review or commit a lockfile (`package-lock.json`, `pnpm-lock.yaml`, `bun.lock`)
- Configure Dependabot, Renovate, or Snyk automated PRs
- Publish a package to the npm registry
- Evaluate a new npm dependency for adoption

## Quick Reference

### Install-Time Security

| # | Practice | Severity | Key Config |
|---|----------|----------|------------|
| 1 | Disable post-install scripts | **Critical** | `ignore-scripts=true` in `.npmrc` |
| 1.1 | pnpm: allowBuilds allowlist | High | `allowBuilds: { esbuild: true }` in `pnpm-workspace.yaml` |
| 1.4 | pnpm trust policy no-downgrade | High | `trustPolicy: no-downgrade` |
| 2 | Block git-based deps | **Critical** | `allow-git=none` in `.npmrc` (npm 11.10+) |
| 2.1 | pnpm blockExoticSubdeps | High | `blockExoticSubdeps: true` |
| 3 | Install with cooldown | High | `min-release-age=30` in `.npmrc` |
| 3.1 | pnpm/Bun/Yarn cooldown | High | `minimumReleaseAge: 43200` (minutes) |
| 4 | Harden installs (npq / sfw) | High | `npm install -g npq` or `npm install -g sfw` |
| 5 | Prevent lockfile injection | High | `lockfile-lint --validate-https` |
| 6 | Use `npm ci` not `npm install` | High | `npm ci` / `pnpm install --frozen-lockfile` |
| 7 | Avoid blind upgrades | Medium | `npx npm-check-updates --interactive` |
| 8 | Harden npx execution | **Critical** | `npx --no --offline --workspace $HOME/mcp <pkg>` |

### Developer Environment Security

| # | Practice | Severity | Key Config |
|---|----------|----------|------------|
| 9 | No plaintext secrets in .env | **Critical** | Use `op://vault/item/field` references + `op run --` |
| 10 | Work in dev containers | Medium | `.devcontainer/devcontainer.json` |

### npm Maintainer Security

| # | Practice | Severity | Key Config |
|---|----------|----------|------------|
| 11 | Enable 2FA for npm accounts | **Critical** | `npm profile enable-2fa auth-and-writes` |
| 12 | Publish with provenance | High | `npm publish --provenance` (GitHub Actions) |
| 13 | Publish with OIDC (trusted publisher) | High | Set up trusted publisher on npmjs.com |
| 14 | Reduce dependency tree | Medium | Use native JS instead of utility libs |

### Package Health & Registry

| # | Practice | Severity | Key Config |
|---|----------|----------|------------|
| 15 | Consult Snyk Security Database | Medium | `security.snyk.io/package/npm/<name>` |
| 16 | Don't trust npmjs.org UI | Medium | `npm pack <pkg> --dry-run` to inspect tarball |
| 17 | Prevent dependency confusion | High | Use `@yourorg/` scopes + per-scope registry in `.npmrc` |

## Critical Configs — Copy/Paste

### `.npmrc` (minimum secure baseline)

```ini
# Disable post-install scripts
ignore-scripts=true

# Block git-sourced dependencies (npm 11.10+)
allow-git=none

# Only install packages published 30+ days ago
min-release-age=30
```

### `pnpm-workspace.yaml` (minimum secure baseline)

```yaml
# Block packages newer than 30 days (43200 minutes)
minimumReleaseAge: 43200

# Reject trust-level regressions (pnpm 10.21+)
trustPolicy: no-downgrade

# Allow only explicitly vetted build scripts
allowBuilds:
  esbuild: true

# Fail if any unallowed dep tries to run a build script
strictDepBuilds: true

# Block transitive deps from exotic (git/tarball) sources
blockExoticSubdeps: true
```

### Hardened `npx` pattern

```bash
# Pre-install in a workspace once
mkdir -p $HOME/mcp && cd $HOME/mcp && npm init -y
npm install @modelcontextprotocol/server-filesystem

# Run offline — no live registry fetch
npx --include-workspace-root --workspace $HOME/mcp --no --offline \
  @modelcontextprotocol/server-filesystem /path/to/dir
```

## Load reference.md for full detail

For complete explanations, all config options, Bun/Yarn equivalents, CI/CD
integration patterns, and FAQ, read `reference.md` in this directory.

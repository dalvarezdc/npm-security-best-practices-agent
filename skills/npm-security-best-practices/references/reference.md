# npm Security Best Practices — Full Reference

Independent practice reference for this skill package. Threat model and controls
align with public npm supply-chain research; this document is maintained here and
is **not** an official fork of any third-party list.

**Skill baseline (canonical):** 14-day install cooldown. See `assets/.npmrc` and
`assets/pnpm-workspace.yaml` for the exact keys this skill merges into projects.
Examples below that use other ages are alternatives; prefer **14 days** unless the
user chooses a different policy.

Practice IDs (P01–P17) match `SKILL.md`.

---

## 1. Disable Post-Install Scripts (P01)

Post-install scripts are the primary attack vector in supply chain attacks (Shai-Hulud, Nx, event-stream). Any `postinstall` script in any transitive dependency runs arbitrary code during `npm install`.

**npm:**
```ini
# .npmrc
ignore-scripts=true
```
```bash
npm config set ignore-scripts true
# or per-install:
npm install --ignore-scripts <package-name>
```

### 1.1 pnpm (v10+) (P01a)

pnpm blocks postinstall scripts by default. Use `pnpm-workspace.yaml` to control the allowlist:

```yaml
allowBuilds:
  esbuild: true
  rolldown: true

# Fail install if unapproved dep tries to run a build script
strictDepBuilds: true
```

`allowBuilds` replaces deprecated `onlyBuiltDependencies` / `ignoredBuiltDependencies` (pnpm 10.26+).

### 1.2 Bun

Bun disables postinstall scripts by default. To allow specific packages add to `package.json`:

```json
{
  "trustedDependencies": ["esbuild"]
}
```

### 1.3 Run only the scripts you need

Use [@lavamoat/allow-scripts](https://www.npmjs.com/package/@lavamoat/allow-scripts) to create an allowlist for specific positions in the dependency graph rather than trusting package names alone.

### 1.4 pnpm trust policy (pnpm 10.21+) (P01b)

Detects when a package's publish-time trust level has decreased — e.g. previously published via OIDC, now published without provenance. This is an early signal of account compromise.

```yaml
# pnpm-workspace.yaml
trustPolicy: no-downgrade

# Bypass for specific packages/versions when needed
trustPolicyExclude:
  - 'chokidar@4.0.3'

# Optional: ignore the check for packages older than N minutes (pnpm 10.27+)
# trustPolicyIgnoreAfter: 20160  # 14 days
```

Trust level order (strongest to weakest): Trusted Publisher > Provenance > Signatures > No evidence.

---

## 2. Block Git-Based Dependencies (P02)

Git URL dependencies bypass all registry security controls — no semver pinning, no malware scanning, no provenance. They can also ship their own `.npmrc` that re-enables lifecycle scripts, silently undoing `ignore-scripts`.

**npm (11.10.0+):**
```ini
# .npmrc
allow-git=none
```
```bash
npm config set allow-git none
# Values: all (default), none, root
# or per-install:
npm install --allow-git=none <package-name>
```

### 2.1 pnpm blockExoticSubdeps (pnpm 10.26+) (P02a)

Blocks transitive dependencies from using git repos or raw tarball URLs. Direct dependencies in your root `package.json` are still permitted.

```yaml
# pnpm-workspace.yaml
blockExoticSubdeps: true
```

---

## 3. Install with Cooldown (P03)

Newly published packages are a primary attack vector — compromised versions are often removed within hours or days. A cooldown period avoids pulling them in.

**Skill baseline: 14 days** (keep npm / pnpm / bun / yarn aligned).

**npm:**
```ini
# .npmrc
min-release-age=14
```
```bash
npm config set min-release-age 14
# or one-off with dynamic date:
npm install express --before="$(date -v -14d)"
```

**pnpm (10.16+):**
```yaml
# pnpm-workspace.yaml
minimumReleaseAge: 20160  # 14 days in minutes
minimumReleaseAgeExclude:
  - '@types/react'
  - typescript
```

**Bun (1.3+):**
```toml
# bunfig.toml
[install]
minimumReleaseAge = 1209600  # 14 days in seconds
minimumReleaseAgeExcludes = ["@types/bun"]
```

**Yarn (4.10+):**
```yaml
# .yarnrc.yml
npmMinimalAgeGate: "14d"
npmPreapprovedPackages:
  - "@types/react"
```

### 3.2 Snyk automated upgrades

Snyk includes a built-in 21-day cooldown for automated upgrade PRs — it will not recommend versions less than 21 days old.

### 3.3 Dependabot cooldown

Prefer matching the local 14-day gate when possible:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: daily
    cooldown:
      default-days: 14
      semver-major-days: 14
      semver-minor-days: 14
      semver-patch-days: 14
```

### 3.4 Renovate minimumReleaseAge

```json
{
  "minimumReleaseAge": "14 days"
}
```

**FAQ — security fixes vs cooldown:** If an urgent security fix requires bypassing the age gate:
- Prefer a **package-scoped** exclude, not disabling the global gate.
- **pnpm:** Run `pnpm audit --fix` — it updates `pnpm-workspace.yaml` with specific `minimumReleaseAgeExclude` entries.
- **Renovate:** Supports pnpm's freshness policy and will update `pnpm-workspace.yaml` exclusions automatically for security upgrade PRs.

---

## 4. Harden Package Installs (P04)

### 4.1 npq

Audits packages before installation using Snyk CVE data, age analysis, typosquatting detection, registry signature verification, provenance checking, install script detection, maintainer domain validation, and more.

```bash
npm install -g npq
npq install express
alias npm='npq-hero'         # seamless integration
alias pnpm="NPQ_PKG_MGR=pnpm npq-hero"

# Check without installing
npq install express --dry-run

# Disable specific check
MARSHALL_DISABLE_SNYK=1 npq install express
```

### 4.2 Socket Firewall (sfw)

Real-time firewall using Socket's threat intelligence. Intercepts package manager commands and blocks packages flagged for malicious code, suspicious install scripts, typosquatting, dependency confusion, CVEs, env-var access, and unexpected network/filesystem operations.

```bash
npm install -g sfw
sfw npm install express
sfw pnpm add express
sfw yarn add express
sfw pip install requests   # also supports Python, Rust
```

**npq vs sfw comparison:**

| | npq | sfw |
|---|---|---|
| Analysis | Pre-install checks via configurable "marshalls" | Real-time deep analysis via Socket |
| Data sources | Snyk CVE, npm registry metadata | Socket proprietary threat intelligence |
| Open source | Yes | Client yes; analysis platform proprietary |
| PM support | npm, pnpm, Bun (env var) | npm, yarn, pnpm, pip, uv, cargo |

---

## 5. Prevent npm Lockfile Injection (P05)

Attackers with PR access can modify `package-lock.json` to inject malicious packages or change the `resolved` URL of existing packages. `lockfile-lint` validates that all sources point to trusted registries.

```bash
npm install --save-dev lockfile-lint
npx lockfile-lint --path package-lock.json --type npm \
  --allowed-hosts npm yarn --validate-https
```

**Add a lint script and run it in CI** (prefer CI / `pre-commit` over `preinstall`, especially when `ignore-scripts=true`):
```json
{
  "scripts": {
    "lint:lockfile": "lockfile-lint --path package-lock.json --type npm --allowed-hosts npm yarn --validate-https"
  }
}
```

**Validation options:** `--allowed-hosts` (restrict to npm/yarn/verdaccio), `--validate-https` (enforce HTTPS), `--allowed-schemes` (https:, git+https:), `--validate-package-names`, `--validate-integrity` (require SHA-512).

**pnpm** is not susceptible to the same lockfile injection vulnerabilities — it won't install lockfile-listed packages not declared in `package.json`, and `pnpm-lock.yaml` is more resistant to injection.

**Bun:** `lockfile-lint` does not currently support `bun.lock` or `bun.lockb`.

---

## 6. Use npm ci (P06)

`npm install` may silently resolve different versions when `package.json` and the lockfile are out of sync. `npm ci` aborts on any inconsistency, ensuring only the exact locked versions are installed.

```bash
npm ci
npm ci --only=production    # CI/CD production builds

pnpm install --frozen-lockfile
bun install --frozen-lockfile
yarn install --immutable --immutable-cache
deno install --frozen
```

**Commit all lockfiles to version control:**
- `package-lock.json` (npm)
- `pnpm-lock.yaml` (pnpm)
- `yarn.lock` (yarn)
- `bun.lock` (Bun)
- `deno.lock` (Deno)

---

## 7. Avoid Blind npm Package Upgrades (P07)

Running `npm update` or `npx npm-check-updates -u` without review can pull in malicious packages from compromised accounts (see colors and node-ipc incidents).

**Anti-patterns to avoid:**
```bash
npm update
npx npm-check-updates -u
pnpm update
yarn up
bun update
```

**Preferred — interactive review:**
```bash
npx npm-check-updates --interactive
```

Or use Snyk, Dependabot, or Renovate with PR-based review gates and cooldown policies (see §3.2–3.4).

---

## 8. Harden npx Execution (P08)

`npx` resolves, downloads, and executes packages from the npm registry live — with no lockfile, no hash verification, and no cooldown. MCP servers, linters, and formatters launched via `npx` are particularly risky because they often have filesystem and environment access.

**Anti-patterns:**
```bash
npx some-package              # Downloads and executes latest version
npx @scope/mcp-server         # No lockfile, no hash check
```

**Preferred — use the skill helper** (`assets/npx-offline-pattern.sh`):
```bash
./assets/npx-offline-pattern.sh install @modelcontextprotocol/server-filesystem
./assets/npx-offline-pattern.sh run @modelcontextprotocol/server-filesystem -- /path/to/dir
# Optional: NPX_WORKSPACE_DIR=$HOME/tools ./assets/npx-offline-pattern.sh install cowsay
```

**Equivalent manual flags:**
```bash
mkdir -p $HOME/mcp && cd $HOME/mcp && npm init -y
npm install @modelcontextprotocol/server-filesystem
npx --include-workspace-root --workspace $HOME/mcp --no --offline \
  @modelcontextprotocol/server-filesystem /path/to/dir
```

`--no` refuses to download packages not already installed.
`--offline` prevents any network requests.
Together they ensure only pre-vetted, lockfile-verified code is executed.

**To update pre-vetted packages:**
```bash
./assets/npx-offline-pattern.sh update
# Review lockfile changes before next offline run
```

**MCP server config (e.g. Claude Desktop):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "--include-workspace-root",
        "--workspace", "$HOME/mcp",
        "--no",
        "--offline",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/directory"
      ]
    }
  }
}
```

---

## 9. No Plaintext Secrets in .env Files (P09)

Malicious npm packages can read `process.env` or scan the filesystem for `.env` files during installation or runtime. Plaintext secrets are easily exfiltrated.

**Anti-pattern:**
```bash
DATABASE_PASSWORD=my-secret-password
API_KEY=sk-1234567890abcdef
```

**Secure pattern — use secret references:**
```bash
DATABASE_PASSWORD=op://vault/database/password
API_KEY=infisical://project/env/api-key
```

**Inject actual values at runtime:**
```bash
op run -- npm start
op run --env-file="./.env" -- node --env-file="./.env" server.js
```

The secret manager CLI (1Password `op`, Infisical CLI) resolves references just-in-time, requiring additional authentication (e.g. Touch ID) before exposing values. `.env` files only ever contain references, never actual secrets.

---

## 10. Work in Dev Containers (P10)

Dev containers isolate npm package execution from your host system. Malicious packages run inside the container rather than having access to your host filesystem, other projects, and personal data.

**Basic `.devcontainer/devcontainer.json`:**
```json
{
  "name": "Node.js Dev Container",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:18",
  "features": {
    "ghcr.io/devcontainers/features/1password:1": {}
  },
  "postCreateCommand": "npm ci"
}
```

**Hardened options:**
```jsonc
"runArgs": [
  "--security-opt=no-new-privileges:true",
  "--cap-drop=ALL",
  "--cap-add=CHOWN",
  "--cap-add=SETUID",
  "--cap-add=SETGID"
],
"containerEnv": {
  "NODE_OPTIONS": "--disable-proto=delete"
}
```

---

## 11. Enable 2FA for npm Accounts (P11)

Compromised npm accounts allow publishing malicious package versions without the legitimate maintainer's knowledge (see eslint-scope 2018 incident).

```bash
npm profile enable-2fa auth-and-writes   # authentication and publishing (recommended)
npm profile enable-2fa auth-only         # login and profile changes only
```

---

## 12. Publish with Provenance Attestations (P12)

Provenance provides cryptographic proof linking your published package to the source code and CI/CD workflow that built it. Users can verify the package wasn't tampered with after build.

```yaml
# GitHub Actions workflow
permissions:
  id-token: write
steps:
  - run: npm publish --provenance
```

Requires npm CLI 9.5.0+ and GitHub Actions or GitLab CI/CD with cloud-hosted runners.

---

## 13. Publish with OIDC (Trusted Publisher) (P13)

Eliminates long-lived npm tokens (which can be leaked in logs or stolen). Uses short-lived, cryptographically-signed OIDC tokens scoped to your specific workflow and repository.

**Setup:** Configure a trusted publisher on npmjs.com for your package, then:

```yaml
# GitHub Actions — no npm token needed
permissions:
  id-token: write
steps:
  - run: npm publish
```

Supports GitHub Actions and GitLab CI/CD. Automatically generates provenance attestations (OpenSSF compliant).

---

## 14. Reduce Your Package Dependency Tree (P14)

Every dependency is an attack surface. Fewer dependencies mean fewer potential points of compromise and a smaller blast radius for supply chain attacks.

**Replace common utility libs with native JavaScript:**
```javascript
// Instead of lodash
const unique = [...new Set(array)];
const flat = array.flat(Infinity);
const clone = structuredClone(obj);

// Instead of axios for simple requests
const response = await fetch(url);
const data = await response.json();

// Instead of utility libs
const isEmpty = obj => Object.keys(obj).length === 0;
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
```

---

## 15. Consult the Snyk Security Database (P15)

Before adopting a new package, review its security health — not just known CVEs but maintenance activity, download trends, and community signals.

```
https://security.snyk.io/package/npm/<package-name>
# Example: https://security.snyk.io/package/npm/lodash
```

Provides: known CVEs, download trends, release frequency, contributor activity, overall health score.

---

## 16. Do Not Trust the Official npmjs.org Registry UI (P16)

The npmjs.org website omits git/HTTPS dependencies from display even when declared in `package.json`. The source code shown on the website can differ from the actual tarball installed by `npm install`.

**Inspect the actual tarball:**
```bash
# List tarball contents without downloading
npm pack <package-name> --dry-run

# Download and inspect
npm pack <package-name>
tar -tzf <package-name>-<version>.tgz
```

Use npq (§4.1) to audit packages before installation — it consults multiple security data sources beyond what npmjs.org displays.

---

## 17. Prevent Dependency Confusion Attacks (P17)

If your organisation uses a private registry alongside the public registry, an attacker can publish a same-named package to the public registry at a higher version number. The package manager resolves the higher version — from the attacker's public package.

**Step 1: Use scoped names for all internal packages.**
```json
{ "name": "@yourcompany/my-internal-tool" }
```

**Step 2: Route your org scope exclusively to your private registry.**
```ini
# .npmrc — commit this file; never commit auth tokens
@yourcompany:registry=https://npm.yourcompany.com/
```

**Yarn (v2+):**
```yaml
# .yarnrc.yml
npmScopes:
  yourcompany:
    npmRegistryServer: "https://npm.yourcompany.com/"
```

**pnpm** reads `.npmrc` and supports the same per-scope registry configuration.

**Why scoped names are essential:** Unscoped private package names (e.g. `my-company-utils`) can be claimed by anyone on the public registry. Scoped packages (`@yourcompany/utils`) are tied to your npm organisation — others cannot publish under your scope.

**Additional mitigations:**
- Claim unscoped internal package names on npmjs.org with placeholder packages
- Use `lockfile-lint` (§5) to verify resolved URLs point to expected registries
- Enable `blockExoticSubdeps` in pnpm (§2.1) to prevent transitive deps from using unexpected sources

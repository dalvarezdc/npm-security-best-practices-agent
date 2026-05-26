# npm-security-best-practices — Agent Skill

An agent skill for `gemini-cli` and `opencode` that enforces the [npm Security Best Practices](https://github.com/lirantal/npm-security-best-practices) guide by Liran Tal. When triggered, the skill provides concrete, copy/paste-ready configurations and step-by-step instructions covering 17 security practices across npm, pnpm, Bun, and Yarn.

---

## What the skill does

The skill loads when an agent detects security-relevant npm/package-manager activity and provides:

- **Immediate copy/paste configs** — hardened `.npmrc` and `pnpm-workspace.yaml` baselines the agent can drop directly into a user project.
- **Hardened `npx` execution** — a two-step offline pattern preventing live registry fetches at execution time.
- **A 17-practice quick-reference table** — severity ratings and the exact configuration key for each practice.
- **Full detail on demand** — `references/reference.md` contains the complete condensed reference for every practice, including Bun, Yarn, Dependabot, Renovate, and Snyk equivalents.

---

## When the skill activates

The skill loads automatically when you are about to:

- Run `npm install`, `pnpm add`, `bun add`, `yarn add`, or `npx`
- Write or review `.npmrc`, `pnpm-workspace.yaml`, `bunfig.toml`, or `.yarnrc.yml`
- Review or commit a lockfile (`package-lock.json`, `pnpm-lock.yaml`, `bun.lock`)
- Configure Dependabot, Renovate, or Snyk automated dependency PRs
- Publish a package to the npm registry
- Evaluate a new npm dependency for adoption

---

## The 17 practices at a glance

| # | Practice | Severity |
|---|----------|----------|
| 1 | Disable post-install scripts | **Critical** |
| 1.1 | pnpm: allowBuilds allowlist | High |
| 1.4 | pnpm trust policy no-downgrade | High |
| 2 | Block git-based dependencies | **Critical** |
| 2.1 | pnpm blockExoticSubdeps | High |
| 3 | Install with cooldown | High |
| 4 | Harden installs (npq / sfw) | High |
| 5 | Prevent lockfile injection | High |
| 6 | Use `npm ci` not `npm install` | High |
| 7 | Avoid blind package upgrades | Medium |
| 8 | Harden npx execution | **Critical** |
| 9 | No plaintext secrets in .env | **Critical** |
| 10 | Work in dev containers | Medium |
| 11 | Enable 2FA for npm accounts | **Critical** |
| 12 | Publish with provenance | High |
| 13 | Publish with OIDC | High |
| 14 | Reduce dependency tree | Medium |
| 15 | Consult Snyk Security Database | Medium |
| 16 | Don't trust npmjs.org UI | Medium |
| 17 | Prevent dependency confusion | High |

---

## Skill assets

The `assets/` directory contains ready-to-use configuration files agents can copy directly into user projects:

| File | Description |
|------|-------------|
| `assets/.npmrc` | Hardened npm baseline — `ignore-scripts`, `allow-git=none`, `min-release-age=30` |
| `assets/pnpm-workspace.yaml` | Hardened pnpm baseline — `minimumReleaseAge`, `trustPolicy`, `allowBuilds`, `strictDepBuilds`, `blockExoticSubdeps` |
| `assets/npx-offline-pattern.sh` | Two-step hardened npx execution script (pre-install workspace + offline-only invocation) |

Full practice documentation is in `references/reference.md`.

---

## Installation

### Installation for Gemini CLI

Since Gemini CLI supports the GitHub CLI skills extension, you can install this directly from the subfolder by running:

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

### Installation for Opencode

To use this skill in Opencode, add it to your project by running:

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

Or manually link it in your `.opencode/skills.yaml` file:

```yaml
skills:
  - name: npm-security-best-practices
    path: https://github.com/dalvarezdc/npm-security-best-practices-agent
    subpath: skills/npm-security-best-practices
```

---

## License

MIT — see [LICENSE](./LICENSE).

The underlying security practices are sourced from the [npm-security-best-practices](https://github.com/lirantal/npm-security-best-practices) project by Liran Tal and contributors. This skill is an independent packaging for agent use and is not affiliated with that project.

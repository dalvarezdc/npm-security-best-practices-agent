# npm-security-best-practices — Agent Skill

An agent skill that **implements basic npm supply-chain hardening in the repository it is working in**, based on the [npm Security Best Practices](https://github.com/lirantal/npm-security-best-practices) guide by Liran Tal.

Default baseline includes lifecycle-script blocking, git-dep blocking, and a **14-day install cooldown**, with merge-safe application of configs from `assets/`.

---

## What the skill does

When loaded, the agent should:

1. Detect the package manager and existing config in the current project
2. **Merge** (not overwrite) security keys from `assets/`
3. Follow task-specific checklists: `apply` | `audit` | `npx` | `publish` | `adopt-dep`
4. Open `references/reference.md` only for practice detail it actually needs

Assets:

| File | Role |
|------|------|
| `assets/.npmrc` | Canonical npm baseline — **merge** into project `.npmrc` |
| `assets/pnpm-workspace.yaml` | Canonical pnpm security keys — **merge** into existing workspace file |
| `assets/npx-offline-pattern.sh` | Offline npx helper: `install` / `run` / `update` |

---

## When it activates

- Hardening or reviewing npm/pnpm/yarn/bun security in a repo
- `npm install`, `pnpm add`, `bun add`, `yarn add`, or `npx`
- Editing `.npmrc`, `pnpm-workspace.yaml`, `bunfig.toml`, `.yarnrc.yml`
- Lockfile review; Dependabot / Renovate / Snyk setup
- Publishing or evaluating a new dependency

---

## Installation

### Grok

User skill (recommended while developing this repo):

```bash
mkdir -p ~/.grok/skills
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.grok/skills/npm-security-best-practices
```

Or install the repo as a plugin (plugin-shaped `skills/` layout):

```bash
grok plugin install . --trust
# or: grok plugin install dalvarezdc/npm-security-best-practices-agent --trust
```

Verify: `grok inspect` or `/skills` in the TUI. Invoke: `/npm-security-best-practices`.

### Gemini CLI

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

### Opencode

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

Or in `.opencode/skills.yaml`:

```yaml
skills:
  - name: npm-security-best-practices
    path: https://github.com/dalvarezdc/npm-security-best-practices-agent
    subpath: skills/npm-security-best-practices
```

### Manual / other agents

Copy or symlink `skills/npm-security-best-practices` into the agent’s skills directory (must contain `SKILL.md`).

---

## Baseline policy

| Setting | Value |
|---------|--------|
| npm `min-release-age` | `14` (days) |
| pnpm `minimumReleaseAge` | `20160` (minutes = 14 days) |
| bun `minimumReleaseAge` | `1209600` (seconds = 14 days) |
| yarn `npmMinimalAgeGate` | `14d` |

Canonical files: `assets/.npmrc`, `assets/pnpm-workspace.yaml`.

---

## License

MIT — see [LICENSE](./LICENSE).

The underlying security practices are sourced from the [npm-security-best-practices](https://github.com/lirantal/npm-security-best-practices) project by Liran Tal and contributors. This skill is an independent packaging for agent use and is not affiliated with that project.

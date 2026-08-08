# npm-security-best-practices — Agent Skill

Independent agent skill that **implements basic npm / pnpm / yarn / bun supply-chain hardening in the repository it is working in**.

Default baseline: block lifecycle scripts, block git deps, **14-day install cooldown**. Configs are **merged** from `assets/` into the target project.

This package is a **standalone skill product** (procedure + assets + evals), not an official fork of any third-party awesome list.

| Path | Role |
|------|------|
| `SKILL.md` | Agent procedure |
| `assets/.npmrc` | Canonical npm baseline |
| `assets/pnpm-workspace.yaml` | Canonical pnpm security keys |
| `assets/npx-offline-pattern.sh` | Offline npx helper (`install` / `run` / `update`) |
| `references/reference.md` | Detail for P01–P17 |
| `evals.md` | Expected agent behaviors |

Full product docs (usage + install for every agent):  
[../../README.md](../../README.md)

---

## Usage recommendations

### Goal

Harden **the current project** against common npm malware paths—not dump a long security essay.

### When to invoke

- New repo or missing install hardening  
- Before/while installing dependencies  
- Lockfile or dependency PRs (`audit` mode)  
- MCP / tools via `npx`  
- Publishing or evaluating a new package  

### Example prompts

**Apply (default):**

```text
Apply the npm-security-best-practices skill to this repository.
Merge the baseline; do not overwrite registry scopes or workspace packages.
Summarize what changed.
```

**Audit only:**

```text
Audit this repo against npm-security-best-practices. Report gaps; do not modify files.
```

**Modes:** `apply` | `audit` | `npx` | `publish` | `adopt-dep`

```text
/npm-security-best-practices apply
/npm-security-best-practices audit
```

### Best results

1. Run the agent in the **target app root**, not only this skill repo.  
2. **Merge** configs—never wipe `@scope:registry` or pnpm `packages:`.  
3. Prefer **`audit` then `apply`** on production monorepos.  
4. After `ignore-scripts`, allow native builds only for packages you trust.  
5. Keep the **14-day** gate; use package-scoped exceptions for urgent CVEs.  
6. Use `assets/npx-offline-pattern.sh` (or equivalent offline flags) for sensitive `npx`.  
7. Commit hardened config so the team and CI inherit it.  
8. This is a **baseline**, not a full security audit.

### Success criteria (`apply`)

- Baseline keys present (`ignore-scripts`, `allow-git=none`, `min-release-age=14`, plus pnpm keys when relevant)  
- Existing workspace/registry settings preserved  
- Short change summary for the user  

---

## Installation

**Repo:** https://github.com/dalvarezdc/npm-security-best-practices-agent  
**Skill dir:** `skills/npm-security-best-practices` (must contain `SKILL.md`)

```bash
git clone https://github.com/dalvarezdc/npm-security-best-practices-agent.git
cd npm-security-best-practices-agent
```

| Agent | Command |
|-------|---------|
| **Grok** | `ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.grok/skills/npm-security-best-practices` · or `grok plugin install dalvarezdc/npm-security-best-practices-agent --trust` |
| **Claude Code** | `ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.claude/skills/npm-security-best-practices` |
| **Gemini CLI** | `gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices` |
| **OpenAI Codex** | Symlink into `~/.codex/skills/` and/or `~/.agents/skills/` (or project `.agents/skills/`) |
| **DeepSeek** | Symlink into the product skills path (e.g. `~/.deepseek/skills/`) |
| **OpenCode** | `opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices` |
| **Cursor** | `ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.cursor/skills/npm-security-best-practices` |
| **Manual** | Copy or symlink this directory into the agent’s skills root |

### Grok

```bash
mkdir -p ~/.grok/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.grok/skills/npm-security-best-practices
# or: grok plugin install . --trust
```

Verify: `grok inspect` or `/skills` · Invoke: `/npm-security-best-practices`

### Claude Code

```bash
mkdir -p ~/.claude/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.claude/skills/npm-security-best-practices
```

### Gemini CLI

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

### OpenAI Codex

```bash
mkdir -p ~/.codex/skills ~/.agents/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.codex/skills/npm-security-best-practices
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.agents/skills/npm-security-best-practices
```

### DeepSeek / other SKILL.md hosts

```bash
mkdir -p ~/.deepseek/skills   # or your product’s documented path
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.deepseek/skills/npm-security-best-practices
```

### OpenCode

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

### Cursor

```bash
mkdir -p ~/.cursor/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.cursor/skills/npm-security-best-practices
```

### Manual

```bash
cp -R skills/npm-security-best-practices /path/to/<agent>/skills/npm-security-best-practices
# or: ln -sfn "$(pwd)/skills/npm-security-best-practices" /path/to/<agent>/skills/npm-security-best-practices
```

### After install

1. Reload / restart the agent if needed.  
2. Open a **real app repository**.  
3. Run an apply or audit prompt from above.  
4. Review and commit config diffs.

### Updating

```bash
git pull   # symlink installs update in place
# copy installs: re-copy the skill directory
# Grok plugin: grok plugin update
```

---

## Baseline policy

| Setting | Value |
|---------|--------|
| npm `min-release-age` | `14` (days) |
| pnpm `minimumReleaseAge` | `20160` (minutes) |
| bun `minimumReleaseAge` | `1209600` (seconds) |
| yarn `npmMinimalAgeGate` | `14d` |

Canonical files: `assets/.npmrc`, `assets/pnpm-workspace.yaml`.

---

## License

MIT — see [LICENSE](./LICENSE).

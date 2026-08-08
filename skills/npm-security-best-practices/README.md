# npm-security-best-practices — Agent Skill

Independent agent skill that **implements basic npm / pnpm / yarn / bun supply-chain hardening in the repository it is working in**.

Default baseline: block lifecycle scripts, block git deps, **14-day install cooldown**. Configs are **merged** from `assets/` into the target project.

This package is maintained as a **standalone skill product** (procedure + assets + evals). It is not an official fork of any third-party awesome list; public community research informed the threat model.

---

## What it does

1. Detect package manager and existing config  
2. Merge security keys from `assets/` (never wipe workspace/registry settings)  
3. Task modes: `apply` | `audit` | `npx` | `publish` | `adopt-dep`  
4. Open `references/reference.md` only for practice IDs that matter  

| Path | Role |
|------|------|
| `SKILL.md` | Agent procedure |
| `assets/.npmrc` | Canonical npm baseline |
| `assets/pnpm-workspace.yaml` | Canonical pnpm security keys |
| `assets/npx-offline-pattern.sh` | `install` / `run` / `update` offline npx helper |
| `references/reference.md` | Detail for P01–P17 |
| `evals.md` | Expected agent behaviors |

---

## Install

Repo: `https://github.com/dalvarezdc/npm-security-best-practices-agent`  
Skill dir: `skills/npm-security-best-practices`

### Grok

```bash
mkdir -p ~/.grok/skills
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.grok/skills/npm-security-best-practices

# or: grok plugin install dalvarezdc/npm-security-best-practices-agent --trust
```

### Claude Code

```bash
mkdir -p ~/.claude/skills
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.claude/skills/npm-security-best-practices
```

### Gemini CLI

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

### OpenAI Codex / agents skills dirs

```bash
mkdir -p ~/.codex/skills ~/.agents/skills
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.codex/skills/npm-security-best-practices
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.agents/skills/npm-security-best-practices
```

### DeepSeek (and other SKILL.md hosts)

```bash
mkdir -p ~/.deepseek/skills   # or the path your product documents
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.deepseek/skills/npm-security-best-practices
```

### OpenCode

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

### Cursor

```bash
mkdir -p ~/.cursor/skills
ln -s /path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
  ~/.cursor/skills/npm-security-best-practices
```

### Manual

Copy or symlink the `skills/npm-security-best-practices` directory (must contain `SKILL.md`) into the agent’s skills root.

---

## Baseline policy

| Setting | Value |
|---------|--------|
| npm `min-release-age` | `14` (days) |
| pnpm `minimumReleaseAge` | `20160` (minutes) |
| bun `minimumReleaseAge` | `1209600` (seconds) |
| yarn `npmMinimalAgeGate` | `14d` |

---

## License

MIT — see [LICENSE](./LICENSE).

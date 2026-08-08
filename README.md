# npm Security Best Practices — Agent Skill

**Independent agent skill** that hardens the repository you are working in against npm (and pnpm / yarn / bun) supply-chain malware patterns: malicious `postinstall` scripts, git-sourced deps, brand-new compromised releases, unsafe `npx`, lockfile tricks, and related risks.

This is **not** an official fork or continuation of any third-party awesome list. It is a standalone product: a procedure-first skill, copyable baselines, and a long-form practice guide for humans. Community research (including public write-ups by [Liran Tal](https://github.com/lirantal) and others) informed the threat model; ownership, baseline policy, and agent workflow are this project’s.

| | |
|---|---|
| **Skill** | [`skills/npm-security-best-practices/`](./skills/npm-security-best-practices/) |
| **Baseline** | 14-day install cooldown + lifecycle/git hardening |
| **Canonical configs** | [`skills/npm-security-best-practices/assets/`](./skills/npm-security-best-practices/assets/) |
| **Human guide** | [`docs/practices-guide.md`](./docs/practices-guide.md) |
| **This repo** | Ships a root [`.npmrc`](./.npmrc) so the project itself is protected if npm/npx is used here |

---

## What the skill does

When an agent loads it, it should:

1. Detect package manager + existing config in the **current** project  
2. **Merge** security keys (never blind-overwrite workspace/registry settings)  
3. Apply the minimum baseline (scripts off, no git deps, 14-day age gate)  
4. Use task modes: `apply` | `audit` | `npx` | `publish` | `adopt-dep`  
5. Pull detail from `references/reference.md` only when needed  

---

## Install the skill

Skill path in this repo:

```text
skills/npm-security-best-practices/
```

### Grok

```bash
# User skill (good for local development of this repo)
mkdir -p ~/.grok/skills
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.grok/skills/npm-security-best-practices

# Or install the whole repo as a plugin
grok plugin install . --trust
# grok plugin install dalvarezdc/npm-security-best-practices-agent --trust
```

Invoke: `/npm-security-best-practices` · verify: `grok inspect` or `/skills`

### Claude Code

```bash
mkdir -p ~/.claude/skills
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.claude/skills/npm-security-best-practices
# Project-scoped alternative:
# mkdir -p .claude/skills && ln -s ../../skills/npm-security-best-practices .claude/skills/npm-security-best-practices
```

### Gemini CLI

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

### OpenAI Codex / ChatGPT agent-style skills

Codex and compatible harnesses that scan skill directories:

```bash
# User-level (adjust if your Codex skills path differs)
mkdir -p ~/.codex/skills ~/.agents/skills
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.codex/skills/npm-security-best-practices
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.agents/skills/npm-security-best-practices

# Or project-scoped (often discovered as .agents/skills)
mkdir -p .agents/skills
ln -s ../../skills/npm-security-best-practices .agents/skills/npm-security-best-practices
```

### DeepSeek (and other SKILL.md-compatible agents)

If the agent loads `SKILL.md` from a skills root:

```bash
mkdir -p ~/.deepseek/skills   # or your product’s documented skills path
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.deepseek/skills/npm-security-best-practices
```

If the product has no fixed path, copy or symlink `skills/npm-security-best-practices` into whatever directory it documents for custom skills (the folder must contain `SKILL.md`).

### OpenCode

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

### Cursor

```bash
mkdir -p ~/.cursor/skills
ln -s "$(pwd)/skills/npm-security-best-practices" ~/.cursor/skills/npm-security-best-practices
```

### Manual (any agent)

```bash
cp -R skills/npm-security-best-practices /path/to/<agent>/skills/npm-security-best-practices
# or symlink (stays in sync with git pulls)
```

---

## TL;DR baseline (14 days)

Canonical files:  
`skills/npm-security-best-practices/assets/.npmrc`  
`skills/npm-security-best-practices/assets/pnpm-workspace.yaml`

<details>
  <summary>.npmrc</summary>

```ini
ignore-scripts=true
allow-git=none
min-release-age=14
```

</details>

<details>
  <summary>pnpm security keys (merge into pnpm-workspace.yaml)</summary>

```yaml
minimumReleaseAge: 20160   # 14 days in minutes
trustPolicy: no-downgrade
strictDepBuilds: true
blockExoticSubdeps: true
# allowBuilds:   # add packages only after vetting native builds
#   esbuild: true
```

</details>

**Rules for agents and humans:** merge keys into existing config; do not wipe `packages:`, catalogs, or `@scope:registry` lines.

---

## Repository self-protection

This repo applies the same npm baseline at the root:

- [`.npmrc`](./.npmrc) — `ignore-scripts`, `allow-git=none`, `min-release-age=14`

There is intentionally no application `package.json` dependency tree yet; the baseline still protects ad-hoc `npm` / `npx` usage in the tree. When dependencies are added, keep this `.npmrc` and prefer frozen lockfile installs in CI.

Offline `npx` helper:

```bash
./skills/npm-security-best-practices/assets/npx-offline-pattern.sh install <package>
./skills/npm-security-best-practices/assets/npx-offline-pattern.sh run <package> -- [args...]
```

---

## Development checks

```bash
./scripts/check-skill.sh
```

CI runs the same script on pull requests (skill package integrity + baseline consistency).

Agent behavior fixtures: [`skills/npm-security-best-practices/evals.md`](./skills/npm-security-best-practices/evals.md).

---

## Layout

```text
.
├── .npmrc                          # this repo’s npm baseline
├── skills/npm-security-best-practices/
│   ├── SKILL.md                    # agent procedure
│   ├── assets/                     # canonical configs + npx helper
│   ├── references/reference.md     # practice detail P01–P17
│   └── evals.md                    # expected agent behaviors
├── docs/practices-guide.md         # long-form human guide
└── scripts/check-skill.sh
```

---

## License

- **Skill package** (`skills/npm-security-best-practices/`): MIT — see skill `LICENSE`  
- **Repository / guide materials:** Apache-2.0 — see root `LICENSE`  

---

## Attribution

Threat model and many concrete controls are aligned with public npm supply-chain guidance. This repository’s skill procedure, 14-day baseline, assets, evals, and multi-agent packaging are maintained independently by the project authors.

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

## Usage recommendations

### When to use it

| Situation | What to ask the agent |
|-----------|------------------------|
| New or unhardened app/repo | *“Apply npm security best practices”* / *“Harden package installs in this repo”* |
| Before trusting `npm install` / `pnpm add` | *“Check our install config against the security baseline first”* |
| Reviewing a PR that changes lockfiles or deps | *“Audit npm hardening; don’t change files”* |
| Wiring MCP servers or tools via `npx` | *“Set up this package with the offline npx pattern”* |
| Publishing a package | *“Harden our publish path (2FA, OIDC, provenance)”* |
| Adopting a new dependency | *“Evaluate this package before we add it”* |

**Good default prompt (most projects):**

```text
Apply the npm-security-best-practices skill to this repository.
Merge the baseline into existing config; do not overwrite registry scopes or workspace packages.
Summarize what changed.
```

**Audit-only (no writes):**

```text
Audit this repo against npm-security-best-practices. Report gaps only; do not modify files.
```

### Task modes

The skill routes work by intent. You can name the mode explicitly:

| Mode | Intent | Example prompt |
|------|--------|----------------|
| **`apply`** (default) | Merge baseline into this repo | *“Harden npm security here”* |
| **`audit`** | Report gaps, no edits | *“Audit npm hardening only”* |
| **`npx`** | Offline / lockfile-backed npx | *“Install and run X safely with npx”* |
| **`publish`** | Maintainer publish hygiene | *“Help me publish securely”* |
| **`adopt-dep`** | Vet a new dependency | *“Should we depend on package Y?”* |

Slash-style (where supported, e.g. Grok):

```text
/npm-security-best-practices
/npm-security-best-practices apply
/npm-security-best-practices audit
/npm-security-best-practices npx
```

### Recommendations for best results

1. **Run it in the target project root** (the app monorepo), not only in this skill repo. The skill hardens *whatever cwd the agent is in*.  
2. **Prefer merge over copy.** Existing `@scope:registry=…`, `packages:`, and catalogs must stay.  
3. **Start with `audit` on large/production repos**, then `apply` once you accept the diff.  
4. **Expect friction after `ignore-scripts=true`.** Native modules may need an explicit `allowBuilds` (pnpm) or equivalent—add packages only after you trust them.  
5. **Keep the 14-day gate.** For urgent CVEs, allow a *package-scoped* exception; don’t disable the global cooldown.  
6. **Use the offline npx helper** for MCP and other tools with FS/network access—don’t leave bare `npx <pkg>` as steady state.  
7. **Align bots with the local gate.** Dependabot / Renovate cooldowns should be ~14 days when possible so PRs don’t fight `.npmrc`.  
8. **Commit the config changes** (`.npmrc`, workspace keys) so CI and teammates inherit the baseline.  
9. **Don’t treat the skill as a full security audit.** It’s a high-leverage install baseline, not AppSec sign-off.  
10. **Install once per agent user or per team project**—user-global for personal defaults; project-scoped skills for shared team policy.

### What you should see after a good `apply`

- `.npmrc` (or equivalent) includes at least `ignore-scripts=true`, `allow-git=none`, `min-release-age=14`  
- pnpm projects: security keys merged into `pnpm-workspace.yaml` without losing `packages:`  
- Short summary of edits + any follow-ups (e.g. packages that need build allowlisting)  
- No full dump of the 17-practice encyclopedia unless you asked for detail  

### When *not* to use it alone

- You need a full dependency CVE remediation plan (use your scanner + this skill’s baseline together).  
- You must allow git dependencies or install scripts by policy—review exceptions deliberately; don’t auto-weaken the baseline.  
- The agent is not allowed to edit config files—use **`audit`** mode only.

---

## Installation

Skill directory in this repository:

```text
skills/npm-security-best-practices/
```

That folder must stay intact (`SKILL.md`, `assets/`, `references/`). Install by pointing your agent at it (symlink, copy, plugin, or marketplace command).

### Prerequisites

- Git clone of this repo **or** a skill-install CLI that can pull from GitHub  
- An agent that loads `SKILL.md`-style skills  
- Absolute paths work more reliably than relative ones for symlinks  

```bash
git clone https://github.com/dalvarezdc/npm-security-best-practices-agent.git
cd npm-security-best-practices-agent
```

### Quick install by agent

| Agent | Install |
|-------|---------|
| **Grok** | Symlink into `~/.grok/skills/` **or** `grok plugin install …` |
| **Claude Code** | Symlink into `~/.claude/skills/` (or project `.claude/skills/`) |
| **Gemini CLI** | `gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices` |
| **OpenAI Codex** | Symlink into `~/.codex/skills/` and/or `~/.agents/skills/` |
| **DeepSeek** | Symlink into the product’s skills directory (or `~/.deepseek/skills/` if used) |
| **OpenCode** | `opencode skill add https://github.com/dalvarezdc/…/skills/npm-security-best-practices` |
| **Cursor** | Symlink into `~/.cursor/skills/` |
| **Any other** | Copy/symlink the skill folder into that agent’s skills root |

### Grok

```bash
# From this repo root — user-wide skill (recommended while developing the skill)
mkdir -p ~/.grok/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.grok/skills/npm-security-best-practices

# Or install the repo as a Grok plugin (plugin-shaped skills/ layout)
grok plugin install . --trust
# From GitHub:
# grok plugin install dalvarezdc/npm-security-best-practices-agent --trust
```

**Use:** `/npm-security-best-practices` or natural language (*“harden npm in this repo”*).  
**Verify:** `grok inspect` or `/skills`.

### Claude Code

```bash
# User-wide
mkdir -p ~/.claude/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.claude/skills/npm-security-best-practices

# Project-scoped (share with the team via git — run from the *target app* repo)
# mkdir -p .claude/skills
# ln -sfn /absolute/path/to/npm-security-best-practices-agent/skills/npm-security-best-practices \
#   .claude/skills/npm-security-best-practices
```

**Use:** ask Claude to apply npm security best practices / harden installs in the current project.

### Gemini CLI

```bash
gh skill install dalvarezdc/npm-security-best-practices-agent npm-security-best-practices
```

Requires [GitHub CLI](https://cli.github.com/) and Gemini’s skills extension support.

### OpenAI Codex / ChatGPT agent-style skills

```bash
# User-level (adjust if your Codex build uses a different skills path)
mkdir -p ~/.codex/skills ~/.agents/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.codex/skills/npm-security-best-practices
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.agents/skills/npm-security-best-practices

# Project-scoped (discovered as .agents/skills in many harnesses)
mkdir -p .agents/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" .agents/skills/npm-security-best-practices
```

### DeepSeek (and other SKILL.md-compatible agents)

```bash
# Prefer the path documented by your DeepSeek / agent product
mkdir -p ~/.deepseek/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.deepseek/skills/npm-security-best-practices
```

If the product has no fixed path, copy or symlink `skills/npm-security-best-practices` into its custom-skills directory (the folder must contain `SKILL.md`).

### OpenCode

```bash
opencode skill add https://github.com/dalvarezdc/npm-security-best-practices-agent/tree/main/skills/npm-security-best-practices
```

### Cursor

```bash
mkdir -p ~/.cursor/skills
ln -sfn "$(pwd)/skills/npm-security-best-practices" ~/.cursor/skills/npm-security-best-practices
```

### Manual (any agent)

```bash
# Copy (snapshot)
cp -R skills/npm-security-best-practices /path/to/<agent>/skills/npm-security-best-practices

# Or symlink (tracks git updates to this clone)
ln -sfn "$(pwd)/skills/npm-security-best-practices" /path/to/<agent>/skills/npm-security-best-practices
```

### After installing

1. Restart the agent session (or reload skills) if the skill does not appear immediately.  
2. Open a **real application repo** and run an `apply` or `audit` prompt from [Usage recommendations](#usage-recommendations).  
3. Review the diff before committing—especially monorepos and private registry configs.

### Updating

```bash
cd /path/to/npm-security-best-practices-agent
git pull

# Symlink installs pick up changes automatically.
# Copy installs: re-run cp -R …
# Grok plugin: grok plugin update
# Gemini: re-run gh skill install … if your toolchain does not auto-update
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

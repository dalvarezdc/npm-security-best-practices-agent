# npm Security Best Practices Skill — Design

**Date:** 2026-05-26
**Source:** README.md in this repository (17 practices)

## Goal

Transform the curated npm security best practices into a superpowers-compatible
skill that agents can load when making decisions about package installation,
dependency management, lockfile security, and npm publishing.

## Skill Type

Reference skill — not a workflow/discipline enforcer. Agents load it to consult
specific practices relevant to their current task.

## Triggering Conditions

Agent should load the skill when:
- Installing npm packages (npm install, pnpm add, npx, etc.)
- Setting up or reviewing .npmrc / pnpm-workspace.yaml / bunfig.toml
- Auditing a project's dependency configuration
- Reviewing or committing lockfiles
- Running npx for MCP servers or one-off tools
- Configuring automated dependency updates (Dependabot, Renovate, Snyk)
- Publishing an npm package
- Evaluating whether to adopt a new npm dependency

## Structure Decision

Two files:
1. SKILL.md — fast-path: triggering description, quick-ref table, critical configs
2. reference.md — condensed detail for all 17 practices

This follows the "Skill with Heavy Reference" pattern from writing-skills/SKILL.md.

## Content Mapping (README → Skill)

| Practice | Section in README | Severity |
|---|---|---|
| 1. Disable post-install scripts | §1 | Critical |
| 1.1 pnpm disable scripts | §1.1 | High |
| 1.2 Bun disable scripts | §1.2 | High |
| 1.3 Run scripts you need (lavamoat) | §1.3 | Medium |
| 1.4 pnpm trust policy | §1.4 | High |
| 2. Block git-based deps | §2 | Critical |
| 2.1 pnpm blockExoticSubdeps | §2.1 | High |
| 3. Install with cooldown | §3 | High |
| 3.1 min-release-age across PMs | §3.1 | High |
| 3.2-3.4 Snyk/Dependabot/Renovate | §3.2-3.4 | Medium |
| 4. Harden installs (npq, sfw) | §4 | High |
| 5. Prevent lockfile injection | §5 | High |
| 6. Use npm ci | §6 | High |
| 7. Avoid blind upgrades | §7 | Medium |
| 8. Harden npx execution | §8 | Critical |
| 9. No plaintext secrets in .env | §9 | Critical |
| 10. Dev containers | §10 | Medium |
| 11. 2FA for npm accounts | §11 | Critical (maintainers) |
| 12. Publish with provenance | §12 | High (maintainers) |
| 13. Publish with OIDC | §13 | High (maintainers) |
| 14. Reduce dependency tree | §14 | Medium (maintainers) |
| 15. Consult Snyk DB | §15 | Medium |
| 16. Don't trust npmjs.org UI | §16 | Medium |
| 17. Prevent dependency confusion | §17 | High |

## Decisions

- description field: starts with "Use when...", no workflow summary, third-person
- Quick-ref table in SKILL.md groups practices by domain (install-time, dev env, maintainer, evaluation)
- SKILL.md includes the three most critical copy-paste configs (.npmrc, pnpm-workspace.yaml snippet, npx hardening pattern)
- reference.md preserves all config code blocks; removes HTML badges, footnotes, and marketing prose
- No tests required (reference skill, not discipline-enforcing — see writing-skills §Testing Reference Skills)

# Changelog

All notable changes to the `npm-security-best-practices` skill are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This skill uses [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2026-05-27

### Added

- Initial release of the `npm-security-best-practices` agent skill for `gemini-cli` and `opencode`.
- `SKILL.md`: Frontmatter-driven skill trigger with a 17-practice quick-reference table and copy/paste configs. Updated to reference nested `references/` and `assets/` paths.
- `references/reference.md`: Moved from the skill root into a dedicated `references/` subdirectory. Contains the full condensed reference for all 17 practices across npm, pnpm, Bun, and Yarn.
- `assets/.npmrc`: Hardened npm configuration baseline (`ignore-scripts=true`, `allow-git=none`, `min-release-age=30`) with inline security commentary. Directly copyable to any project root.
- `assets/pnpm-workspace.yaml`: Hardened pnpm workspace configuration baseline (`minimumReleaseAge`, `trustPolicy: no-downgrade`, `allowBuilds`, `strictDepBuilds`, `blockExoticSubdeps`) with inline security commentary and version requirements.
- `assets/npx-offline-pattern.sh`: Self-documenting shell script implementing the two-step hardened `npx` execution pattern (pre-install workspace + offline-only invocation). Directly executable.
- `SKILLCARD.yaml`: Machine-readable skill metadata including name, description, author (`dalvarezdc`), version, compatibility tags (`gemini-cli`, `opencode`), trigger description, and asset/reference index.
- `LICENSE`: MIT License covering the skill itself (copyright dalvarezdc).
- `README.md`: Human-readable skill documentation with installation instructions for both `gemini-cli` and `opencode`.

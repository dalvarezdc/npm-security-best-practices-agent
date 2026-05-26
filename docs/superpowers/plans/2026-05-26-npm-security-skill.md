# npm Security Best Practices → Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform this repo's README into a superpowers-compatible skill (`SKILL.md` + `reference.md`) that agents can load when installing, auditing, or configuring npm packages.

**Architecture:** Two files inside `skills/npm-security-best-practices/`. `SKILL.md` is the fast-path entry point: YAML frontmatter, triggering description, quick-reference table of all 17 practices, and the most critical copy-paste config snippets. `reference.md` is the full condensed detail for all 17 practices — distilled from the README but free of HTML, badges, and prose padding.

**Tech Stack:** Markdown only. No build step. No code execution. The skill follows the superpowers SKILL.md specification (`name`, `description` YAML frontmatter; third-person description starting with "Use when..."; CSO keyword coverage).

---

## File Map

| File | Status | Purpose |
|------|--------|---------|
| `skills/npm-security-best-practices/SKILL.md` | **Create** | Entry point: frontmatter, triggers, quick-ref table, critical config snippets, pointer to reference.md |
| `skills/npm-security-best-practices/reference.md` | **Create** | Full condensed detail for all 17 practices |
| `docs/superpowers/specs/2026-05-26-npm-security-skill-design.md` | **Create** | Design doc (this session's brainstorming output) |
| `docs/superpowers/plans/2026-05-26-npm-security-skill.md` | **Create** | This plan |

---

## Task 1: Create directory structure and design/plan docs

- [x] Create docs/ and skills/ directory trees
- [x] Write design doc to docs/superpowers/specs/
- [x] Write plan to docs/superpowers/plans/
- [x] Commit

## Task 2: Write SKILL.md

- [ ] Write skills/npm-security-best-practices/SKILL.md
- [ ] Word-count check (target <600 words)
- [ ] Frontmatter character count check (≤1024 chars)
- [ ] Commit

## Task 3: Write reference.md

- [ ] Write skills/npm-security-best-practices/reference.md
- [ ] Verify no HTML or badge syntax
- [ ] Commit

## Task 4: Self-review and CSO check

- [ ] Check frontmatter validity
- [ ] Check for placeholder language
- [ ] Check keyword coverage
- [ ] Fix any issues, commit if needed

## Task 5: Final verification

- [ ] Verify file structure
- [ ] Verify SKILL.md renders correctly
- [ ] Verify git log is clean

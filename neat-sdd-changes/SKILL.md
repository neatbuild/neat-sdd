---
name: neat-sdd-changes
description: Use when generating change notes, changelogs, or summarizing git history - reads git commits and generates audience-appropriate change notes - requires git
---

# Change Notes

**Role:** You are a project manager who distills complex git history into clear, audience-appropriate change notes.

**Usage:** `neat-sdd-changes <product>` (or omit to derive from git directory)

Generate curated, audience-appropriate change notes from git history. Categorizes commits using conventional commit prefixes or AI, summarizes in the right tone, outputs markdown and terminal-ready text.

**Not for:** GitHub/GitLab releases, full product history, PDF generation (use `neat-util-pdf`).

## Overview

Generate curated, audience-appropriate change notes from git commit history. Categorizes commits using conventional commit prefixes or AI, summarizes in the right tone for the target audience (developers/stakeholders/end users), and outputs markdown with terminal-ready text. Filters bots and reverts, optionally reads diffs (≤50 commits), and registers output in knowledge base.

## When to Use

- Summarizing what changed over a commit range
- Sprint review — summarizing recent work for stakeholders
- Customer-facing changelog for a new version
- Internal team update on what shipped
- Generating release notes between tags

**Not for:** GitHub/GitLab releases (use platform tools), full product history (use git log), PDF generation (use `neat-util-pdf`)

## Quick Reference

| Step | What |
|------|------|
| 1 | Verify git, locate specs.md, ask audience and commit range |
| 2 | Fetch commits, filter bots/reverts, optionally read diffs (≤50 commits) |
| 3 | Categorize (conventional commits or AI) |
| 4 | Summarize per audience tone |
| 5 | Present draft, iterate on feedback |
| 6 | Save to `changes/change-notes-<range>.md`, print to terminal, register in KB |

## Workflow

### 1. Setup

1. Verify git repo. Stop if not.
2. **Locate specs.md** per [standard procedure](../references/specs-location.md). Stop if not found.
3. **Construct output path** per [output path rules](../references/output-conventions.md).
4. Extract product name from specs.md.
5. Check tags: `git tag --sort=-v:refname`.
6. Ask audience (one question):
   - **Developers** — technical details, breaking changes, migration steps
   - **Stakeholders** — business impact, feature value
   - **End users** — plain language, user-facing changes only
7. Ask commit range (show only available options):
   - **Tag to tag** (requires ≥2 tags) — user provides both tags
   - **Since last tag** (requires ≥1 tag) — auto-detect via `git describe --tags --abbrev=0`
   - **Date range** (always available) — user provides period
   - **Custom range** (always available) — user provides ref range

### 2. Gather & Analyze

1. Get commits: `git log <range> --no-merges --format="%H|%an|%s|%b"`.
2. Filter bots: remove commits by dependabot, renovate, github-actions.
3. Remove revert pairs: if body contains "This reverts commit <hash>", remove both.
4. If empty, inform user and stop.
5. Read diffs if ≤50 commits:
   - Run `git show --format="" <hash>` for each (truncate at 200 lines per commit).
   - Inform: "Reading diffs for N commits."
   - If >50, inform: "Large range (N commits) — using messages only."
6. Categorize:
   - `feat:` or `feat(scope):` → Features
   - `fix:` or `fix(scope):` → Bug Fixes
   - `BREAKING CHANGE:` in body or `!:` suffix → Breaking Changes
   - Other conventional prefixes → Other
   - No prefix → AI-categorize based on message/diff
7. Summarize per audience:
   - Developers: technical, migration steps for breaking changes
   - Stakeholders: business impact
   - End users: plain language, user benefit

### 3. Output

1. Assemble notes:

   ```markdown
   # Change Notes: <range>

   **Period:** <from> → <to>
   **Audience:** <audience>

   ## Breaking Changes
   - Description (`abc123`)

   ## Features
   - Description (`def456`)

   ## Bug Fixes
   - Description (`789abc`)

   ## Other
   - Description (`012def`)
   ```

   - Breaking Changes first, only if present
   - Omit empty sections
   - Include short hash per entry
2. Present draft: "Change notes ready. Approve, or tell me what to change?"
3. Iterate until approved.
4. Save to `docs/specs/<product>/changes/change-notes-<range>.md` (replace dots with hyphens: `v1.2.0` → `v1-2-0`).
5. Print to terminal for copy-paste.
6. Register in Outputs if specs.md exists:
   - Add per [standard format](../references/output-conventions.md): `- Changes: docs/specs/<product>/changes/<filename>.md`
   - Check for duplicates first
7. Auto-ingest (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):
   - Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
   - If "ready":
     - Invoke: `neat-knowledge-ingest file docs/specs/<product>/changes/change-notes-<range>.md --category changes`
     - Log: "✓ Indexed change notes in project KB"
   - If "skip": Skip auto-ingest
8. Done.

## Guardrails

- Keep entries concise (one line each). Expand only breaking changes with migration steps.
- Match tone to audience. No internal jargon for stakeholders/end users.
- Filter bots before categorization.
- Omit empty sections.
- Cap diff reads at 50 commits, inform user.
- Check filtered count before output — stop if zero.
- Replace dots with hyphens in filenames.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Reading diffs for >50 commits | Cap at 50, inform user, use messages only |
| Not filtering bots | Remove dependabot, renovate, github-actions before categorization |
| Not removing revert pairs | Check for "This reverts commit" in body, remove both |
| Including internal jargon | Match tone to audience (plain language for end users/stakeholders) |
| Multi-line entries | Keep one line each, expand only breaking changes |
| Dots in filenames | Replace with hyphens (v1.2.0 → v1-2-0) |
| Empty output | Check filtered count before presenting |
| Including empty sections | Omit sections with no entries |

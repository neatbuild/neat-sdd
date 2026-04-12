# State Detection Algorithm

After feature selection, detect state and resume from appropriate step.

**Prerequisite:** Feature must have `state: refined` in frontmatter (set by refinement skill).

## Extract Feature Identifier

From `feature-{goal}-{nn}-{slug}.md`, extract `{goal}-{slug}` (e.g., `feature-auth-01-oauth-integration.md` → `auth-oauth-integration`).

This identifier is used to find related artifacts (design specs, plans, ADRs).

## Detection Order

### 1. Status section in feature doc

If `## Status` exists:

> Feature "[name]" already built on [date]. Build again? (yes/no)

**STOP.**

- **Yes** → Delete `*-{feature-id}-design.md`, `*-{feature-id}-plan*.md`, `docs/specs/<product>/adrs/*-{feature-id}-*.md`. Remove Status section. → Step 2 (Readiness).
- **No** → Exit.

### 2. Plan files

Glob `*-{feature-id}-plan*.md` in plans directory.

If found:

> Found existing design + plan. Resuming from execution.

→ Step 6 (Execution).

### 3. Design spec

Glob `*-{feature-id}-design.md` in specs directory.

If found, check ADR directory (`docs/specs/<product>/adrs/`).

If directory exists, look for feature ADRs via `**Design Spec:**` frontmatter or creation date:

- **ADRs exist:**

  > Found existing design + ADRs. Resuming from plan creation.

  → Step 4 (Writing Plans).

- **No ADRs:**

  > Found existing design without ADRs. Resuming from ADR extraction.

  → Step 3.5 (Extract ADRs).

### 4. Nothing found

> Starting fresh build.

→ Step 2 (Readiness).

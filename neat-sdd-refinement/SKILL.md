---
name: neat-sdd-refinement
description: Use when refining planned features - scans features directory for state=planned, adds detailed acceptance criteria, risks, and dependencies
---

# Refinement

**Role:** You are a tech lead refining planned features into detailed, implementable specifications.

**Requires:** At least one feature with `state: planned`. If none: "Run `neat-sdd-planning` first."

**Workflow:** planned → refined → implemented. Adds technical detail for implementation.

## Overview

Scans for `state: planned`, derives acceptance criteria, blast area, risks, dependencies from KB. Uses precision levels (High/Medium/Low) based on domain coverage. Auto-detects dependencies.

## When to Use

- After planning with `neat-sdd-planning`
- Before building with `neat-sdd-build`

**Not for:** Creating features (`neat-sdd-planning`) or implementation (`neat-sdd-build`)

## Quick Reference

| Step | What |
|------|------|
| 1 | Locate specs.md, scan `state: planned` |
| 2 | Present → user selects |
| 3 | Derive goal, blast area, criteria, risks from KB |
| 4 | Auto-detect dependencies → approve |
| 5 | Present draft → edit |
| 6 | Save `state: refined` |
| 7 | Loop or finish |

## Setup

1. **Locate specs.md** ([procedure](../references/specs-location.md))
2. **Construct output path** ([rules](../references/output-conventions.md))
3. **Scan features:**
Glob `docs/specs/<product>/features/feature-*.md`, filter `state: planned`. If none → STOP: "No planned features."
4. **Load KB:**

With progressive disclosure:
  Invoke: neat-knowledge-query extract analysis --sections L3,L6 --format json
  Parse: L3 components, L6 risks
  
  Invoke: neat-knowledge-query extract domains --summary-only
  Parse: Available domain knowledge for coverage assessment

Fallback:
  Read specs.md, parse KB entries
  Read analysis L3, L6 sections directly
  Read domain files for coverage

Check KB state. If Minimal (no Analysis AND no Domain Knowledge): use Technical Decisions (Low precision), rely on Planning's initial assessment. If Partial (no Domain Knowledge) OR L3 also missing: derive from planning's initial assessment only, set precision to Low, recommend running `neat-sdd-domains`.

**Planning without KB:** Features planned with minimal KB will have only basic component identification. Refinement accepts this and sets precision to Low, using fallback criteria patterns.
5. **Precision:**

- High: Domain knowledge exists (e.g., domain-knowledge-04-backend.md covers auth flows)
- Medium: L3 only (e.g., analysis identifies "Auth Service" component but no domain investigation)
- Low: Technical Decisions only (e.g., no analysis, deriving from planning's initial "Components affected")

## Derivation

**Goal:** One sentence outcome.

**Blast Area:** Planning provides components/type. Refinement adds precision: `> Precision: High/Medium/Low (source)` as first line. Components not files (e.g., "sync engine" not "src/sync.ts").

**Criteria patterns:** Real-time (latency, sync), Auth (OAuth, tokens), API (schema, errors), Fallback (core works, tests verify).

**Risks:** Extract from L6 or "None identified."

## Dependency Detection

Auto-detect infrastructure dependencies from component relationships.

**Algorithm:** Parse blast area components, query KB for infrastructure, cross-reference providers in other features, validate, user confirms.

**Edge cases:** Missing (warn, create or proceed manually), no provider (suggest infrastructure feature), circular (require resolution), transitive (direct only).

**Examples:**

High precision:

```text
Detected:
  - websocket-infrastructure (provides WebSocket Server)
  - realtime-notifications (provides Notification Service)

WARNING: User Session Manager requires auth but no feature provides it.
```

L3 fallback:

```text
WARNING: L3 detection (lower confidence). Verify.

Detected:
  - websocket-infrastructure (provides WebSocket Server)
  - realtime-notifications (provides Notification Service)
```

## Save and Register

After user approves the refined feature:

1. **Save:** Update feature file with `state: refined`, add `refined: YYYY-MM-DD`, add `depends_on: [...]` if detected
2. **Loop:** STOP - "Refine another feature? (Y/n)"

## Feature Format

```markdown
---
name: Real-time Collaborative Editing
goal: realtime-collab
state: refined
created: 2026-03-26
refined: 2026-03-27
depends_on: [offline-support]
---

# Real-time Collaborative Editing

[Original description]

## Goal
One sentence: what's true when done.

## Blast Area
> Precision: High (domain-knowledge-04-backend)

**Components affected:** WebSocket manager, sync engine, versioning schema

**Type:** Incremental | Transformative

Multi-repo: `[repo-name] component-name`. Components only.

## Acceptance Criteria
- Testable condition 1
- Testable condition 2

## Risks
- Risk (mitigate: approach)
```

## Re-refinement

If already refined: read, derive updates, check downstream, present diff. If approved: save + recommend audit. Else: discard.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Guessing blast area | Use KB coverage map |
| Missing criteria | Derive from patterns |
| Not querying KB | Query for components/risks |
| Auto-approving re-refinement | Show downstream impact first |
| Asking for dependencies | Auto-detect, user confirms only |

## Output

```text
docs/specs/<product>/features/
  feature-{goal}-{nn}-{name}.md
```

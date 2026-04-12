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
| 7 | Auto-ingest (if neat-knowledge available) |
| 8 | Loop or finish |

## Steps

| # | Action | Details |
|---|--------|---------|
| 1 | Locate specs.md, output path | [Standard](../references/specs-location.md), [output rules](../references/output-conventions.md) |
| 2 | Scan features/ | Find `state: planned`, load KB per [query pattern](../references/output-access.md) |
| 3 | Present list | STOP - user picks |
| 4 | Derive details | Blast area, criteria, risks from KB |
| 5 | Derive dependencies | Auto-detect, STOP - user approves |
| 6 | Present draft | STOP - allow edits |
| 7 | Save | Update with `state: refined` |
| 8 | Auto-ingest | If neat-knowledge available ([pattern](../references/neat-knowledge.md)) |
| 9 | Loop | STOP - "Refine another?" |

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

Check KB state. If Minimal (no Analysis AND no Domain Knowledge): use Technical Decisions (Low), mark for validation. If Partial (no Domain Knowledge) OR L3 also missing: derive from planning's initial assessment only, set precision to Low, recommend running `neat-sdd-domains`.
5. **Precision:**

- High: Domain knowledge exists (e.g., domain-knowledge-04-backend.md covers auth flows)
- Medium: L3 only (e.g., analysis identifies "Auth Service" component but no domain investigation)
- Low: Technical Decisions only (e.g., no analysis, deriving from planning's initial "Components affected")

## Derivation

**Goal:** One sentence: what's true when done.

**Blast Area** (High: KB detail, Medium: KB list, Low: Tech Decisions):
Planning provides "Components affected" and "Type". Refinement adds precision.

Components not files: "WebSocket manager, sync engine" ✅ not "src/websocket/manager.ts" ❌

**Acceptance Criteria** (patterns):

- Real-time: Changes <Nms, no data loss, offline sync
- Auth: OAuth flow, token refresh, logout clears
- API: Schema, error codes, rate limiting
- Fallback: Core works, error handling, tests verify

**Risks:** Extract from L6 for blast area. None: "None identified."

## Dependency Detection

Auto-detect **infrastructure dependencies** from component relationships (feature depends on another feature that provides required infrastructure/services). This is distinct from ordering constraints flagged during planning.

**Algorithm:**

1. Parse blast area for components
2. Query KB for infrastructure (High: domain knowledge, Medium: L3)
3. Cross-reference "Components affected" for providers
4. Validate all detected dependencies exist in features directory (glob `feature-*.md`, check names)
5. Present → user confirms/modifies

**Edge cases:**

| Case | Handling |
|------|----------|
| Missing dependency | STOP, recommend `neat-sdd-audit` |
| No provider | Warn, suggest creating infrastructure feature first |
| Low precision | L3 fallback with caveat or manual entry |
| Circular | Detect cycles, require resolution |
| Implemented | Include `state: implemented` (safe) |
| Multiple | Show all, user selects |
| Cross-repo | Include repo name |
| Transitive | Direct only (A→B, not A→B→C) |

**Examples:**

High precision:

```text
Detected:
  - websocket-infrastructure (provides WebSocket Server)
  - realtime-notifications (provides Notification Service)

⚠️ User Session Manager requires auth but no feature provides it.
```

L3 fallback:

```text
⚠️ L3 detection (lower confidence). Verify.

Detected:
  - websocket-infrastructure (provides WebSocket Server)
  - realtime-notifications (provides Notification Service)
```

## Save and Register

After user approves the refined feature:

1. **Save:** Update feature file with `state: refined`, add `refined: YYYY-MM-DD`, add `depends_on: [...]` if detected
2. **Auto-ingest** (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):
   - Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -L ~/.claude/skills/neat-knowledge-query`
   - If installed:
     - Check/initialize KB: `docs/knowledge/.index/summaries.json` exists? If NO → invoke `neat-knowledge-ingest --init-project-kb`
     - Invoke: `neat-knowledge-ingest file docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md --category features`
     - Log: "✓ Indexed feature in project KB"
   - If not installed: Skip
3. **Loop:** STOP - "Refine another feature? (Y/n)"

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

If already refined:

1. Read, derive updates, diff
2. Check downstream: features, components, plans, specs, gates
3. Present → STOP
4. Approved: save + recommend audit | Declined: discard

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating new sections | Preserve structure |
| Guessing blast area | Use coverage map |
| Missing criteria | Derive from patterns |
| No fallback | Use generic pattern |
| Silent low precision | Show level, offer domains |
| Not querying KB | Query components/risks |
| Auto-approving changes | Show impact, wait |
| Wrong paths | Follow output path rules |
| Skipping re-refinement impact | Check downstream |
| Asking for dependencies | Auto-detect, confirm |

## Output

```text
docs/specs/<product>/features/
  feature-{goal}-{nn}-{name}.md
```

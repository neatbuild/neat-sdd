---
name: neat-sdd-build
description: Use when building a refined feature end-to-end - orchestrates design, planning, and implementation with spec gate verification - requires existing feature docs from refinement
---

# Build

**Role:** You are a tech lead who orchestrates feature builds from spec through verified code, using spec gates for alignment at every transition.

## Overview

Orchestrates builds: readiness → brainstorming → ADR extraction → writing-plans → spec gate → execution → spec gate.

**Requires:** Feature docs in `docs/specs/<product>/features/`, superpowers: `brainstorming`, `writing-plans`, `subagent-driven-development`/`executing-plans`.

## When to Use

- After refining features with `neat-sdd-refinement`
- For end-to-end execution with verification
- When implementation traces to feature doc

**Not for:** Standalone implementation (use superpowers directly)

## Quick Reference

| Step | What |
|------|------|
| 1-1.5 | Pick feature, resume from Status/plan/design or fresh |
| 2-2.5 | Check entry criteria, doc quality, discover blast area |
| 3-3.5 | Design (query KB), extract ADRs |
| 4-4.5 | Write TDD tasks, analyze dependencies |
| 5 | Spec gate: design + plan |
| 6-6a | Execute layer-by-layer |
| 7 | Spec gate: code |
| 8 | Update feature doc status, auto-ingest to KB |
| 9 | Prompt for audit if 2+ features with relationships |
| 10 | Continue building |

## Setup

1. Locate specs.md ([procedure](../references/specs-location.md))
2. Construct output path ([rules](../references/output-conventions.md))
3. Read features, filter not implemented (`state: refined`, no `## Status` section)

**Feature state tracking:** `state: implemented` means code is complete AND verified. Build updates both `state: implemented` (frontmatter) and appends `## Status` (section with build metadata).

## Process

### Step 1: Pick Feature (BLOCKING)

Present features with entry criteria for user selection.

### Step 1.5: Automatic State Detection

Per [State Detection Algorithm](references/state-detection.md). `## Status` → "Build again?". Plan exists → resume Step 6. Design + ADRs → resume Step 4.

### Step 2: Readiness Check

#### 2a. Prerequisites

Prerequisites must have `## Status`. Validate `depends_on` features exist. Missing dependencies → STOP, recommend `neat-sdd-audit`.

#### 2b. Doc Quality

| Criterion | Ready |
|-----------|-------|
| Acceptance criteria | Testable, concrete |
| Blast Area section | High/Medium precision |
| Risks | Identified, proportional |
| Goal | One-sentence |

Score: 4/4=High, 2-3/4=Medium, 0-1/4=Low.

#### 2c. Route

High/Medium → Step 2.5. Low → refinement.

### Step 2.5: Discover Blast Area Files

Parse components → keywords → search → rank → confirm.

### Step 3: Brainstorming

Query KB per [knowledge query pattern](../references/output-access.md) for relevant context (analysis sections, domain knowledge, existing patterns). Invoke `/brainstorming` with feature doc, specs.md, KB context, blast area. Output: `docs/superpowers/specs/`.

After brainstorming completes, proceed to Step 3.5 (Extract ADRs).

### Step 3.5: Extract ADRs

Invoke `neat-sdd-adr {design-spec} {feature-doc} integrated`. May produce zero ADRs if no architecturally significant decisions.

**Outcomes:** SUCCESS → Step 4 | MINOR → auto-fix | MAJOR → re-brainstorm.

### Step 4: Writing Plans

Invoke `/writing-plans` with design spec and feature doc. Output: `docs/superpowers/plans/`.

### Step 4.5: Dependency Analysis

Per [Dependency Analysis Algorithm](references/dependency-analysis.md):

1. Count tasks (Grep `"^### Task \d+:"`)
2. Build dependency graph (task references, TDD pairs)
3. Identify layers (Layer 0 = no dependencies, Layer N = depends on Layer N-1)
4. Present layer breakdown

**Example:** 25 tasks → L0: 15 (independent), L1: 8, L2: 2.

### Step 5: Spec Gate — Design + Plan

Invoke `neat-sdd-gate` (design mode) with feature doc + design + plan.

### Step 6: Execution

Execute layer-by-layer using dependency analysis from Step 4.5. Per layer:

1. Spawn agent with worktree isolation, pass layer tasks + feature doc + design spec
2. Agent chooses strategy (`/subagent-driven-development` or `/dispatching-parallel-agents`), commits after each task
3. Merge worktree, run integration tests
4. Next layer after tests pass

See [Parallel Execution Reference](references/parallel-execution.md).

### Step 7: Spec Gate — Execute

Invoke `neat-sdd-gate` (execute mode) with feature doc + codebase.

### Step 8: Update Feature Doc

1. **Update feature file:** Update frontmatter `state: implemented`. Append `## Status` section: built date, branch, gate log reference.
2. **Auto-ingest** (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):
   - Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
   - If "ready":
     - Invoke: `neat-knowledge-ingest file docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md --category features`
     - Log: "✓ Indexed implemented feature in project KB"
   - If "skip": Skip auto-ingest
3. **Announce completion**

**Both updates required:** Frontmatter tracks state, Status section provides build metadata.

### Step 9: Audit Prompt (If Applicable)

If 2+ implemented features AND current has `depends_on` or blast area overlaps: prompt "Run audit to verify cross-feature integration? Y/n". If Y: invoke `neat-sdd-audit`. Otherwise skip.

### Step 10: Continue Building

Build another?

## Gate Handling

**On gate failure (design or execute mode):**

1. Present gate findings (blockers, warnings)
2. Ask user: "Fix plan | Fix design | Accept as-is | Abort"
   - **Fix plan:** Return to Step 4 (writing-plans), update plan, re-run gate
   - **Fix design:** Return to Step 3 (brainstorming), update design + plan, re-run gate
   - **Accept as-is:** User acknowledges risk, proceed to next step
   - **Abort:** Stop build, feature remains `state: refined`
3. Max 3 gate attempts per step. After 3 failures, escalate to user for decision.
4. **Criteria changes:** If gate reveals feature doc criteria are wrong, surface to user, update if approved, re-run gate.

## Common Mistakes

See [Common Mistakes Reference](references/common-mistakes.md).

## Output

```text
docs/superpowers/
  specs/YYYY-MM-DD-{goal}-{slug}-design.md
  plans/YYYY-MM-DD-{goal}-{slug}-plan.md       # single plan file

docs/specs/<product>/
  adrs/adr-YYYYMMDD-<decision>.md, index.md
  features/
    feature-{goal}-{nn}-{slug}.md              # state: implemented, with Status
    feature-{goal}-{nn}-{slug}-gates.md
```

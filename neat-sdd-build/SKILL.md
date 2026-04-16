---
name: neat-sdd-build
description: Use when building a refined feature end-to-end - orchestrates design, planning, and implementation with spec gate verification - requires existing feature docs from refinement
---

# Build

**Role:** You are a tech lead who orchestrates feature builds from spec through verified code, using spec gates for alignment at every transition.

## Overview

Orchestrates continuous parallel builds: readiness → brainstorming → ADR extraction → writing-plans → risk assessment + spec gate → execution → risk assessment + spec gate.

**Execution model:** Dynamic parallel queuing - as features complete, new independent features are automatically prepared and spawned.

**Requires:** Feature docs in `docs/specs/<product>/features/`, superpowers: `brainstorming`, `writing-plans`, `subagent-driven-development`/`executing-plans`.

## When to Use

- After refining features with `neat-sdd-refinement`
- For end-to-end execution with verification
- When implementation traces to feature doc

**Not for:** Standalone implementation (use superpowers directly)

## Quick Reference

| Step | What |
|------|------|
| 1-1.5 | Pick feature(s), validate independence, resume from Status/plan/design or fresh |
| 2-2.5 | Check entry criteria, doc quality, discover blast area (per feature) |
| 3-3.5 | Design (query KB), extract ADRs (per feature) |
| 4-4.5 | Write TDD tasks, analyze dependencies (per feature) |
| 5 | Risk assessment → gate design + plan if needed (per feature) |
| 6 | Spawn all features in background (isolated worktrees) |
| 6a | Monitor completion, merge as finished |
| 7 | Risk assessment → gate code if needed (per feature) |
| 8 | Update feature doc status, auto-ingest to KB (per feature) |
| 9 | Prompt for audit if 2+ features with relationships |
| 10 | Continue building |

## Setup

1. Locate specs.md ([procedure](../references/specs-location.md))
2. Construct output path ([rules](../references/output-conventions.md))
3. Read features, filter not implemented (`state: refined`, no `## Status` section)

**Feature state tracking:** `state: implemented` means code is complete AND verified. Build updates both `state: implemented` (frontmatter) and appends `## Status` (section with build metadata).

## Process

### Step 1: Pick Feature(s) (BLOCKING)

Present features with entry criteria. User selects 1+ features to build.

**Independence Validation:**

1. Check `depends_on` in frontmatter: no dependencies between selected features
2. Check blast areas: no overlapping files/components
3. Check task plans: no shared external dependencies being modified

**If conflicts found:** Present conflict details, ask user to deselect conflicting features or adjust selection.

**If independent (or N=1):** Proceed with batch workflow (each in isolated worktree).

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

**Load KB Context (per [knowledge query pattern](../references/output-access.md)):**

Check: `docs/knowledge/.index/metadata.json` exists?

**If YES (agent-driven discovery available):**

- Formulate specific questions based on blast area components
- Example: `neat-knowledge-extract "What authentication patterns, token handling, and security decisions exist?"`
- Internally calls search, agent evaluates keyword matches for relevance and depth
- Returns: Structured JSON (80-90% context savings)
- If invoke fails (neat-knowledge not installed): fall back to direct reads automatically, log "neat-knowledge not available, using direct reads"

**If NO (direct reads fallback):**

- Read `specs.md`, parse KB entries in Outputs section
- Read relevant files from `docs/specs/` (analysis, domains, features, ADRs)
- Extract sections directly in main context
- Same functionality, higher context usage

**Then invoke brainstorming:**
Invoke `/brainstorming` with feature doc, specs.md, KB context (from either path), blast area. Output: `docs/superpowers/specs/`.

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

### Step 5: Risk Assessment + Spec Gate — Design + Plan

**Risk Assessment:** Analyze design complexity per [risk assessment algorithm](references/risk-assessment.md#design-phase-assessment).

**If gate runs:**

1. Ensure artifacts exist: feature doc, design spec, task plan
2. Invoke `neat-sdd-gate <product>` (auto-detects design mode based on artifacts)

### Step 6: Spawn Execution Agents

For each prepared feature (has design + plan from Steps 1-5):

1. Spawn agent with worktree isolation (`run_in_background: true`)
2. Pass: layer-by-layer tasks + feature doc + design spec
3. Agent executes all layers independently
4. Track: feature name → agent ID → worktree path

**After all spawned:** Continue immediately to Step 6a (Monitor Completion) - do NOT stop here.

See [Parallel Execution Reference](references/parallel-execution.md).

### Step 6a: Monitor Completion & Dynamic Queuing

Wait for background agents to complete. As each finishes:

1. Retrieve completion status and worktree path
2. **Simplify in worktree (BLOCKING):**
   - Invoke `/simplify` in the worktree context
   - Reviews changed code for reuse, quality, efficiency
   - Fixes issues found
   - Commits simplifications to worktree
   - **CRITICAL:** Must run BEFORE merge - other features may depend on this code
3. Merge worktree to main branch
4. Run integration tests for that feature
5. If tests pass:
   - **IMMEDIATELY run Step 7 (Risk Assessment + Gate) - BLOCKING**
   - **IMMEDIATELY run Step 8 (Update Feature Doc state: implemented) - BLOCKING**
   - **CRITICAL:** State MUST be updated BEFORE checking for next feature
6. If tests fail:
   - Mark feature as failed (add `## Status - Failed` section)
   - Log failure, continue monitoring others

**After feature state updated (Step 8 complete):**

1. Check for remaining features with `state: refined`
2. If found: validate independence from still-running features
   - Check `depends_on`: no dependencies on running features
   - Check blast areas: no overlap with running features
   - Check task plans: no shared dependencies being modified
3. If independent: run Steps 1-5 for new feature, spawn at Step 6 immediately
4. If conflicts exist: wait for next completion, try again

**Continue until:** No refined features remain OR all remaining features conflict with running ones.

**CRITICAL SAFETY:** Feature state update (Step 8) is BLOCKING before spawning next feature. Prevents duplicate work on same feature.

### Step 7: Risk Assessment + Spec Gate — Execute

**Risk Assessment:** Analyze implementation complexity per [risk assessment algorithm](references/risk-assessment.md#execute-phase-assessment).

**If gate runs:**

1. Ensure artifacts exist: feature doc, blast area file, git diff with changes
2. Invoke `neat-sdd-gate <product>` (auto-detects execute mode based on artifacts)

### Step 8: Update Feature Doc (CRITICAL - BLOCKING)

**CRITICAL:** This step MUST complete before spawning next feature in Step 6a. Failure to update state immediately can cause duplicate work.

1. **Update feature file:** Update frontmatter `state: implemented`. Append `## Status` section: built date, branch, gate log path (if gates ran: `feature-{goal}-{nn}-{slug}-gates.md`).
2. **Auto-ingest** (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):
   - Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
   - If "ready":
     - Invoke: `neat-knowledge-ingest file docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md --category features`
     - Log: "✓ Indexed implemented feature in project KB"
   - If "skip": Skip auto-ingest
3. **Announce completion**

**Both updates required:** Frontmatter tracks state, Status section provides build metadata.

**Red Flag:** If you're about to check for next feature but haven't updated state yet - STOP.

### Step 9: Audit Prompt (If Applicable)

If 2+ implemented features AND current has `depends_on` or blast area overlaps: prompt "Run audit to verify cross-feature integration? Y/n". If Y: invoke `neat-sdd-audit`. Otherwise skip.

### Step 10: Completion

All features processed (built or logged as failed). Announce: "All features built."

## Gate Handling

**Note:** Gates only run if risk assessment determines the feature is medium or high risk. Low-risk features skip gates with logged reasoning.

**If skipped gates lead to issues:** If a feature was assessed as low-risk and gates were skipped, but execution or integration tests reveal problems, manually invoke `neat-sdd-gate <product>` to verify alignment retroactively. The gate will auto-detect mode and validate against acceptance criteria.

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
    feature-{goal}-{nn}-{slug}-gates.md        # created/appended by neat-sdd-gate automatically
```

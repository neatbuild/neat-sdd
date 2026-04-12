---
name: neat-sdd-adr
description: Use when creating or extracting architectural decisions - standalone conversational mode or extraction from design specs - generates MADR format ADRs
---

# ADR Management

**Role:** You are a software architect who documents architectural decisions in MADR format.

**Usage:**

- Standalone: `neat-sdd-adr`
- Extraction: `neat-sdd-adr <design-spec-path> <feature-doc-path> <mode>`

## Overview

**Modes:** Standalone (conversational) or Extraction (from design spec "Key Decisions")

**Architecture:** Shared utilities. Standalone in main agent, extraction spawns parallel sub-agents.
**Output:** MADR format in `docs/specs/<product>/adrs/` with shared numbering.

## When to Use

**Standalone:** Document decisions without design specs, record past decisions, explore trade-offs.
**Extraction:** neat-sdd-build integration, backfill from specs, design review.

## Quick Reference

### Mode Detection

| Arguments | Mode | Workflow |
|-----------|------|----------|
| None | Standalone | Converse → Generate → Review → Save |
| 2-3 args | Extraction | Parse → Filter → Confirm → Extract → Save |

### Standalone Steps

| Step | What | Agent |
|------|------|-------|
| 1 | Setup: paths, specs.md | Main |
| 2 | Context: query KB | Main → KB |
| 3 | Converse: ask questions | Main |
| 4 | Generate: assign #, format MADR | Main |
| 5 | Review: present, edit | Main |
| 6 | Save: write, update | Main |

### Extraction Steps

| Step | What | Agent |
|------|------|-------|
| 1 | Setup: mode, paths | Main |
| 2 | Parse: extract Key Decisions | Main |
| 3 | Filter: check significance | Main |
| 4 | Confirm: present, approve | Main |
| 5 | Spawn: parallel (1 per) | Main → Subs |
| 6 | Extract: check, ask, generate | Subs |
| 7 | Save: collect, update | Main |

## Setup & Mode Detection

**Detect:** No args → Standalone | 2+ args → Extraction

**Setup:** Locate specs.md ([standard procedure](../references/specs-location.md)), extract product name. Set path: `<repo-root>/docs/specs/<product>/adrs/`. Create dir if needed.

## Shared Utilities

[Shared utilities](references/utilities.md)

## Standalone Mode

### Phase 0: Context

Ask topic. Query KB per [knowledge query pattern](../references/output-access.md): architectural patterns, existing ADRs, L3 components, L5/L6 constraints/risks, domain knowledge. Inform questions/recommendations.

After gathering context, proceed to Phase 1 (Conversation).

### Phase 1: Conversation

Ask: "What decision?" "What problem?" Check: decision, context, alternatives, rationale, consequences. If missing: "Alternatives?" (suggest), "Why?", "Trade-offs?", "Risks?" Use context to suggest alternatives, identify conflicts, recommend alignment. Stop when all 5 present or "none". See [examples](references/examples.md).

### Phase 2: Generation

Assign date number (shared utility, `YYYYMMDD` format), filename `adr-{YYYYMMDD}-{slug}.md`. Status: "Accepted"/"Proposed". Enrich with KB. Format per [template](references/template.md). See [examples](references/examples.md).

### Phase 3: Review

Present: "Does this look good?" (yes/edit/no). Edit: ask → update → loop. No: "Canceled."

### Phase 4: Save

Get path (create dir if needed), write file (fail → report, exit). Update index.md (sort by date number descending), specs.md (add entry/count). Auto-ingest (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):

- Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
- If "ready":
  - Invoke: `neat-knowledge-ingest file <adr-path> --category adrs`
  - Log: "✓ Indexed ADR in project KB"
- If "skip": Skip auto-ingest

Report success.

**Errors:** Can't create dir → exit | Write fails → no updates | Index corrupted → backup + fresh

## Extraction Mode

Extract from design spec "Key Decisions". Input: `neat-sdd-adr <design-spec-path> <feature-doc-path> <mode>`. Expects `## Key Decisions` with H3 subsections (`### N. Title`).

**Note:** Extraction is always triggered but may result in zero ADRs if no architecturally significant decisions are found. This is valid behavior—not all features require ADRs.

### Step 1: Parse & Filter

Parse → split by H3 → extract number, title, content. Filter ADR-worthy (multi-component, hard to reverse, trade-offs, non-functionals). Skip local/standard/trivial.

**If significant decisions found:** Confirm: "Detected {N}: Significant ({X}), Uncertain ({Y}), Skipped ({Z}). Generate {X}?" → yes/no/add/remove

**If no significant decisions:** Report: "SUCCESS: Extraction triggered: Analyzed {N} decisions, found 0 architecturally significant" and exit gracefully (this is valid, not an error)

### Step 2: Assign Numbers

Use shared utility #1: Use today's date in `YYYYMMDD` format. All ADRs in this batch share the same date number.

**Example:** Creating 3 ADRs on 2026-03-30 → all use `20260330` (different slugs differentiate them).

**Extract feature name:** Parse feature-doc-path pattern `feature-<nn>-<slug>.md` → extract `<slug>` for sub-agent inputs.

### Step 3: Spawn Sub-Agents

**Parallel dispatch:**

```text
Extract ADR, generate MADR, save, return metadata only.

Inputs: {title}, {content}, {date-number}, {design-spec-path}, {feature-doc-path}, {feature-name}, {product-name}, {output-path}

Steps:
1. Check: 2+ missing (rationale/alternatives/consequences) OR (1 missing AND <100 words) → ask user
2. Filename: adr-{date-number}-{slug}.md (YYYYMMDD format)
3. Generate MADR per [template](references/template.md) (Context from feature+spec, Decision from Key Decisions)
4. Write {output-path}/adr-{date-number}-{slug}.md
5. Return: date-number, title, filename (3 lines only)
```

**Execution:** Spawn ALL in batch (`Agent`, `subagent_type: "general-purpose"`). Wait, collect.

### Step 4: Collect & Save

Receive metadata (3 lines/ADR). Update index.md (sort by date number descending) and specs.md. Auto-ingest (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):

- Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
- If "ready":
  - Invoke: `neat-knowledge-ingest directory docs/specs/<product>/adrs/ --category adrs`
  - Log: "✓ Indexed {N} ADRs in project KB"
- If "skip": Skip auto-ingest

Context benefit: ~30 tokens/ADR vs 800-1,200.

### Error Handling

| Error | Message |
|-------|---------|
| Spec not found | "Design spec not found at {path}" |
| No Key Decisions | "No 'Key Decisions' section found" |
| User rejects | "Canceled. No files created." |
| Sub-agent failure | "Generated {N} of {M}. Failed: {title}: {error}" |

### Success

**With ADRs:**

```text
SUCCESS: Extraction triggered: Analyzed {N} decisions, filtered to {M} significant
SUCCESS: Generated {M} ADRs: docs/specs/{product}/adrs/adr-{YYYYMMDD}-*.md
SUCCESS: Index and specs.md updated
SUCCESS: Indexed in project KB (if neat-knowledge available)
```

**Without ADRs (valid outcome):**

```text
SUCCESS: Extraction triggered: Analyzed {N} decisions, found 0 architecturally significant
INFO: No ADRs generated. All decisions were implementation-specific or trivial.
```

## Output

ADRs are saved to `docs/specs/<product>/adrs/` per [output conventions](../references/output-conventions.md). Updated in specs.md Outputs section and KB.

## Common Mistakes

[Common mistakes](references/common-mistakes.md)

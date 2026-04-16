---
name: neat-sdd-domains
description: Use when building domain knowledge through focused investigations - investigates specific topics within technical or business domains that merge into living domain knowledge files - requires existing neat-sdd-analysis output
---

# Domain Knowledge Building

**Role:** You are a domain expert who builds domain knowledge through code investigation and focused analysis.

**Usage:** `neat-sdd-domains <domain>` or `neat-sdd-domains` (will prompt)

## Overview

Select domain → build foundation → investigate topics → merge into one file.

**Output:** `domain-knowledge-{NN}-{name}.md` with Overview, Investigations, Change Log.

**Not for:** Q&A (`neat-knowledge-extract`) or analysis (`neat-sdd-analysis`)

## When to Use

- Build domain knowledge through code investigation
- Investigate specific topics
- Update knowledge (detects contradictions)

## Quick Reference

| Step | What |
|------|------|
| 1 | Locate specs.md, output path, analysis |
| 2 | Select domain |
| 3 | Check materials |
| 4 | Build/update file |
| 5 | Ask topic |
| 6 | Clarify |
| 7 | Investigate |
| 8 | Merge |
| 9 | Loop or finish |
| 10 | PDF, register |

## Setup

1. **Locate specs.md** ([procedure](../references/specs-location.md))
2. **Construct output path** ([rules](../references/output-conventions.md))
3. Read target analysis from KB per [knowledge query pattern](../references/output-access.md)
4. Read `## Business Domains` section from analysis
5. Check existing Domain Knowledge

## Source of Truth

| Layer | Authority | Scope |
|-------|-----------|-------|
| **Domain knowledge** | Highest | Domain-specific |
| **Target analysis** | Default | Per product |
| **Reference analyses** | Context | References only |
| **Codebase** | Ground truth | Always |

## Domain Taxonomy

[technical-domains.md](references/technical-domains.md): 7 technical (01-07), business (08-business-*)

## Investigation

### 1. Select Domain

Present [taxonomy](references/technical-domains.md): Technical (01-07), Business (08-business-*), or new (0).

If 0: ask name, validate, generate `08-business-{name}`, register.

### 2. Check Materials

"Domain materials? (Optional)"

### 3. Build/Update File

Build BEFORE topic. Path: `docs/specs/<product>/domains/domain-knowledge-{NN}-{name}.md`

**Exists:** Read, summary, ask "Update materials?"

**New:** Read analysis + materials. Create with heading, Last Updated, Overview, Investigations, Change Log.

### 4. Ask Topic

"What would you like to investigate?"

### 5. Clarify

Ask 2-4 questions: vague → specific.

### 6. Generate Slug

Example: "token rotation" → `token-rotation`

### 7. Check Existing

If found: show summary, ask "Update or new?"

### 8. Investigate

Dispatch Explore with context, scope, paths.

**Example:** Topic "token rotation" → Explore with: "Investigate token rotation mechanisms in the auth system. Focus on refresh flows, expiration handling, and storage."

After the investigation completes, proceed to Step 9 (Merge).

### 9. Merge

**Updating:** Contradiction detection, resolve, update.

**New:** Add Investigation: Findings, Impact, Recommendations, References. Update counts, Change Log.

### 10. Loop or Finish

"Investigate another?" Yes: step 4; No: step 11.

### 11. Complete

1. Register in Outputs ([format](../references/output-conventions.md))
2. Auto-ingest (if neat-knowledge available, per [auto KB pattern](../references/neat-knowledge.md)):
   - Check: `test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json && echo "ready" || echo "skip"`
   - If "ready":
     - Invoke: `neat-knowledge-ingest file docs/specs/<product>/domains/domain-knowledge-{NN}-{name}.md --category domains`
     - Log: "✓ Indexed domain knowledge in project KB"
   - If "skip": Skip auto-ingest
3. Offer PDF (`neat-util-pdf`)
4. Recommend `neat-sdd-audit`

## Output Format

See step 3. Examples: [business-domains.md](references/business-domains.md)

## Contradiction Detection

Classify: Contradiction, Addition, Removal. If contradictions/removals: present, resolve, log; otherwise merge.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Topic before file | Build file first (3), topic after (4) |
| Materials required | Optional |
| Separate files | One per domain |
| Loop to 1 | Loop to 4 |
| Generic questions | Reference findings |
| Auto-resolve | Present first |
| Use reference | Use target |
| Direct investigation | Use Explore |
| Write to root | Follow Setup 2 |

---
name: neat-sdd-planning
description: Use when user has a high-level goal or objective that needs to be broken down into discrete features for refinement
---

# Planning

**Role:** You are a product owner who clarifies ambiguous goals and decomposes them into discrete, refinable features.

**Core principle:** Clarify before decomposing. Detailed evaluation happens in refinement.

## Overview

Decomposes goals into refinable features via KB-guided clarification and architecture validation.

## When to Use

Use when goals need decomposition before refinement. Not for detailed specs or implementation.

## Quick Reference

| Step | What |
|------|------|
| 1 | Query KB for context overview (structured index) |
| 2 | Generate clarifying questions → query KB for factual answers → ask user for decisions |
| 3 | Synthesize capabilities from goal (5-15 features) |
| 4 | Cross-check against architecture → identify components, type, risks |
| 5 | Present features, iterate on feedback |
| 6 | Derive goal identifier, save as `feature-{goal}-{nn}-{slug}.md` with `state: planned`, update specs.md KB |

## Setup

1. **Locate specs.md** ([procedure](../references/specs-location.md))
2. **Construct output path** ([rules](../references/output-conventions.md))
3. If Plan entry exists in KB, ask "Update existing plan or start fresh?"

## Process

1. Query KB for overview (structured index) per [knowledge query pattern](../references/output-access.md)
2. Generate clarifying questions, query KB for factual answers, ask user for decisions
3. Synthesize capabilities from goal, cross-check against architecture
4. Present features with component mapping and risks, iterate on feedback
5. Save to `features/<slug>.md`, update specs.md KB

### Step 1: Load Context Overview

Query KB per [knowledge query pattern](../references/output-access.md):

Agent-driven discovery:

```markdown
Invoke: neat-knowledge-extract "What is the tech stack, integrations, architectural components, main workflows, and business logic?"
```

Agent evaluates keyword matches and decides loading depth (summary/sections/full based on ROI).

Parse JSON: Extract tech_stack, integrations, components, workflows, business_logic from returned documents.

Fallback: Read specs.md, parse KB entries, read analysis directly.

If KB minimal: Use goal only; factual questions become decision questions.

### Step 2: Clarify (Required Before Step 3)

**2.1 Generate questions:** List 2-5 questions about ambiguities (scope, users, integration, constraints, priorities). Categorize: **Factual** (KB) or **Decision** (user).

**2.2 Query KB for factual answers:** Query KB per [knowledge query pattern](../references/output-access.md) with explanations and citations. Example: "Does system support real-time?" → Query "What workflows and integration patterns support real-time operations?" Agent evaluates and loads relevant analysis sections + domain knowledge, synthesize with citations.

**2.3 Ask user decision questions:** Present only questions KB cannot answer (priorities, permissions, strategic choices).

### Step 3: Decompose and Cross-Check

**3.1 Synthesize capabilities:** Break goal into functional capabilities (user-centric, independently refinable, clear value). Aim for 5-15 features. Avoid technical layers or vague goals.

**3.2 Cross-check against architecture:** For each feature, identify components affected (from architectural components in KB), type (Incremental/Transformative), risks (blast radius, conflicts, ordering). Query KB for deeper understanding if needed with specific questions about component relationships or integration patterns.

### Step 4: Present and Iterate

Show: Name, brief description, components affected, type, risks. Iterate on feedback until approved.

### Step 5: Save and Update

**5.1 Derive goal identifier:** Extract 1-3 key terms from user's goal, create slug (lowercase, hyphens, max 20 chars).

**Examples:**

- "Implement OAuth authentication system" → `auth`
- "Add real-time collaborative editing" → `realtime-collab`
- "Build API v2 with GraphQL" → `api-v2`
- "Migrate to microservices architecture" → `microservices`

**5.2 Save feature docs:** Create `docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md` using format below. Use two-digit numbers (01, 02, etc.) scoped per goal identifier (each goal starts numbering at 01).

**5.3 Update specs.md Outputs:** Add Features entry per [standard format](../references/output-conventions.md):

```markdown
- Features: docs/specs/<product>/features/ (8 features)
```

**5.4 Recommend next step:** Suggest `neat-sdd-refinement` for detailed acceptance criteria.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping clarification | Always clarify before decomposing |
| Asking factual questions | Query KB for facts, ask user for decisions |
| Wrong granularity | 5-15 capabilities with user value |
| Skipping architecture cross-check | Must identify components, type, risks |
| Not deriving goal identifier | Derive from user's goal in Step 5.1 |

## Output

Save to `docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md` per [output path rules](../references/output-conventions.md).

**Format:**

```markdown
---
name: Feature Name
goal: goal-identifier
state: planned
created: YYYY-MM-DD
---

# Feature Name

Brief 1-2 sentence description.

## Goal

(To be added in refinement)

## Blast Area

> Initial assessment from planning. Refinement adds precision levels (High/Medium/Low) as first line.

**Components affected:** component-a, component-b

**Type:** Incremental | Transformative

**Cross-repo format (if applicable):** `[repo-name] component-name`

**Format contract:** Planning provides components list and type. Refinement prepends precision blockquote (`> Precision: Level (source)`).

## Acceptance Criteria

(To be added in refinement)

## Risks

[Description of risks, if any]
```

**Naming:**

- **Goal identifier:** 1-3 key terms from goal (lowercase, hyphens, max 20 chars)
- **Number:** Scoped per goal (01, 02, etc.)
- **Slug:** Feature name (lowercase, hyphens only, e.g., "Real-Time Editing!" → `realtime-editing`)

**Terminology standard:**

- **Section heading:** `## Blast Area` (always capitalized)
- **Field label:** `**Components affected:**` (bold with colon)
- **Inline reference:** "blast area" (lowercase) or "Blast Area section" (when referring to specific section)

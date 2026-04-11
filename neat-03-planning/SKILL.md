---
name: neat-sdd-planning
description: Use when user has a high-level goal or objective that needs to be broken down into discrete features for refinement
---

# Planning

**Role:** You are a product owner who clarifies ambiguous goals and decomposes them into discrete, refinable features.

**Core principle:** Clarify before decomposing. Detailed evaluation happens in refinement.

## Overview

Breaks high-level goals into discrete, refinable features through KB-guided clarification and architectural cross-checking. Queries KB for facts, asks user for decisions, validates against architecture.

## When to Use

- High-level goal needing decomposition
- Analysis exists, need to plan what to build
- Defining scope before refinement

**Not for:** Detailed specs (`neat-sdd-refinement`) or immediate implementation (`neat-sdd-build`)

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

**Query KB per [knowledge query pattern](../references/output-access.md)** for Structured Index (L1-L5: tech stack, integrations, components, flows, journeys) and top 3-5 constraints/risks.

**With progressive disclosure (neat-knowledge available):**

Invoke Skill tool:
  skill: neat-knowledge-query
  args: extract analysis --sections L1,L2,L3,L4,L5 --format json

Parse response:

- L1 → tech_stack, dependencies
- L2 → integrations
- L3 → components, architecture patterns
- L4 → flows, journeys
- L5 → business logic, user journeys

Extract top 3-5 constraints/risks from L6 (if needed):
  Invoke: neat-knowledge-query extract analysis --sections L6 --summary-only

**After loading context, proceed to Step 2 (Clarify).**

**Fallback (no neat-knowledge):**

Check: .index/summaries.json exists in docs/knowledge/?

- No → Read specs.md, parse KB entries, read analysis file directly
- Extract same structured data
- Continue with same logic

**If KB minimal/empty:** Check KB state per knowledge query pattern. If Minimal or Empty: Continue with user-provided goal only. Step 2 factual questions become decision questions. Decomposition relies on goal understanding, not deep KB.

**After loading context (or determining KB is minimal), proceed to Step 2 (Clarify).**

### Step 2: Clarify (Required Before Step 3)

**2.1 Generate questions:** List 2-5 questions about ambiguities (scope, users, integration, constraints, priorities). Categorize: **Factual** (KB) or **Decision** (user).

**2.2 Query KB for factual answers:** Query KB per [knowledge query pattern](../references/output-access.md) with explanations and citations.

**Example:** "Does the system currently support real-time updates?"

With progressive disclosure:
  Invoke: neat-knowledge-query extract analysis --sections L4 --format json
  Parse: flows section for WebSocket infrastructure, pub/sub patterns
  
  If domain knowledge exists for realtime:
    Invoke: neat-knowledge-query extract domains --domain XX-realtime --summary-only
    Parse: domain overview for real-time patterns

  Synthesize answer from both sources with citations.

Fallback:
  Read analysis L4 section directly
  Search for WebSocket, realtime patterns
  Synthesize answer from findings

**After answering factual questions from KB, proceed to 2.3.**

**2.3 Ask user decision questions:** Present only questions KB cannot answer (priorities, permissions, strategic choices, preferences).

**Example:** "Should notifications be opt-in or opt-out by default?" → Ask user (strategic preference).

**After clarifying with user, proceed to Step 3 (Decompose and Cross-Check).**

### Step 3: Decompose and Cross-Check

**3.1 Synthesize capabilities:** Break goal into functional capabilities (user-centric, independently refinable, clear value). Aim for 5-15 features. Avoid technical layers or vague goals.

**3.2 Cross-check against architecture:** For each feature:

- **Components affected** (from L3)
- **Type:** Incremental (builds on L4/L5) or Transformative (new capability)
- **Risks:** High blast radius (5+ components), conflicts with flows, ordering constraints (if feature must precede/follow others)

**Query KB if deeper understanding needed:**

With progressive disclosure:
  Invoke: neat-knowledge-query extract analysis --sections L3,L4 --format json
  Parse structured components and flows
  
  If domain knowledge relevant:
    Invoke: neat-knowledge-query extract domains --domain XX-name --sections overview
    Parse for domain-specific patterns

Fallback:
  Read analysis L3, L4 sections directly
  Extract components and flows

**After cross-checking against architecture, proceed to Step 4 (Present and Iterate).**

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
| Skipping Step 2 clarification | Always clarify first — ambiguous goals produce unclear features |
| Asking user factual questions | Query KB for factual answers first, ask user only decisions |
| Querying KB for lists when you need explanations | Step 1 extracts structured index; Step 2.2 queries for detailed answers |
| Decomposing into technical components | Synthesize functional capabilities first, then cross-check against components |
| Skipping architectural cross-check | Must identify components affected, type, and risks for each feature |
| Wrong granularity | Feature = capability with user value, refinable independently (aim for 5-15) |
| Adding dependencies | Belongs in refinement, not planning |
| Wrong save location for platforms | Follow output path rules (Setup step 2) |
| Not deriving goal identifier | Must derive from user's goal description in Step 5.1 |
| Global feature numbering | Numbers are scoped per goal, not global |

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

> Initial assessment from planning. Refinement adds precision levels (High/Medium/Low).

**Components affected:** component-a, component-b

**Type:** Incremental | Transformative

**Cross-repo format (if applicable):** `[repo-name] component-name`

## Acceptance Criteria

(To be added in refinement)

## Risks

[Description of risks, if any]
```

**Naming:**

- **Goal identifier:** 1-3 key terms from goal (lowercase, hyphens, max 20 chars)
- **Number:** Scoped per goal (01, 02, etc.)
- **Slug:** Feature name (lowercase, hyphens only, e.g., "Real-Time Editing!" → `realtime-editing`)

---
name: neat-sdd-audit
description: Use when multiple features are implemented and need cross-feature verification - checks dependency integration, blast area coordination, implementation gaps, and pattern consistency - requires implemented features
---

# neat-sdd Cross-Feature Audit

**Role:** You are a QA engineer who verifies cross-feature integration, coordination, and consistency after implementation.

**Usage:** `neat-sdd-audit <product>` or `neat-sdd-audit` (will prompt for product)

**Requires:** Multiple features with `state: implemented` in `docs/specs/<product>/features/`

**Not for:** Single feature verification (use `neat-sdd-gate`), documentation consistency during refinement (use `neat-sdd-refinement`)

## Overview

Cross-feature implementation verification after features are built. Verifies dependency integration in code, blast area coordination, implementation gaps, and pattern consistency. Produces severity-ranked findings (ERROR/WARNING/INFO) with actionable recommendations.

**Scope distinction:**
- `neat-sdd-gate`: Does Feature A's code satisfy Feature A's spec?
- `neat-sdd-audit`: Do Features A, B, C work together correctly?

## When to Use

Run audit AFTER features are implemented:
- After implementing dependent features (features with `depends_on`)
- After implementing features with overlapping blast areas
- After a batch of features in the same domain complete
- Before major milestones (merge to main, release)
- When you suspect cross-feature integration issues

## When NOT to Use

Do NOT run audit for:
- Single feature verification → use `neat-sdd-gate`
- Documentation-level checks during refinement → handled by `neat-sdd-refinement`
- Before implementation starts → audit verifies code, not specs

## Quick Reference

| Step | What |
|------|------|
| 1 | Setup: locate specs, load features, determine which checks apply |
| 2 | Run applicable checks (1-4) |
| 3 | Present audit report with severity-ranked findings |
| 4 | Handle user choice: fix (recommend actions), accept (log rationale), done |
| 5 | Save audit report to `docs/specs/<product>/audit.md` |

## Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| ERROR | Integration broken, gaps, or conflicts | Should address before merge/release |
| WARNING | Inconsistencies or weak coordination | Review recommended |
| INFO | Verification passed or awareness only | No action needed |

All severities are advisory - user decides whether to address.

## Setup

1. **Locate specs.md** per [standard procedure](../references/specs-location.md). Read Outputs section for features path.
2. **Glob features:** Find all `feature-*.md` files. If none with `state: implemented` → **STOP:** "No implemented features found. Audit requires implemented features."
3. **Load feature data:** For each implemented feature, read:
   - Frontmatter: name, goal, state, depends_on
   - Blast Area: components, precision
   - Acceptance Criteria
4. **Determine applicable checks:** Based on feature data, decide which checks apply (see Checks section)
5. **Construct output path** per [output path rules](../references/output-conventions.md)

## Checks

Run all checks whose inputs exist. Skip others and note in report.

### Check 1: Dependency Integration Verification

**Inputs:** Features with `depends_on` in frontmatter (≥1 pair)

**Skip if:** No features with `depends_on` field

**Verifies:** Dependent features actually integrate with dependency features in code

**Algorithm:**

1. **Build dependency list:** For each feature with `depends_on`, create pairs (dependent → dependency)
2. **Verify each pair:**
   - Query KB: "What does [dependency feature] provide/export? Include component names and APIs."
   - Identify dependent feature's implementation files from blast area
   - Grep dependent files for imports/usage of dependency's exports
   - Verify usage patterns match provided API (spawn subagent for complex cases)
3. **Classify findings:**

| Severity | Condition |
|----------|-----------|
| ERROR | Feature B depends_on A but doesn't import A's exports |
| ERROR | Feature B imports A but uses wrong API/interface (mismatch) |
| WARNING | Feature B depends_on A but coupling is weak (minimal/unclear usage) |
| INFO | Feature B correctly integrates with A (verification passed) |

**Example finding:**
```
ERROR: feature-realtime-collab depends_on feature-websocket-infra but doesn't import WebSocketServer
- Expected: import from websocket-infra/server
- Actual: No imports found in src/collaboration/manager.ts
```

### Check 2: Blast Area Overlap Coordination

**Inputs:** Features with overlapping blast areas (≥1 overlap)

**Skip if:** No overlapping blast areas found

**Verifies:** Features modifying same components coordinate correctly

**Algorithm:**

1. **Build blast area map:** component → [features that modify it]
2. **Find overlaps:** Components modified by 2+ features
3. **For each overlap:**
   - Check if features reference each other (in dependencies or Risks section)
   - Query KB: "How do [feature A] and [feature B] modify [component]? Compare approaches."
   - Detect conflicts vs. coordinated changes
4. **Classify findings:**

| Severity | Condition |
|----------|-----------|
| ERROR | Features modify component with conflicting approaches (e.g., different error handling that breaks each other) |
| WARNING | Features modify component differently without documented coordination |
| INFO | Overlapping modifications are coordinated (referenced in dependencies/risks) |

**Example finding:**
```
WARNING: auth-module and api-gateway both modify ErrorHandler without coordination
- auth-module: Throws custom AuthError
- api-gateway: Expects standard Error format
- Features don't reference each other in dependencies or risks
```

### Check 3: Implementation Gap Detection

**Inputs:** Feature acceptance criteria, implementations, dependency relationships (≥2 features)

**Skip if:** < 2 implemented features

**Verifies:** Features connect where specs imply they should

**Algorithm:**

1. **Find integration keywords:** Grep acceptance criteria for "integrates with", "uses", "receives from", "sends to", "connects to"
2. **For each implied integration:**
   - Identify feature pair (A implies integration with B)
   - Query KB: "Does [feature A] implementation integrate with [feature B]? Check for API calls, imports, data flow."
   - Verify handoff points exist (Feature A output → Feature B input)
3. **Classify findings:**

| Severity | Condition |
|----------|-----------|
| ERROR | Acceptance criteria explicitly requires integration but code has no connection |
| WARNING | Features in same domain with related concerns but no integration found |
| INFO | Integration points match spec expectations |

**Example finding:**
```
ERROR: feature-notification-system acceptance criteria states "integrates with user-preferences for delivery settings" but implementation doesn't access UserPreferences API
- Criteria: "System respects user notification preferences from user-preferences feature"
- Implementation: No imports or API calls to preferences service
```

### Check 4: Cross-Feature Pattern Consistency

**Inputs:** Multiple implemented features in same domain (≥2 features per domain)

**Skip if:** < 2 features per domain

**Verifies:** Similar problems solved similarly across features

**Algorithm:**

1. **Group by domain:** Extract domain from blast area precision labels (e.g., "High (domain-knowledge-auth)" → auth domain)
2. **For each domain with 2+ features:**
   - Identify common patterns: error handling, logging, validation, state management, API design
   - Query KB: "Compare [pattern] implementation across [feature A], [feature B], [feature C]"
   - Detect divergence
3. **Check intentionality:** If divergent, check if documented in Risks or Technical Decisions
4. **Classify findings:**

| Severity | Condition |
|----------|-----------|
| WARNING | Similar patterns implemented differently without documented rationale |
| INFO | Patterns intentionally different (documented in design) |
| INFO | Patterns are consistent across features |

**Example finding:**
```
WARNING: auth features use inconsistent error handling patterns
- feature-login: Returns error codes (401, 403, 500)
- feature-oauth: Throws custom exceptions (AuthException, TokenExpiredException)
- feature-mfa: Returns boolean success/failure
- No documented rationale for divergence
```

## Process

### Step 1: Run Applicable Checks

Execute checks 1-4 based on inputs available. Collect findings. Note skipped checks with reasons.

### Step 2: Present Audit Report (BLOCKING)

**Format:**

```
# Audit Report: <product>
Date: YYYY-MM-DD HH:MM
Features Audited: N features (M implemented)

## Summary
- Errors: N
- Warnings: N
- Info: N
- Checks Skipped: [list with reasons]

## Check 1: Dependency Integration
[Table if run, or "SKIPPED: No features with depends_on"]

## Check 2: Blast Area Overlaps
[Table if run, or "SKIPPED: No overlapping blast areas"]

## Check 3: Implementation Gaps
[Table if run, or "SKIPPED: < 2 implemented features"]

## Check 4: Pattern Consistency
[Table if run, or "SKIPPED: < 2 features per domain"]

## Verdict
[PASS | FAIL] - [Summary of ERRORs if FAIL]
```

**Present to user:** Show findings table, summary, then ask: "Proceed? **Fix** | **Accept** | **Done**"

### Step 3: Handle User Choice

**Fix:** Recommend actions for ERRORs and WARNINGs:

| Finding Type | Recommended Action |
|--------------|-------------------|
| Dependency integration broken | Fix integration in dependent feature, re-run `neat-sdd-gate` |
| Blast area conflict | Coordinate features - may need refactoring, re-run `neat-sdd-gate` for affected features |
| Implementation gap | Implement missing integration, update acceptance criteria verification |
| Pattern inconsistency | Align patterns or document intentional divergence in Technical Decisions |

**Accept:** Ask which findings to accept. Get one-line rationale per finding. Log in report under each finding.

**Done:** Save report as-is.

### Step 4: Save Audit Report

Save to `docs/specs/<product>/audit.md` (overwrite each run). Register in specs.md Outputs per [standard format](../references/output-conventions.md):

```markdown
- Audit: docs/specs/<product>/audit.md
```

If entry exists, replace. If new, append to Outputs section.

## Red Flags - Signs You're Skipping Checks

These thoughts mean STOP - you're rationalizing away verification:

- "Individual gates passed, integration must be fine"
- "Tests pass, so features integrate correctly"
- "Time pressure means skip deep checks"
- "Tech lead reviewed, don't need to verify code"
- "Just check documentation consistency"
- "Quick sanity check is enough"
- "Developer is tired, rubber-stamp to help"

**All of these mean: Run the full checks. No shortcuts.**

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Only checking documentation | Audit verifies IMPLEMENTATION integration, not docs |
| Accepting "tests pass" as sufficient | Individual tests don't verify cross-feature integration |
| Skipping code reading | Must read actual implementations, not infer from specs |
| Treating ERRORs as blocking without user input | User decides - present findings, don't auto-block |
| Running audit before implementation | Audit requires implemented features (`state: implemented`) |
| Using audit for single feature | Single feature → use `neat-sdd-gate` |
| Inferring integration from proximity | Proximity ≠ integration. Verify imports/usage in code |
| Skipping checks due to pressure | Pressure is when thorough verification matters most |
| Not using KB for deep verification | Spawn knowledge query for complex integration verification |

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Gates passed for each feature" | Gate checks single feature. Audit checks cross-feature integration. |
| "Tests pass individually" | Individual tests don't verify features work together. |
| "Time pressure justifies quick check" | Time pressure is when integration bugs emerge. Check thoroughly. |
| "Just verify docs are consistent" | Audit verifies code integration, not documentation. |
| "Tech lead approved each feature" | Individual approval doesn't verify cross-feature concerns. |
| "Developer exhausted, be helpful" | Helpful = finding bugs now, not rubber-stamping broken integration. |
| "Quick sanity check is enough" | Sanity check misses integration gaps. Run all applicable checks. |

## KB Registration

Register per [standard format](../references/output-conventions.md): `- Audit: docs/specs/<product>/audit.md`

## Output

`docs/specs/<product>/audit.md`

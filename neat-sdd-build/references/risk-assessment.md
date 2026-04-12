# Risk Assessment Algorithm

Risk-based gate triggering determines whether to run spec gates based on feature complexity and criticality.

## Design Phase Assessment

Run before Step 5 (design + plan verification).

**Risk signals:**

- Keywords in goal/criteria: `auth`, `payment`, `security`, `migration`, `database`, `breaking`, `API`
- ADRs extracted > 0 (architectural significance)
- Other features depend on this feature (incoming dependencies - breaking this breaks downstream features)

**Decision:**

- ANY risk signal → Run gate
- No risk signals → Skip gate, log decision

**Log format (skip):**

```text
Skipped design gate (low-risk feature: [X] files, no keywords, no dependencies)
```

**Log destination:** Console output during build execution. Not written to gate log file since gate doesn't run.

## Execute Phase Assessment

Run before Step 7 (code verification).

**Risk signals:**

- Git diff files ≥ 5
- Git diff lines (insertions + deletions) ≥ 200
- Keywords in diff: `auth`, `payment`, `security`, `migration`, `schema`, `breaking`, `deprecated`
- Modified files in critical paths: `auth/`, `payment/`, `security/`, `migrations/`, `api/`
- New database models or API endpoints

**Decision:**

- ANY risk signal → Run gate
- No risk signals → Skip gate, log decision

**Log format (skip):**

```text
Skipped execute gate (low-risk implementation: [X] files, [Y] lines changed)
```

**Log destination:** Console output during build execution. Not written to gate log file since gate doesn't run.

**Detection commands:**

```bash
git diff --stat main...HEAD                    # Count files and lines
git diff main...HEAD | grep -i "auth\|payment"  # Check for keywords
```

## Conservative Approach

The algorithm is designed to be conservative - ANY risk signal triggers the gate. This ensures:

- Critical features always get verified
- False negatives (missing a risky feature) are minimized
- False positives (running gate unnecessarily) are acceptable

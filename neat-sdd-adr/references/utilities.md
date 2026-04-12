# ADR Shared Utilities

Common operations used by both standalone and extraction modes.

## 1. ADR Numbering

Use today's date in `YYYYMMDD` format (e.g., `20260330`). Same-day ADRs share the number but have unique slugs. Zero collision/gap issues, chronologically ordered, distributed team-friendly.

**Examples:**

- Single: `20260330`
- Multiple same day: all `20260330` (different slugs)
- Concurrent branches: different dates = no conflicts

---

## 2. Filename Generation

Date number (utility #1) + lowercase title → spaces to hyphens → remove special chars → truncate 50 chars → `adr-{YYYYMMDD}-{slug}.md`.

**Examples:**

- "API v2.0" → `adr-20260330-api-v2-0.md`
- "Adopt Microservices" → `adr-20260330-adopt-microservices.md`
- "Database Migration Strategy" → `adr-20260415-database-migration-strategy.md`

---

## 3. Index Management

Maintain sorted index.md table (#, Title, Status, Feature, Date). Read → append rows → sort by date descending (newest first) → write. Parse failure: backup to `index.md.bak`, create fresh. Same-day ADRs sorted alphabetically by title.

**Example:**

```text
# | Title | Status | Feature | Date
20260331 | Logging Framework | Accepted | obs-01 | 2026-03-31
20260330 | API Versioning | Accepted | api-02 | 2026-03-30
20260330 | Caching Strategy | Accepted | perf-01 | 2026-03-30
```

---

## 4. specs.md Registration

Register ADR directory in Outputs section. Read specs.md → find `## Outputs` → add/update `- ADRs: docs/specs/<product>/adrs/ (N ADRs)` → write.

**Example:** `ADRs: docs/specs/myapp/adrs/ (5 ADRs)`

---

## 5. Path Resolution

Locate specs.md ([procedure](../../references/specs-location.md)) → extract product name → construct `<repo-root>/docs/specs/<product>/adrs/` → create dir if needed → return absolute path.

**Examples:** `myapp` → `.../docs/specs/myapp/adrs/`, `web` → `.../docs/specs/web/adrs/`

# ADR Common Mistakes

## Both Modes

| Mistake | Correct Approach |
|---------|------------------|
| Including "ADR-NNNN:" prefix in header | Use `# {title}` format (no prefix in title) |
| Skipping specs.md registration | Always register ADRs in Outputs section |
| Not creating output directory | Always check and create `docs/specs/<product>/adrs/` |
| Using sequential numbers | Use date-based `YYYYMMDD` format (e.g., `20260330`) |
| Including git operations | Never commit - users handle version control |

## Standalone Mode

| Mistake | Correct Approach |
|---------|------------------|
| Batch questions together | One question at a time, wait for response |
| Skip completeness check | Always verify all 5 components before generating |
| Generate without review | Always present ADR for user approval before saving |
| Accept vague responses | Ask follow-up questions until specific enough for ADR |
| Assume decision status | Ask if decision is already made (Accepted) or proposed (Proposed) |
| Save without user approval | Phase 3 review is mandatory - don't skip |

## Extraction Mode

| Mistake | Correct Approach |
|---------|------------------|
| No filtering before extraction | Filter for architectural significance, skip local/trivial decisions |
| Treating zero ADRs as failure | Zero ADRs is valid if no significant decisions—report extraction was triggered |
| Skip user confirmation | Present filtered decisions, get explicit approval before extraction |
| Sequential sub-agent spawning | Spawn ALL sub-agents in single parallel batch |
| Sub-agents return full content | Collect metadata only (number, title, filename) |
| Main agent generates ADRs | Sub-agents handle all generation, main agent just coordinates |
| Not assigning numbers upfront | Assign numbers before spawning sub-agents |
| Skip validation | Check "Key Decisions" section exists before proceeding |

**Note on Filtering:** Architecturally significant = multi-component impact, hard to reverse, involves trade-offs, affects non-functionals. Skip local/standard/trivial decisions. Many features have Key Decisions but zero ADR-worthy decisions—this is expected.

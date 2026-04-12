# Accessing Outputs

**neat-sdd works independently** - reads output files from docs/specs/ directly. Optional: Install [neat-knowledge](https://github.com/neatskills/neat-knowledge) for 80-90% context savings through progressive disclosure and automatic KB management (see [auto KB pattern](neat-knowledge.md)).

## Core Principle

**neat-sdd reads output files directly** (always works, higher context usage)

**Optional enhancement:** Use `neat-knowledge-query` for progressive disclosure (80-90% context savings)

- **Extract mode**: Structured JSON for skill-to-skill calls
- **Ask mode**: Natural language for human interaction

## Pattern (Optional Enhancement)

**neat-sdd always works** by reading files directly. Progressive disclosure is an **optional performance optimization**.

```markdown
Check: .index/metadata.json exists in docs/knowledge/?
  
YES → Progressive disclosure available (OPTIONAL ENHANCEMENT):
  - Use neat-knowledge-query extract mode
  - Summaries loaded first (~1-3K tokens)
  - Sections extracted on demand
  - Conversation caching (80-90% context savings)
  
NO → Direct reads (ALWAYS WORKS):
  - Read specs.md, parse KB entries
  - Read files directly from docs/specs/
  - Extract sections in main context
  - Same functionality, higher context usage
```

**Both modes produce identical results** - progressive disclosure is purely a performance optimization.

## Extract Mode (Optional - For Performance)

**Note:** This is an optional enhancement. Skills work without neat-knowledge by reading files directly.

**Command format (if neat-knowledge installed):**

```bash
/neat-knowledge-query extract <source> <options>
```

**Sources:**

- `analysis` - Analysis document layers (L0-L6)
- `domains` - Domain knowledge files
- `features` - Feature specifications
- `adrs` - Architectural Decision Records

**Common options:**

- `--sections <list>` - Specific sections to extract
- `--format json` - Output format (default)
- `--summary-only` - Return summaries without loading full content
- `--filter <condition>` - Filter results (features, ADRs)

### Examples

**Planning - Load context overview:**

```markdown
Invoke Skill tool:
  skill: neat-knowledge-query
  args: extract analysis --sections L1,L2,L3,L4,L5 --format json

Parse JSON response:
{
  "sections": {
    "L1": {
      "structured": {
        "tech_stack": ["Next.js 14", "React 18"],
        "dependencies": ["express", "prisma"]
      }
    },
    "L3": {
      "structured": {
        "components": ["API layer", "Auth service"],
        "architecture_pattern": "Monolithic"
      }
    }
  }
}

Extract: tech_stack, components for cross-checking
```

**Refinement - Load blast area context:**

```markdown
Invoke: neat-knowledge-query extract analysis --sections L3,L6 --format json
Parse: L3 components, L6 risks

Invoke: neat-knowledge-query extract domains --summary-only
Parse: Available domains for precision assessment

Use structured data for blast area derivation
```

**Build - Query patterns:**

```markdown
Invoke: neat-knowledge-query extract domains --domain 03-auth --sections token-rotation
Parse: investigation content for patterns

Use patterns in brainstorming context
```

**ADR - Get existing decisions:**

```markdown
Invoke: neat-knowledge-query extract adrs --summary-only
Parse: Array of existing ADRs with titles and decisions

Check for conflicts with new decision
```

### Response Structure

See [extract-mode-schema.md](../docs/architecture/extract-mode-schema.md) for complete schema.

**Key fields:**

- `source` - What was queried (analysis/domains/features/adrs)
- `loaded_from` - Where data came from (summary/full/cache)
- `sections` or `features` or `adrs` - Actual data
- `metadata` - Token counts, cache hits, timestamps

## Ask Mode (For Humans)

**Command format:**

```bash
/neat-knowledge-query ask <question>
```

**Returns:** Natural language answer with source citations

**Example:**

```markdown
User: /neat-knowledge-query ask "What auth patterns do we use?"

Response:
Based on the domain knowledge and analysis:

**Authentication Patterns:**
- JWT-based tokens with refresh mechanism
- OAuth2 for third-party integrations  
- Session-based fallback for legacy endpoints

Sources:
- analysis-myapp.md (L3, L6)
- domain-knowledge-03-auth.md (token-rotation investigation)
```

## KB State Definitions

**Minimal KB:** specs.md exists but has no Analysis entries AND no Domain Knowledge entries in Outputs section.

**Partial KB:** specs.md exists with Analysis but no Domain Knowledge entries.

**Full KB:** specs.md exists with both Analysis and Domain Knowledge entries.

Skills should check KB state in specs.md Outputs section to determine behavior (e.g., planning uses user-provided goal only when minimal; refinement uses Technical Decisions when minimal).

## Progressive Disclosure Benefits

**Context savings:**

- Summary-only queries: ~1-3K tokens vs ~10K for full file (70-85% savings)
- Section extraction: Load L1, L3 only = ~1.5K vs full file 10K (85% savings)
- Conversation caching: L1 loaded once, reused in later queries (0 tokens, instant)

**How it works:**

1. First query loads summaries (~1-3K tokens, cached by Claude)
2. Extract mode requests specific sections (L1, L3, L6)
3. neat-knowledge checks: sections in summary? Return summary
4. Not in summary? Spawn subagent to extract from full file
5. Cache sections in conversation memory
6. Future queries reuse cached sections (instant, no file load)

**Example conversation:**

```text
Query 1: extract analysis --sections L1,L3
  → Load summaries (1.5K), return L1, L3 from summary (500 tokens)
  → Context: 2K tokens

Query 2: extract analysis --sections L6  
  → L6 in summary (cache hit)
  → Return instantly (200 tokens)
  → Context: 2.2K tokens (no growth)

Query 3: extract analysis --sections L4,L5
  → Not in summary, spawn subagent
  → Extract L4, L5 (1.8K tokens)
  → Cache for future
  → Context: 4K tokens

Total loaded: 4K tokens vs 30K if loaded full file 3 times
Savings: 87%
```

## Direct Read Mode (Always Works)

**Standard operation without neat-knowledge:**

```markdown
Step X: Load KB Context

**Standard operation (always works):**

1. Read specs.md
2. Parse "Outputs" section for entries
3. Read files directly from docs/specs/
   - For analysis: Read full file, extract needed sections in main context
   - For domains: Read full file, extract needed sections
   - For features: Read feature files matching filter
4. Parse into structured data
5. Continue with skill logic

**With neat-knowledge (optional optimization):**

Check: .index/metadata.json exists in docs/knowledge/?
YES → Use neat-knowledge-query extract mode (80-90% context savings)
NO → Use standard operation above

Both paths produce same results, progressive disclosure is faster
```

## Usage in Skills

**Standard pattern (works always):**

```markdown
## Step X: Load Context from KB

**Default mode (always works):**

1. Read specs.md
2. Parse KB entries (Analysis, Domains, Features, ADRs)
3. Read files from docs/specs/
4. Extract needed sections in main context
5. Continue with skill logic

**Optional optimization (if neat-knowledge installed):**

Check: .index/metadata.json exists in docs/knowledge/?
If YES:
  - Invoke neat-knowledge-query extract <source> --sections <sections>
  - Parse JSON response (structured, predictable)
  - 80-90% context savings vs direct reads

If NO or invoke fails:
  - Use default mode above
  - Same results, higher context usage

**Both paths produce same data structure**
Skill logic works regardless of source
```

## Anti-Patterns

**DON'T:**

- Require neat-knowledge for basic functionality (neat-sdd must work independently)
- Fail if neat-knowledge unavailable (always have direct read fallback)
- Load full files multiple times without checking cache (when using neat-knowledge)

**DO:**

- Make neat-knowledge optional (check availability, don't require it)
- Support direct reads (always works, no dependencies)
- Use progressive disclosure when available (80-90% context savings)
- Request only sections needed when using extract mode
- Trust conversation caching when using neat-knowledge

**If using neat-knowledge extract mode:**

- Use --summary-only when full content not needed
- Request specific sections, not --sections all
- Trust conversation caching (sections loaded once)

## Schema Reference

Complete schema documentation: [docs/architecture/extract-mode-schema.md](../docs/architecture/extract-mode-schema.md)

**Key schemas:**

- Analysis: L0-L6 sections with structured fields (tech_stack, components, risks)
- Domains: Overview + investigations with structured content
- Features: Goal, criteria, risks, dependencies, blast area
- ADRs: Title, status, context, decision, consequences

## Progressive Disclosure Architecture

See complete design:

- [storage-architecture-final.md](../docs/architecture/storage-architecture-final.md) - Storage and independence
- [section-extraction-strategy.md](../docs/architecture/section-extraction-strategy.md) - Caching algorithm
- [progressive-disclosure-design.md](../docs/architecture/progressive-disclosure-design.md) - Full architecture

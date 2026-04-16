# Accessing Outputs

**neat-sdd works independently** - reads output files from docs/specs/ directly. Optional: Install [neat-knowledge](https://github.com/neatskills/neat-knowledge) for 80-90% context savings through agent-driven discovery and automatic KB management (see [auto KB pattern](neat-knowledge.md)).

## Core Principle

**neat-sdd reads output files directly** (always works, higher context usage)

**Optional enhancement:** Use `neat-knowledge-query` for agent-driven discovery (80-90% context savings)

- **Extract mode**: Intelligent discovery with structured JSON - agent evaluates relevance and loading depth
- **Ask mode**: Natural language for human interaction

## Pattern (Optional Enhancement)

**neat-sdd always works** by reading files directly. Agent-driven discovery is an **optional performance optimization**.

```markdown
Check: .index/metadata.json exists in docs/knowledge/?
  
YES → Agent-driven discovery available (OPTIONAL ENHANCEMENT):
  - Skills ask natural language questions
  - Search returns 20-30 keyword matches with metadata
  - Agent evaluates relevance and optimal loading depth
  - Content loaded based on intelligent ROI assessment
  - Conversation caching (80-90% context savings)
  
NO → Direct reads (ALWAYS WORKS):
  - Read specs.md, parse KB entries
  - Read files directly from docs/specs/
  - Extract sections in main context
  - Same functionality, higher context usage
```

**Both modes produce identical results** - agent-driven discovery is purely a performance optimization.

## Extract Mode (Optional - Agent-Driven Discovery)

**Note:** This is an optional enhancement. Skills work without neat-knowledge by reading files directly.

**New Architecture:** Instead of hard-coded section names, skills ask natural language questions. An agent intelligently evaluates what to load based on relevance and token cost.

**Command format (if neat-knowledge installed):**

```bash
/neat-knowledge-extract "<natural language query>"
```

**How it works:**

1. **Search stage:** Keyword filter returns 20-30 matches with rich metadata (summary, sections, token costs, tags)
2. **Agent evaluation:** Two-part decision:
   - **RELEVANCE:** Which documents are semantically relevant?
   - **DEPTH:** What loading depth? (summaries/sections/full)
3. **Load content:** Based on agent's ROI-optimized decision
4. **Return JSON:** Structured response with `loaded` field indicating depth

**Key benefits:**

- No hard-coded section names (L1, L2, L3, etc.)
- Intelligent relevance filtering (semantic, not just keywords)
- ROI optimization (token cost vs query needs)
- Adaptive depth (overview → summaries, technical → sections, deep → full)

### Examples

**Example 1 - Planning:**

```markdown
Invoke: neat-knowledge-extract "What is the tech stack, architectural components, integrations, and main workflows?"

Agent: Analysis relevant → load summary (2.5K tokens)
Returns: { "documents": [...], "loading_strategy": "summary", "tokens_loaded": 2500 }
Savings: 2.5K vs 8K+ full file (70% reduction)
```

**Example 2 - Refinement (multiple queries):**

```markdown
Invoke: neat-knowledge-extract "What are the architectural components and identified risks?"
Returns: Components + risks (1.8K tokens)

Invoke: neat-knowledge-extract "What domain knowledge is available?"
Returns: Domain summaries (600 tokens)

Total: 2.4K vs 10K+ direct reads (76% savings)
```

### Response Structure

**Key fields:**

- `documents[]` - Array of loaded documents
  - `filename` - Document filename
  - `title` - Document title
  - `category` - Category (analysis/domains/features/adrs)
  - `loaded` - Depth loaded (summary/sections/full)
  - `content` - Actual content based on agent decision
  - `tokens` - Token costs for ROI tracking
  - `tags` - Document tags
- `loading_strategy` - Overall strategy (summaries/sections/full/mixed)
- `tokens_loaded` - Total tokens loaded
- `total` - Number of documents returned

## Ask Mode (For Humans)

**Command format:**

```bash
/neat-knowledge-ask <question>
```

**Returns:** Natural language answer with source citations

**Example:**

```markdown
User: /neat-knowledge-ask "What auth patterns do we use?"

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

## Agent-Driven Discovery Benefits

**How it works:**

1. Skills ask natural language questions
2. Search returns 20-30 keyword matches with metadata (summaries, sections, token costs)
3. Agent makes two-part decision:
   - **RELEVANCE:** Which 2-5 docs semantically relevant?
   - **DEPTH:** What loading depth? (summary ~2-3K / sections ~1-2K / full ~8K)
4. Content loaded based on ROI, cached in conversation
5. Future queries reuse cache (instant, 0 tokens)

**Typical savings:** 70-85% vs direct reads. Multi-query conversations with caching can reach 90%.

## Usage in Skills

**Standard pattern for all skills:**

```markdown
## Step X: Load KB Context

Check: .index/metadata.json exists in docs/knowledge/?

If YES (agent-driven discovery):
  - Invoke: neat-knowledge-extract "<natural language query>"
  - Agent evaluates 20-30 keyword matches for relevance and depth
  - Returns: Structured JSON (80-90% context savings)

If NO (direct reads):
  - Read specs.md, parse KB entries
  - Read files from docs/specs/ (analysis, domains, features, ADRs)
  - Extract sections in main context
  - Same results, higher token usage

Both paths produce same data structure - skill logic works regardless
```

## Anti-Patterns

**DON'T:**

- Require neat-knowledge for basic functionality (neat-sdd must work independently)
- Fail if neat-knowledge unavailable (always have direct read fallback)
- Load full files multiple times without checking cache (when using neat-knowledge)
- Hard-code section names (L1, L2, L3, etc.) - use natural language queries
- Pre-filter results yourself - let the agent evaluate relevance
- Prescribe loading depth - let the agent decide based on ROI

**DO:**

- Make neat-knowledge optional (check availability, don't require it)
- Support direct reads (always works, no dependencies)
- Use agent-driven discovery when available (80-90% context savings)
- Ask clear, specific questions (what you need to know)
- Trust the agent to filter relevance and optimize depth
- Trust conversation caching when using neat-knowledge

**If using neat-knowledge extract mode:**

- Ask natural language questions focused on what you need
- Let the agent evaluate which documents are relevant
- Let the agent decide loading depth (summary/sections/full)
- Trust the agent's ROI optimization

## Formulating Effective Queries

**✓ Good:** Specific questions let agent optimize depth and filter relevance

- "What is the tech stack, architectural components, integrations, and main workflows?"
- "What authentication patterns, token handling, and security decisions exist?"
- "What architectural decisions have been made?"

**✗ Avoid:** Vague or prescriptive queries

- ~~"Tell me about the system"~~ → Too broad
- ~~"Load everything"~~ → Defeats optimization  
- ~~"Get analysis L1-L6"~~ → Hard-coded sections (old pattern)

**Multiple focused queries > one broad query.** Agent optimizes each individually, caches results, avoids loading unneeded content.

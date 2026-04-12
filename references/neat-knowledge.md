# Automatic Knowledge Management

When neat-knowledge skills are installed, neat-sdd automatically manages the project knowledge base.

## Skill Installation Check

Check if neat-knowledge skills are installed:

```bash
# Check both required skills
test -L ~/.claude/skills/neat-knowledge-ingest && \
test -L ~/.claude/skills/neat-knowledge-query && \
echo "installed" || echo "not-installed"
```

**Result:**

- `installed` → Enable automatic KB management
- `not-installed` → Continue without KB management (neat-sdd works independently)

## KB Detection

**Auto-ingest requires an initialized KB.** Users must initialize the KB once by ingesting any content via `/neat-knowledge-ingest`.

**Check sequence:**

1. Are neat-knowledge skills installed? (`test -L ~/.claude/skills/neat-knowledge-ingest`)
   - NO → Skip auto-ingest (neat-sdd works independently)

2. Does `docs/knowledge/.index/metadata.json` exist?
   - YES → KB initialized, proceed to ingestion
   - NO → Skip auto-ingest, log recommendation

**One-time KB initialization (user action):**

User runs `/neat-knowledge-ingest <any-file>` once. This prompts for KB location and creates:

- docs/knowledge/.index/metadata.json (KB metadata)
- docs/knowledge/.index/index.json (search index)
- docs/knowledge/.index/summaries/ (per-category summaries)

After initialization, all auto-ingest operations work seamlessly.

## Automatic Ingestion Points

### After Analysis (neat-sdd-analysis)

**When:** After saving `analysis-<product>.md` and `specs.md`

**Action:**

```markdown
Check: neat-knowledge skills installed?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && echo "installed" || echo "not-installed"
  
If "not-installed":
  Skip auto-ingest
  
If "installed":
  Check: docs/knowledge/.index/metadata.json exists?
  
  If NO:
    Skip auto-ingest
    Log: "To enable auto-indexing, initialize KB with: /neat-knowledge-ingest <any-file>"
    
  If YES:
    Invoke Skill tool:
      skill: neat-knowledge-ingest
      args: file docs/specs/<product>/analysis-<product>.md --category analysis
    Log: "✓ Indexed analysis in project KB"
```

### After Domain Investigation (neat-sdd-domains)

**When:** After saving `domain-knowledge-{NN}-{name}.md`

**Action:**

```markdown
Check: neat-knowledge skills installed AND KB initialized?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json
  
If YES:
  Invoke Skill tool:
    skill: neat-knowledge-ingest
    args: file docs/specs/<product>/domains/domain-knowledge-{NN}-{name}.md --category domains
  Log: "✓ Indexed domain knowledge in project KB"
  
If NO:
  Skip auto-ingest
```

### After ADR Creation (neat-sdd-adr)

**When:** After creating ADRs in `docs/specs/<product>/adrs/`

**Action:**

```markdown
Check: neat-knowledge skills installed AND KB initialized?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json
  
If YES:
  Invoke Skill tool:
    skill: neat-knowledge-ingest
    args: directory docs/specs/<product>/adrs/ --category adrs
  Log: "✓ Indexed {N} ADRs in project KB"
  
If NO:
  Skip auto-ingest
```

### After Feature Implementation (neat-sdd-build)

**When:** After updating feature doc to `state: implemented` with `## Status` section

**Action:**

```markdown
Check: neat-knowledge skills installed AND KB initialized?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && test -f docs/knowledge/.index/metadata.json
  
If YES:
  Invoke Skill tool:
    skill: neat-knowledge-ingest
    args: file docs/specs/<product>/features/feature-{goal}-{nn}-{slug}.md --category features
  Log: "✓ Indexed implemented feature in project KB"
  
If NO:
  Skip auto-ingest
```

**Why after implementation, not refinement:** The KB should contain actual capabilities (working code), not planned features (specs). Only implemented features are ingested.

## Benefits

**With automatic KB management:**

- Analysis immediately searchable via `neat-knowledge-query`
- Domain knowledge available for planning/refinement context
- ADRs indexed for conflict detection
- 80-90% context savings in downstream skills (planning, refinement, build)

**Without neat-knowledge:**

- neat-sdd works independently by reading files directly
- No performance optimization
- User can install neat-knowledge later and manually ingest content

## Implementation Pattern

**Standard pattern for all neat-sdd skills that generate content:**

```markdown
## Step X: Save and Register

1. Save file to docs/specs/<product>/<path>
2. Register in specs.md Outputs
3. Auto-ingest (if neat-knowledge available):

Check: neat-knowledge skills installed AND KB initialized?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && \
       test -f docs/knowledge/.index/metadata.json && \
       echo "ready" || echo "skip"
       
If "ready":
  Invoke: neat-knowledge-ingest <args>
  Log: "✓ Indexed in project KB"
  
If "skip":
  Skip auto-ingest
  (User can initialize KB with: /neat-knowledge-ingest <any-file>)
```

## Error Handling

**If KB initialization fails:**

- Log warning: "Could not initialize project KB"
- Continue without KB (neat-sdd works independently)
- Suggest manual installation

**If ingestion fails:**

- Log warning: "Could not index in KB"
- Continue without KB
- File is still saved and registered in specs.md
- User can manually ingest later

## User Experience

**Seamless integration:**

- User installs neat-knowledge → automatic KB management
- User doesn't install → neat-sdd works independently
- No user action required
- No failures or blockers

**Transparency:**

- Log messages confirm KB operations
- User knows content is indexed
- Clear feedback on what happened

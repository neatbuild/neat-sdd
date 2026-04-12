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

## Automatic KB Initialization

**When:** First time a neat-sdd skill needs to ingest content

**Check sequence:**

1. Does `docs/knowledge/.index/summaries.json` exist?
   - YES → KB exists, proceed to ingestion
   - NO → Initialize KB first

**KB Initialization:**

```markdown
Invoke Skill tool:
  skill: neat-knowledge-ingest
  args: --init-project-kb

This creates:
  - docs/knowledge/.index/summaries.json (empty KB index)
  - docs/knowledge/.index/metadata.json (kb_type: "project")
```

## Automatic Ingestion Points

### After Analysis (neat-sdd-analysis)

**When:** After saving `analysis-<product>.md` and `specs.md`

**Action:**

```markdown
Check: neat-knowledge skills installed?
If YES:
  1. Check/initialize KB (see above)
  2. Invoke Skill tool:
       skill: neat-knowledge-ingest
       args: file docs/specs/<product>/analysis-<product>.md --category analysis
  3. Log: "✓ Indexed analysis in project KB"
  
If NO:
  Skip (user can manually install neat-knowledge later)
```

### After Domain Investigation (neat-sdd-domains)

**When:** After saving `domain-knowledge-{NN}-{name}.md`

**Action:**

```markdown
Check: neat-knowledge skills installed?
If YES:
  1. Check/initialize KB (see above)
  2. Invoke Skill tool:
       skill: neat-knowledge-ingest
       args: file docs/specs/<product>/domains/domain-knowledge-{NN}-{name}.md --category domains
  3. Log: "✓ Indexed domain knowledge in project KB"
  
If NO:
  Skip
```

### After ADR Creation (neat-sdd-adr)

**When:** After creating ADRs in `docs/specs/<product>/adrs/`

**Action:**

```markdown
Check: neat-knowledge skills installed?
If YES:
  1. Check/initialize KB (see above)
  2. Invoke Skill tool:
       skill: neat-knowledge-ingest
       args: directory docs/specs/<product>/adrs/ --category adrs
  3. Log: "✓ Indexed {N} ADRs in project KB"
  
If NO:
  Skip
```

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

Check: neat-knowledge skills installed?
  Run: test -L ~/.claude/skills/neat-knowledge-ingest && \
       test -L ~/.claude/skills/neat-knowledge-query && \
       echo "installed" || echo "not-installed"
       
If "installed":
  Check: docs/knowledge/.index/summaries.json exists?
  If NO:
    Invoke: neat-knowledge-ingest --init-project-kb
    Log: "Initialized project KB at docs/knowledge/"
    
  Invoke: neat-knowledge-ingest <args>
  Log: "✓ Indexed in project KB"
  
If "not-installed":
  Skip auto-ingest
  Continue normally
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

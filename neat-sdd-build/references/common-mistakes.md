# Common Mistakes

## State & Resume

- Run Step 1.5; if status → "Build again?"
- Never skip

## Readiness

- If low → refinement
- Verify entry criteria

## Workflow

- Never skip: brainstorming, 2.5 (files), 3.5 (ADRs), 4 (plans), 4.5 (dependency analysis)
- Confirm discovered files
- Major ADR rejections = design issues
- 3 retry → escalate

## Dependency Analysis

- Build dependency graph first
- Identify layers (Layer 0 = independent, Layer 1+)
- Keep TDD sequences together (test→impl→commit)
- Use layers for execution strategy (not file organization)

## Layer Execution

- Spawn one agent per layer with `isolation: "worktree"`
- Pass all layer tasks to agent
- Agent decides execution strategy internally
- Integration tests after layer completes and worktree merged

## KB & Code

- Invoke knowledge before brainstorming
- KB = guidance, code = truth
- Key Decisions: H2 with H3 subsections

## Gates

- Never skip or proceed after FAIL
- 3 retry → escalate

## Completion

- Update feature status
- Offer next feature; feature branch

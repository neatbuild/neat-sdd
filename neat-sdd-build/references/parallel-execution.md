# Parallel Execution

## Overview

Spawn one agent per layer with worktree isolation. Layer agent receives all tasks and decides execution strategy internally.

## Requirements

- Layer with tasks
- `subagent-driven-development` or `dispatching-parallel-agents` available
- CPU/memory for concurrent agents

## Strategy

**One agent per layer** with full context and autonomy:

1. Receives all layer tasks
2. Decides strategy: sequential (`/subagent-driven-development`), parallel (`/dispatching-parallel-agents`), or mixed
3. Commits after each task
4. Returns when complete

**Build skill orchestrates layers, not tasks.**

## Algorithm

Per layer:

1. Spawn agent with `isolation: "worktree"`
2. Pass tasks, feature doc, design spec, dependencies
3. Wait for completion
4. Success → merge worktree → integration tests
5. Failure → present options (fix/retry or abort)
6. Next layer or stop

## Layer Agent Prompt

```text
Execute Layer N ({X} tasks) for feature: {feature-goal}

Context: Feature doc ({path}), design spec ({path}), dependencies ({completed-layers})

Tasks: {all-layer-tasks}

Instructions:
1. Analyze for dependencies and parallelization
2. Use `/subagent-driven-development` (sequential) or `/dispatching-parallel-agents` (parallel)
3. Commit after each task
4. Run integration tests after completion

Worktree: {worktree-path}, Branch: {branch-name}
```

## Worktree Isolation

- One worktree per layer (not per task group)
- Provides clean environment for layer work
- Auto-deletes if no changes
- Merges only successful layers
- Prevents conflicts between layers

## Failure Handling

**During layer execution:**

- Layer agent handles task failures internally
- Build skill only sees: success, partial completion, or full failure
- If layer fails → present options (fix/retry or abort layer)

**After merge:**

- Integration test failures suggest design gaps
- Max 3 retries per layer
- If repeated failures → escalate to user

## Benefits

1. Simpler orchestration (one agent per layer)
2. Agent autonomy (decides execution strategy)
3. Full context (sees all layer tasks)
4. Flexible parallelization (agent chooses when beneficial)
5. Fewer worktrees (one per layer)

## Example

Scenario: 25 tasks divided into 15 Layer 0, 8 Layer 1, 2 Layer 2.

```text
Build Skill:
  → Spawn Layer 0 agent (15 tasks, worktree-layer-0)
    Layer 0 agent analyzes:
      - Sees auth (5), API (5), utils (5)
      - Decides: use /dispatching-parallel-agents for 3 groups
      - Executes and commits each task
      - Runs integration tests
      - ✓ Returns success

  → Merge worktree-layer-0 → integration tests pass

  → Spawn Layer 1 agent (8 tasks, worktree-layer-1)
    Layer 1 agent analyzes:
      - Sees service tasks with some dependencies
      - Decides: sequential with /subagent-driven-development
      - Executes and commits each task
      - Runs integration tests
      - ✓ Returns success

  → Merge worktree-layer-1 → integration tests pass

  → Spawn Layer 2 agent (2 tasks, worktree-layer-2)
    Layer 2 agent:
      - Sequential execution
      - ✓ Returns success

  → Merge worktree-layer-2 → integration tests pass
  → All layers complete
```

## Trade-offs

**Pros:** Simpler orchestration (3 agents, not 9+), agent-driven parallelization, full context, fewer merges, easier debugging.

**Cons:** Requires smart agents, no guaranteed parallelization.

**Net:** Trust agents. Simpler is better.

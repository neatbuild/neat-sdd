# Dependency Analysis Algorithm

**MANDATORY for ALL plans.**

## Overview

Analyze task dependencies to identify execution layers. Layers determine execution strategy per layer.

## Process

### Step 1: Count Tasks

Grep `"^### Task \d+:"`, announce count.

### Step 2: Build Dependency Graph

1. Grep task references ("depends on Task N", "after Task N", "Task N → Task M")
2. Preserve TDD sequences (test + implementation)
3. Build adjacency list (Task → [dependencies])

**Example:**

```text
Task 1: Create schema
Task 2: Create model (depends on Task 1)
Task 3: Create service (depends on Task 2)
Task 4: Add logger utility
Task 5: Add error handler (depends on Task 4)
```

Graph: `1 → 2 → 3`, `4 → 5`

### Step 3: Identify Layers

- **Layer 0**: No dependencies (foundation)
- **Layer 1**: Depends only on Layer 0
- **Layer N**: Depends on Layer N-1

**Example:** L0: Task 1, 4 (independent); L1: Task 2, 5 (depend on L0); L2: Task 3 (depends on L1).

### Step 4: Present Analysis

```text
Plan: {N} tasks
Layers: L0: {X} (independent), L1: {Y}, L2: {Z}
TDD sequences: {W}
```

## Execution Strategy (Per Layer)

Execute layers sequentially. One agent per layer:

**Per layer:** Spawn agent with worktree, pass tasks/docs, agent decides strategy (sequential or parallel), commits after each task, merge → integration tests.

**Between layers:** Next layer starts only after previous passes tests.

## Example Flow

Scenario: 25 tasks divided into 15 Layer 0, 8 Layer 1, 2 Layer 2.

```text
Step 4.5: Dependency Analysis
  Layer 0: 15 tasks (auth: 5, API: 5, utils: 5)
  Layer 1: 8 tasks (services)
  Layer 2: 2 tasks (integration)

Step 6: Execution

  Layer 0 (15 tasks):
    → Spawn layer agent with worktree
    → Agent analyzes: sees auth, API, utils components
    → Agent decides: use /dispatching-parallel-agents
    → Agent executes and commits each task
    → Agent runs integration tests
    → Merge worktree → integration tests pass
    ✓ Layer 0 complete

  Layer 1 (8 tasks):
    → Spawn layer agent with worktree
    → Agent analyzes: sees service dependencies
    → Agent decides: sequential with /subagent-driven-development
    → Agent executes and commits each task
    → Agent runs integration tests
    → Merge worktree → integration tests pass
    ✓ Layer 1 complete

  Layer 2 (2 tasks):
    → Spawn layer agent with worktree
    → Agent executes sequentially
    → Merge worktree → integration tests pass
    ✓ Layer 2 complete

Step 7: Spec Gate (execute mode)
  → Verify all work against acceptance criteria
```

## Benefits

1. Safety: dependencies built first
2. Parallelization: independent tasks concurrent
3. Progress tracking: layer-by-layer
4. Failure isolation: validate before next layer
5. Flexible: parallel/sequential per layer

## Output

Single plan file: `YYYY-MM-DD-<feature>-plan.md`

No phase files. Dependency layers used as execution strategy only.

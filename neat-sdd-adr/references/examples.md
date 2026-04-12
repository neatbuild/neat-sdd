# ADR Examples

## Standalone Mode Conversation Example

```text
Q: "What decision are you documenting?"
A: "Migrating from monolith to microservices."

Q: "What problem prompted this?"
A: "Deployment bottleneck, teams can't deploy independently."

[Missing: alternatives, rationale, consequences]

Q: "What alternatives were considered?"
A: "Modular monolith, improved CI/CD on current monolith."

Q: "Why microservices?"
A: "Independent deployment and team autonomy are critical."

Q: "Trade-offs?"
A: "Positive: scaling, autonomy. Negative: complexity, latency, consistency."

[Complete → Phase 2]
```

## Generated MADR Example

Filename: `adr-001-microservices-architecture.md`

```markdown
# Microservices Architecture

**Status:** Accepted | **Date:** 2026-03-29 | **Feature:** Standalone | **Design Spec:** Standalone

## Context
Monolith deployment bottleneck prevents independent team deployments.

## Decision
Migrate to microservices, decompose by business capability.

**Alternatives:** Improved CI/CD, modular monolith
**Why microservices:** Independent deployment and team autonomy critical at scale.

## Consequences
**Positive:** Independent scaling, team autonomy, tech flexibility
**Negative:** Complexity, latency, data consistency, operational overhead
**Risks:** Distributed debugging, higher costs, new skills required
```

# Technical Domains

Taxonomy for categorizing technical investigations and domain knowledge.

## 7 Technical Domains (01-07)

| Domain | Depends On | Covers |
|--------|------------|--------|
| 01-infra | — | Hosting, scaling, networking, cloud resources, compute |
| 02-data | 01-infra | Databases, storage, data modeling, caching |
| 03-auth | 01-infra, 02-data | Authentication, authorization, security |
| 04-backend | 01-infra, 02-data, 03-auth | Architecture (monolith, microservices, serverless), API design, integrations |
| 05-frontend | 04-backend, 03-auth | Architecture (SPA, SSR, micro-frontends), UI, state, browser |
| 06-mobile | 04-backend, 03-auth | Architecture (native, cross-platform), app store, offline, push |
| 07-devops | all above | CI/CD, deployment, testing, monitoring |

## Business Domains (08-business-*)

Custom sub-domains for business logic.

**Format:** `08-business-{name}` (e.g., `08-business-orders`)

Each gets `domain-knowledge-08-business-{name}.md` file. Use DDD lens when applicable, otherwise adapt to product patterns.

## specs.md Registration

Registered under `## Business Domains` after `## Outputs`.

**Format:** `- {domain-id}: {description}`

**Example:**

```markdown
## Business Domains

- 08-business-orders: Order management and fulfillment
- 08-business-payments: Payment processing and transactions
```

Auto-registered during investigations.

## Usage

**Domains skill:** Present technical (01-07), list business (08-business-*), allow defining new, register in specs.md

**Other skills:** Tag features (planning), check gaps (audit), filter/organize (knowledge)

See [business-domains.md](business-domains.md) for investigation patterns.

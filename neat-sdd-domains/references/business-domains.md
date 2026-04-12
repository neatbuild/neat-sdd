# Business Sub-Domain Examples

Applies to any business sub-domain (orders, payments, inventory, etc.)

## For DDD Codebases

```markdown
#### Findings

##### Bounded Contexts
- Order Management (`src/orders/`)
- Payment (`src/payments/`)

##### Aggregates
- **Order** (root): OrderLine (entity), ShippingAddress (value object)
- **Payment** (root)

##### Domain Events
- OrderPlaced, OrderPaid, OrderShipped
- Event bus: `src/events/`

##### Business Rules
- Order immutable after payment (Order.modifyLine())
- Min order: $10 (Order.validate())

##### Invariants
- Order total = sum of lines
- Payment amount = order total
```

## For Non-DDD Codebases

```markdown
#### Findings

##### Business Entities
- `orders` (id, user_id, status, total, created_at)
- `order_items` (id, order_id, product_id, quantity, price)
- Related: payments, shipments

##### Business Rules (implementation)
- Validation: `OrderService.validate()` (line 45)
- Price calc: `OrderCalculator.calculateTotal()` (line 120)
- State transitions: `OrderStateMachine.php` (line 80)

##### Workflows
- Lifecycle: pending → paid → shipped → delivered
- Via `status` column + service methods
- Validated in `OrderService.updateStatus()`

##### Business Logic Patterns
- Service layer (`OrderService`, `PaymentService`)
- Model validation (`Order.php`, line 200)
```

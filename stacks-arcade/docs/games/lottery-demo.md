# Lottery Demo Contract (planned)

Outline for a simple pooled lottery demo. Contract logic is currently empty; this document captures expected features for future implementation.

## Concept
- Players buy tickets with STX for a chance to win the pooled jackpot.
- A deterministic draw (for demo) selects a winner after sales close.
- Winner receives jackpot minus optional fee; others get nothing.

## Draft Flow
- `open-round` sets ticket price, max tickets, sales window, optional fee bps.
- `buy-ticket` records buyer entry, enforces price, prevents duplicates if desired.
- `draw-winner` callable after sales window; selects winner via block height/time modulo ticket count.
- `claim` lets winner withdraw jackpot; optionally allows refunds if no tickets sold.

## Proposed State
- `rounds` map with id, status (open/closed/drawn), ticket price, fee, created/close heights, winning index.
- `entries` map or list storing buyer principals per round.
- `balances` map holding payouts owed.
- `next-round-id` data var.

## Error Set (draft)
- Round not open/closed, ticket price mismatch, sales closed, no entries, draw already run, zero claim.

## Implementation TODOs
- Implement constants and helpers in `contracts/lottery-demo.clar`.
- Replace example Vitest with cases for ticket purchase, draw, claim, and refund edge cases.
- Add event schema: ticket purchase, draw, claim, refund.

## Notes
- Use deterministic draw for local testing; document that it is not secure randomness.
- Consider max entry count to avoid memory blowups.
- If adding a fee, route to deployer balance with clear print events.
- Emit the winning ticket index along with winner principal to simplify indexers and UI updates.

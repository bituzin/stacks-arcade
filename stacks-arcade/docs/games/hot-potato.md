# Hot Potato Contract (planned)

Design sketch for a pass-the-potato game where players rotate custody of a staked pot before a timeout or random stop. Contract code is not implemented yet; this doc captures scope for future work.

## Concept
- Players join a lobby by staking a fixed amount.
- A timer/block-height countdown defines when the potato "explodes".
- Each pass extends/updates the timer; the current holder when the timer ends loses the stake to the others (or burns it to contract owner).

## Rough Flow
- `start-game` to initialize pot size, max players, duration.
- `join` to lock stake and become eligible to hold the potato.
- `pass (to principal)` callable by current holder while game is active; records pass count and updates holder.
- `settle` callable by anyone after timer expires; pays out winners and records result.
- `claim` to withdraw any credited payout.

## Proposed State
- `games` map storing id, status, pot size, players list/bitmap, current holder, expiration height, pass count, winner set.
- `balances` map for accrued payouts.
- `next-game-id` data var.

## Open Design Points
- Decide deterministic end condition (block time/height) for predictability in simnet.
- Should every pass require a micro-fee to prevent spamming?
- How to prevent griefing by refusing to pass (e.g., auto-pass after deadline)?
- Limit player count to avoid oversized tuples in clarity when storing pass history.

## Implementation TODOs
- Fill in `contracts/hot-potato.clar` with constants, data structures, and pass/settle logic.
- Replace example Vitest with scenarios covering pass success, expired game, and claims.
- Add event schema for analytics (pass, explode, claim).

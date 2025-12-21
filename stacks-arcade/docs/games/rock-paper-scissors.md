# Rock Paper Scissors Contract (planned)

Two-player wagered RPS. Contract code is a stub today; this outline documents expected game shape and helps align future implementation and tests.

## Intended Flow
- `create-challenge (wager uint) (move uint)` → creator locks wager and commits to move (0/1/2 = rock/paper/scissors). Ideally this is a commit-reveal hash for fairness.
- `accept-challenge (game-id uint) (move uint)` → challenger locks equal wager and reveals move.
- `reveal (game-id uint) (move uint) (salt (buff n))` → creator reveals committed move, contract resolves result, credits payouts.
- `claim` → withdraw owed balance.
- Optional: `cancel` if reveal not provided within deadline.

## Proposed State
- `games` map keyed by id with creator, challenger, wager, commitment/revealed move, status, winner, result string, deadline.
- `balances` map for owed payouts, `next-game-id` var for indexing.

## Rules
- rock (0) beats scissors (2)
- paper (1) beats rock (0)
- scissors (2) beats paper (1)
- tie → refund wagers

## Security Notes
- Use commit-reveal to avoid front-running; store commitment as hash of move+salt.
- Add timeout to allow challenger to reclaim funds if creator never reveals.
- Keep move representation small (uint) to simplify comparisons.
- Consider limiting max outstanding games per creator to prevent storage spam.

## Implementation TODOs
- Implement contract in `contracts/rock-paper-scissors.clar` with commit-reveal flow.
- Swap example Vitest with cases covering wins, ties, timeouts, and claims.
- Emit events for create, accept, reveal, and claim to aid explorers.

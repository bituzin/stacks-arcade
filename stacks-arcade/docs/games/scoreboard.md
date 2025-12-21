# Scoreboard Contract (planned)

Planned shared leaderboard to track per-player scores across games. Contract is a stub today; this doc outlines scope for future implementation.

## Use Case
- Record wins/losses/payout totals per principal.
- Enable frontends to fetch top players and personal stats.

## Draft API
- `record (player principal) (game (string-ascii 32)) (delta int)` → contract-only or admin-only to update score entries.
- `set-rank (player principal) (rank uint)` optional manual override.
- `reset-player (player principal)` to clear stats if needed.
- `claim-badge` optional function to mint/finalize milestones.

## Proposed State
- `scores` map keyed by player storing total games, wins, losses, last-game id/name, cumulative payout int.
- `ranks` map optional tier per player.
- `global` data var for admin/pricing controls.

## Read-Only Ideas
- `get-score (player)` → score tuple or none.
- `top (limit uint)` → paginated top players by wins/payouts (may require list or indexed data structure).
- `version` string constant.

## Implementation TODOs
- Fill `contracts/scoreboard.clar` with data structures and permission checks.
- Replace example Vitest with leaderboard tests: record, update, read-only pagination.
- Decide how game contracts authenticate (e.g., deployer-only, allowlist of principals).
- Ensure any leaderboard pagination fits within Clarity list size limits; consider returning slices rather than entire board.

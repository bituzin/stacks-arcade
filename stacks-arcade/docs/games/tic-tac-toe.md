# Tic Tac Toe Contract (planned)

Two-player wagered tic-tac-toe. Contract is a stub; this doc outlines intended game mechanics and implementation notes.

## Intended Flow
- `create-game (wager uint) (symbol uint)` → creator posts wager and chooses symbol (0 = X, 1 = O) or let contract assign.
- `join-game (game-id uint)` → challenger posts matching wager, gets opposite symbol, game opens.
- `make-move (game-id uint) (cell uint)` → active player marks cell 0-8; validates turn order, empty cell, game status.
- `settle (game-id uint)` → auto after every move; when win or draw detected, credits payouts (winner takes pot, draw refunds).
- `claim` → withdraw owed balances.

## Board Encoding
- Represent board as list of 9 uints or a single 9-digit base-3 int (0 empty, 1 X, 2 O) to minimize storage.

## Proposed State
- `games` map: id, creator, challenger, wager, board encoding, next-turn principal, status (open/active/settled), winner optional, moves count.
- `balances` map for owed payouts; `next-game-id` data var.

## Win Detection
- Precompute winning triplets [(0,1,2), (3,4,5), (6,7,8), (0,3,6), (1,4,7), (2,5,8), (0,4,8), (2,4,6)] and check after each move.

## Implementation TODOs
- Implement storage and move validation in `contracts/tic-tac-toe.clar`.
- Add Vitest cases for win, draw, invalid move, wrong turn, and claim.
- Emit events for create, join, move, settle, claim.

## Notes
- Enforce a max move count of 9 to prevent overflow; settle as draw when moves == 9.
- Consider inactivity timeout to allow reclaim if opponent stops playing.
- Normalize cell input as 0-8 to keep frontends simple; add guardrails for duplicate moves.

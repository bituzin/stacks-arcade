# Guess The Number Contract

Single-player guessing game. Players stake STX, pick a number between 0-9, and win 2x their wager if their guess matches the on-chain draw.

## Core Flow
- Play: `play (wager uint) (guess uint)` → validates guess range and wager bounds, transfers wager into contract, draws `draw-number`, stores game record, credits payout (2x wager) on a win, increments game id.
- Claim: `claim` → withdraws any owed balance to caller; errors if balance is zero.

## Draw Logic
- `draw-number` = `(stacks-block-height + stacks-block-time) mod 10`; deterministic/predictable and suitable only for demos.

## State
- `games` map keyed by `id` storing player, wager, guess, draw, winner flag, timestamp.
- `balances` map accrues owed winnings per player; cleared on claim.
- `next-game-id` data var increments per play.

## Read-Only
- `get-next-game-id` → current counter.
- `get-game (id)` → optional game tuple.
- `get-balance (who)` → owed microstacks.
- `get-version` → contract version string.

## Events (print)
- `play`: id, player, guess, draw, winner, winner-ascii, payout
- `claim`: player, amount

## Errors
- 400 invalid guess (> 9)
- 401 bet below `min-bet`
- 402 bet above `max-bet`
- 403 transfer failure
- 404 zero balance claim

## Notes
- Credit-then-claim avoids payout transfers inside game resolution.
- Adjust `min-bet`/`max-bet` to tune demo exposure. Consider better randomness for production use.
- `max-workers` is capped to 1 in Vitest config to avoid simnet contention; keep that when adding new tests.

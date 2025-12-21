# Higher / Lower Contract (planned)

Placeholder design for a number comparison game where players guess if the next draw is higher or lower than the previous value. Contract logic is not implemented yet; this doc captures intended shape so implementation can follow.

## Intended Flow
- Start round: deployer seeds an initial draw (or derive from block height/time) and opens a round.
- Guess: player submits `higher` or `lower` plus wager; validates bounds and locks wager.
- Reveal: contract draws next number (deterministic for demo), resolves guess, credits payout (2x wager) on success.
- Claim: players withdraw credited winnings via `claim`.

## Proposed State
- `rounds` map with `{id, opener, start-draw, end-draw?, status, created-at}`.
- `guesses` map keyed by `{round-id, player}` storing guess choice, wager, resolved flag, winner bool.
- `balances` map for accrued payouts.
- `next-round-id` data var to index rounds.

## Error Budget (draft)
- Invalid choice, wager below/above bounds, round not open, already guessed, transfer failure, zero claim.

## Open Questions
- Should multiple players join same round or is it single-player?
- Should draws be deterministic (block height/time) or seeded randomness per round?
- Does the opener get a fee share or only acts as coordinator?

## Implementation TODOs
- Flesh out contract constants and helper functions in `contracts/higher-lower.clar`.
- Replace example Vitest with real scenarios that cover win/loss/tie and claim flows.
- Add README snippet with CLI calls once flow is finalized.

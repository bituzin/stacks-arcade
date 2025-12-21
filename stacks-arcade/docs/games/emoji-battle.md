# Emoji Battle Contract

Two-player emoji duel where the creator stakes an emoji and wager, a challenger joins with their emoji, and the result is settled immediately based on a simple element matchup. Winners get the combined stake; ties refund both players.

## Core Flow
- Create: `create-game (stake uint) (emoji (string-ascii 10))` → validates emoji (fire/water/leaf), bounds on `stake`, transfers stake into contract, records open game, increments `next-game-id`.
- Join: `join-game (game-id uint) (emoji (string-ascii 10))` → challenger must not be creator, must join open game with allowed emoji, transfers matching stake, resolves battle, credits payouts, sets status to settled.
- Cancel: `cancel-game (game-id uint)` → creator-only, only while open/no challenger, credits stake back to creator, marks canceled.
- Claim: `claim` → withdraws any owed balance for caller.

## Matchup Rules
- fire beats leaf
- leaf beats water
- water beats fire
- same emoji = tie (both refunded)

## State
- `games` map keyed by `id` storing creator, optional challenger, stake, emoji choices, status (`open/settled/canceled`), optional winner principal, string result (`open/creator/challenger/tie/canceled`), `created_at` timestamp.
- `balances` map accrues owed STX per player (payouts credited, then withdrawn via `claim`).
- `next-game-id` data var counts games.

## Read-Only
- `get-next-game-id` → returns the next id before creation.
- `get-game (game-id)` → optional game tuple; useful for indexers.
- `get-balance (who)` → owed microstacks for an address.
- `get-version` → contract version string.

## Events (print)
- `create`: id, creator, stake, emoji, created timestamp
- `settle`: id, creator, challenger, result, winner, winner-ascii, payout
- `cancel`: id, creator
- `claim`: player, amount

## Errors
- 400 invalid emoji, 401 stake below min, 402 stake above max
- 403 not open, 404 already joined, 405 creator self-join, 406 transfer failure
- 407 not creator, 408 zero claim, 409 not found

## Notes
- Allowed emojis: "fire", "water", "leaf"; strings limited to 10 ASCII chars.
- Stakes default to min/max guard rails; adjust constants as needed for production.
- Credit-then-claim pattern keeps contract solvent before payout transfer.
- Settlement is synchronous at join time; there is no deferred randomness.
- Use `get-balance` before `claim` to surface user-facing owed amounts.

## Future Ideas
- Add a fee toggle or rake for the deployer to fund maintenance.
- Include an expiration time that cancels unjoined games automatically.
- Emit a short result code enum alongside the string message to simplify indexers.

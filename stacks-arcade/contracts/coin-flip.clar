;; title: coin-flip
;; version: 0.0.1
;; summary: Single-player coin flip game with escrowed wager.
;; description: Player picks heads/tails, funds wager, flips on-chain, and claims payout if they win.

;; traits
;;

;; token definitions
;;

;; constants
;;
;; Note: randomness uses block-height parity, which is predictable and not suitable for production wagers.
(define-constant contract-version "0.0.1")
(define-constant contract-admin none) ;; reserved for future controls
(define-constant min-bet u1000000) ;; 0.01 STX assuming microstacks
(define-constant max-bet u100000000) ;; 1 STX cap
(define-constant fee-bps u0) ;; no fee yet
(define-constant err-not-open (err u100))
(define-constant err-insufficient-bet (err u101))
(define-constant err-too-high-bet (err u102))
(define-constant err-invalid-pick (err u103))
(define-constant err-not-player (err u104))
(define-constant err-already-funded (err u105))
(define-constant err-not-funded (err u106))
(define-constant err-already-settled (err u107))
(define-constant err-transfer-failed (err u108))
(define-constant err-zero-claim (err u109))
(define-constant err-not-found (err u110))
(define-constant status-open u0)
(define-constant status-settled u1)
(define-constant status-canceled u2)

;; data vars
;;
(define-data-var next-game-id uint u0)

;; data maps
;;
;; game tuple shape: {id: uint, player: principal, wager: uint, pick: uint, funded: bool, status: uint, result: (optional uint), winner: bool}
(define-map games
  {id: uint}
  {
    id: uint,
    player: principal,
    wager: uint,
    pick: uint,
    funded: bool,
    status: uint,
    result: (optional uint),
    winner: bool
  }
)
(define-map balances
  {player: principal}
  {amount: uint}
)

;; user game history: {player} -> (list 1000 uint)
(define-map user-game-history
  {player: principal}
  {game-ids: (list 1000 uint)}
)

;; public functions
;;
(define-public (create-game (wager uint) (pick uint))
  (let
    (
      (game-id (var-get next-game-id))
    )
    (begin
      (asserts! (>= wager min-bet) err-insufficient-bet)
      (asserts! (<= wager max-bet) err-too-high-bet)
      (asserts! (or (is-eq pick u0) (is-eq pick u1)) err-invalid-pick)
      (let
        (
          (game {
            id: game-id,
            player: tx-sender,
            wager: wager,
            pick: pick,
            funded: false,
            status: status-open,
            result: none,
            winner: false
          })
        )
        (begin
          (print {event: "create", id: game-id, player: tx-sender, wager: wager, pick: pick})
          (map-set games {id: game-id} game)
          ;; update user-game-history
          (let (
            (current (default-to {game-ids: (list)} (map-get? user-game-history {player: tx-sender})))
            (updated (unwrap-panic (as-max-len? (append (get game-ids current) game-id) u1000)))
          )
            (map-set user-game-history {player: tx-sender} {game-ids: updated})
          )
          (var-set next-game-id (+ game-id u1))
          (ok game-id))))))
;; read-only: get all game ids for a user
(define-read-only (get-user-game-ids (player principal))
  (default-to (list) (get game-ids (map-get? user-game-history {player: player})))
)
(define-public (fund-game (game-id uint))
  (match (map-get? games {id: game-id})
    game
    (begin
      (asserts! (is-open? (get status game)) err-not-open)
      (unwrap! (assert-player (get player game)) err-not-player)
      (asserts! (not (get funded game)) err-already-funded)
      (let
        (
          (contract-principal (unwrap! (as-contract? () tx-sender) err-transfer-failed))
          (wager (get wager game))
        )
        (begin
          (unwrap! (stx-transfer? wager tx-sender contract-principal) err-transfer-failed)
          (print {event: "fund", id: game-id, player: tx-sender, wager: wager})
          (map-set games {id: (get id game)} (merge game {funded: true}))
          (ok true))))
    err-not-found))
(define-public (cancel-game (game-id uint))
  (match (map-get? games {id: game-id})
    game
    (begin
      (unwrap! (assert-player (get player game)) err-not-player)
      (asserts! (is-open? (get status game)) err-not-open)
      (asserts! (not (get funded game)) err-already-funded)
      (print {event: "cancel", id: game-id, player: tx-sender})
      (map-set games {id: (get id game)} (merge game {status: status-canceled}))
      (ok true))
    err-not-found))
(define-public (flip (game-id uint))
  (match (map-get? games {id: game-id})
    game
    (begin
      (asserts! (is-open? (get status game)) err-not-open)
      (asserts! (get funded game) err-not-funded)
      (unwrap! (assert-player (get player game)) err-not-player)
      (let
        (
          ;; Mix block height and block time to avoid trivial even/odd parity on height alone.
          (result (mod (+ stacks-block-height stacks-block-time) u2))
          (winner (is-eq result (get pick game)))
          (player (get player game))
          (wager (get wager game))
          (winner-ascii (unwrap-panic (to-ascii? winner)))
        )
        (let
          (
            (payout (if winner (* wager u2) u0))
            (updated (merge game {status: status-settled, result: (some result), winner: winner}))
          )
          (map-set games {id: (get id game)} updated)
          (print {event: "flip", id: game-id, player: tx-sender, result: result, winner: winner, winner-ascii: winner-ascii, payout: payout})
          (if (> payout u0)
            (let
              (
                (current (default-to u0 (get amount (map-get? balances {player: player}))))
              )
              (map-set balances {player: player} {amount: (+ current payout)}))
            true)
          (ok {result: result, winner: winner}))))
    err-not-found))
(define-public (claim)
  (let
    (
      (amount (default-to u0 (get amount (map-get? balances {player: tx-sender}))))
    )
    (asserts! (> amount u0) err-zero-claim)
    (let ((recipient tx-sender))
      (unwrap! (as-contract? ((with-stx amount)) (try! (stx-transfer? amount tx-sender recipient))) err-transfer-failed)
      (print {event: "claim", player: recipient, amount: amount}))
    (map-set balances {player: tx-sender} {amount: u0})
    (ok true)))

;; read only functions
;;
(define-read-only (get-next-game-id)
  (var-get next-game-id))
(define-read-only (get-game (game-id uint))
  (map-get? games {id: game-id}))
(define-read-only (get-balance (who principal))
  (default-to u0 (get amount (map-get? balances {player: who}))))
(define-read-only (get-version) contract-version)
(define-read-only (is-funded (game-id uint))
  (match (map-get? games {id: game-id})
    game (get funded game)
    false))
(define-read-only (get-result (game-id uint))
  (match (map-get? games {id: game-id})
    game (some {result: (get result game), winner: (get winner game)})
    none))

;; private functions
;;
(define-private (is-open? (status uint))
  (is-eq status status-open))
(define-private (is-settled? (status uint))
  (is-eq status status-settled))
(define-private (assert-player (player principal))
  (if (is-eq tx-sender player)
      (ok true)
      err-not-player))

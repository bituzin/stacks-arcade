;; title: emoji-battle
;; version: 0.0.1
;; summary: Two-player emoji duel with staked bets and simple element matchups.
;; description: Creator stakes an emoji and wager; a challenger joins with their emoji. Winner takes both stakes or both are refunded on a tie.

;; constants
(define-constant contract-version "0.0.1")
(define-constant status-open u0)
(define-constant status-settled u1)
(define-constant status-canceled u2)
(define-constant min-stake u0)
(define-constant max-stake u100000000) ;; 1 STX cap for demo
(define-constant emoji-fire "fire")
(define-constant emoji-water "water")
(define-constant emoji-leaf "leaf")
(define-constant err-invalid-emoji (err u400))
(define-constant err-stake-low (err u401))
(define-constant err-stake-high (err u402))
(define-constant err-not-open (err u403))
(define-constant err-already-joined (err u404))
(define-constant err-self-join (err u405))
(define-constant err-transfer (err u406))
(define-constant err-not-creator (err u407))
(define-constant err-zero-claim (err u408))
(define-constant err-not-found (err u409))

;; data vars
(define-data-var next-game-id uint u0)

;; data maps
;; game tuple: {id, creator, challenger, stake, emoji1, emoji2, status, winner, result, created-at}
(define-map games
  {id: uint}
  {
    id: uint,
    creator: principal,
    challenger: (optional principal),
    stake: uint,
    emoji1: (string-ascii 10),
    emoji2: (optional (string-ascii 10)),
    status: uint,
    winner: (optional principal),
    result: (string-ascii 10),
    created_at: uint
  }
)
(define-map balances {player: principal} {amount: uint})

;; private helpers
(define-private (is-open? (status uint))
  (is-eq status status-open))

(define-private (allowed-emoji? (emoji (string-ascii 10)))
  (or (is-eq emoji emoji-fire)
      (is-eq emoji emoji-water)
      (is-eq emoji emoji-leaf)))

(define-private (beats? (attacker (string-ascii 10)) (defender (string-ascii 10)))
  (or (and (is-eq attacker emoji-fire) (is-eq defender emoji-leaf))
      (and (is-eq attacker emoji-leaf) (is-eq defender emoji-water))
      (and (is-eq attacker emoji-water) (is-eq defender emoji-fire))))

(define-private (resolve-battle (emoji1 (string-ascii 10)) (emoji2 (string-ascii 10)) (creator principal) (challenger principal))
  (let
    (
      (winner
        (if (is-eq emoji1 emoji2)
          none
          (if (beats? emoji1 emoji2) (some creator) (some challenger))))
      (result (if (is-eq emoji1 emoji2) "tie" (if (beats? emoji1 emoji2) "creator" "challenger")))
    )
    {winner: winner, result: result}))

(define-private (credit (player principal) (amount uint))
  (let
    (
      (current (default-to u0 (get amount (map-get? balances {player: player}))))
    )
    (map-set balances {player: player} {amount: (+ current amount)})))

(define-private (assert-creator (expected principal))
  (if (is-eq tx-sender expected)
      (ok true)
      err-not-creator))

(define-private (contract-principal)
  (unwrap-panic (as-contract? () tx-sender)))

(define-private (winner->ascii (winner (optional principal)))
  (match winner
    some-w (unwrap-panic (to-ascii? some-w))
    (unwrap-panic (to-ascii? u"none"))))

;; public functions
(define-public (create-game (stake uint) (emoji (string-ascii 10)))
  (let
    (
      (game-id (var-get next-game-id))
      (created_at stacks-block-time)
      (self (contract-principal))
    )
    (begin
      (asserts! (allowed-emoji? emoji) err-invalid-emoji)
      (asserts! (>= stake min-stake) err-stake-low)
      (asserts! (<= stake max-stake) err-stake-high)
      (unwrap! (stx-transfer? stake tx-sender self) err-transfer)
      (map-set games {id: game-id}
        {
          id: game-id,
          creator: tx-sender,
          challenger: none,
          stake: stake,
          emoji1: emoji,
          emoji2: none,
          status: status-open,
          winner: none,
          result: "open",
          created_at: created_at
        })
      (var-set next-game-id (+ game-id u1))
      (print {event: "create", id: game-id, creator: tx-sender, stake: stake, emoji: emoji, at: created_at})
      (ok game-id))))

(define-public (join-game (game-id uint) (emoji (string-ascii 10)))
  (let ((game (unwrap! (map-get? games {id: game-id}) err-not-found)))
    (begin
      (asserts! (allowed-emoji? emoji) err-invalid-emoji)
      (asserts! (is-open? (get status game)) err-not-open)
      (asserts! (is-none (get challenger game)) err-already-joined)
      (asserts! (not (is-eq tx-sender (get creator game))) err-self-join)
      (let ((self (contract-principal)))
        (unwrap! (stx-transfer? (get stake game) tx-sender self) err-transfer))
      (let
        (
          (resolution (resolve-battle (get emoji1 game) emoji (get creator game) tx-sender))
          (updated (merge game {challenger: (some tx-sender), emoji2: (some emoji), status: status-settled}))
        )
        (let
          (
            (winner (get winner resolution))
            (result (get result resolution))
            (stake (get stake game))
          )
          (begin
            (if (is-none winner)
              (begin
                (credit (get creator game) stake)
                (credit tx-sender stake))
              (credit (default-to tx-sender winner) (* stake u2)))
            (map-set games {id: game-id} (merge updated {winner: winner, result: result}))
            (print {event: "settle", id: game-id, creator: (get creator game), challenger: tx-sender, result: result, winner: winner, winner-ascii: (winner->ascii winner), payout: (if (is-none winner) stake (* stake u2))})
            (ok {result: result, winner: winner})))))))

(define-public (cancel-game (game-id uint))
  (match (map-get? games {id: game-id})
    game
    (begin
      (asserts! (is-open? (get status game)) err-not-open)
      (asserts! (is-none (get challenger game)) err-already-joined)
      (unwrap! (assert-creator (get creator game)) err-not-creator)
      (credit (get creator game) (get stake game))
      (map-set games {id: game-id} (merge game {status: status-canceled, result: "canceled"}))
      (print {event: "cancel", id: game-id, creator: tx-sender})
      (ok true))
    err-not-found))

(define-public (claim)
  (let ((amount (default-to u0 (get amount (map-get? balances {player: tx-sender})))))
    (asserts! (> amount u0) err-zero-claim)
    (let ((recipient tx-sender))
      (unwrap! (as-contract? ((with-stx amount)) (try! (stx-transfer? amount tx-sender recipient))) err-transfer)
      (map-set balances {player: tx-sender} {amount: u0})
      (print {event: "claim", player: recipient, amount: amount})
      (ok true))))

;; read only functions
(define-read-only (get-next-game-id)
  (var-get next-game-id))

(define-read-only (get-game (game-id uint))
  (map-get? games {id: game-id}))

(define-read-only (get-balance (who principal))
  (default-to u0 (get amount (map-get? balances {player: who}))))

(define-read-only (get-version)
  contract-version)


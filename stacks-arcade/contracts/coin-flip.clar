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
(define-constant contract-version "0.0.1")
(define-constant contract-admin none) ;; reserved for future controls
(define-constant min-bet u1000000) ;; 0.01 STX assuming microstacks
(define-constant max-bet u100000000) ;; 1 STX cap
(define-constant fee-bps u0) ;; no fee yet

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

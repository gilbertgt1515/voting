;; ------------------------------------------------------------
;; escrow-v2.clar
;; Author: Moses Joseph
;; Purpose: Secure on-chain escrow between buyer and seller
;; Version: 2.0 (Refined)
;; ------------------------------------------------------------

;; ------------------------------------------------------------
;; Contract storage
;; ------------------------------------------------------------

(define-data-var buyer principal 'SP000000000000000000001ZKJ8ZZ)
(define-data-var seller principal 'SP000000000000000000002Q6VF78)
(define-data-var arbiter principal tx-sender) ;; optional third party
(define-data-var amount uint u0)
(define-data-var funded bool false)
(define-data-var released bool false)
(define-data-var cancelled bool false)

;; Custom error constants
(define-constant ERR-NOT-BUYER (err u401))
(define-constant ERR-NOT-SELLER (err u402))
(define-constant ERR-NOT-ARBITER (err u403))
(define-constant ERR-NOT-FUNDED (err u404))
(define-constant ERR-ALREADY-FUNDED (err u405))
(define-constant ERR-ALREADY-RELEASED (err u406))
(define-constant ERR-ALREADY-CANCELLED (err u407))

;; ------------------------------------------------------------
;; Function: init-escrow
;; Purpose: Initialize escrow with seller, buyer, and amount.
;; Only the arbiter (deployer) can set initial terms.
;; ------------------------------------------------------------
(define-public (init-escrow (buyer principal) (seller principal) (amount uint))
  (if (is-eq tx-sender (var-get arbiter))
      (begin
        (var-set buyer buyer)
        (var-set seller seller)
        (var-set amount amount)
        (ok {buyer: buyer, seller: seller, amount: amount}))
      ERR-NOT-ARBITER))

;; ------------------------------------------------------------
;; Function: fund
;; Purpose: Buyer funds the escrow by transferring STX into the contract.
;; ------------------------------------------------------------
(define-public (fund)
  (let (
        (buyer-addr (var-get buyer))
        (escrow-amount (var-get amount))
       )
    (if (not (is-eq tx-sender buyer-addr))
        ERR-NOT-BUYER
        (if (var-get funded)
            ERR-ALREADY-FUNDED
            (begin
              (stx-transfer? escrow-amount tx-sender (as-contract tx-sender))
              (var-set funded true)
              (ok {funded: true, amount: escrow-amount})
            )
        )
    )
  )
)

;; ------------------------------------------------------------
;; Function: release
;; Purpose: Release funds to seller once goods/services are confirmed.
;; Can be called by buyer or arbiter.
;; ------------------------------------------------------------
(define-public (release)
  (let (
        (seller-addr (var-get seller))
        (escrow-amount (var-get amount))
       )
    (if (not (var-get funded))
        ERR-NOT-FUNDED
        (if (var-get released)
            ERR-ALREADY-RELEASED
            (if (or (is-eq tx-sender (var-get buyer))
                    (is-eq tx-sender (var-get arbiter)))
                (begin
                  (stx-transfer? escrow-amount (as-contract tx-sender) seller-addr)
                  (var-set released true)
                  (ok {released: true, to: seller-addr})
                )
                ERR-NOT-BUYER)
        )
    )
  )
)

;; ------------------------------------------------------------
;; Function: cancel
;; Purpose: Refund buyer if transaction fails or goods not delivered.
;; Can be triggered by seller or arbiter.
;; ------------------------------------------------------------
(define-public (cancel)
  (let (
        (buyer-addr (var-get buyer))
        (escrow-amount (var-get amount))
       )
    (if (not (var-get funded))
        ERR-NOT-FUNDED
        (if (var-get cancelled)
            ERR-ALREADY-CANCELLED
            (if (or (is-eq tx-sender (var-get seller))
                    (is-eq tx-sender (var-get arbiter)))
                (begin
                  (stx-transfer? escrow-amount (as-contract tx-sender) buyer-addr)
                  (var-set cancelled true)
                  (ok {cancelled: true, refunded-to: buyer-addr})
                )
                ERR-NOT-SELLER)
        )
    )
  )
)

;; ------------------------------------------------------------
;; Read-only helper: get-escrow-status
;; Returns escrow participants and current state.
;; ------------------------------------------------------------
(define-read-only (get-escrow-status)
  (ok {
        buyer: (var-get buyer),
        seller: (var-get seller),
        arbiter: (var-get arbiter),
        amount: (var-get amount),
        funded: (var-get funded),
        released: (var-get released),
        cancelled: (var-get cancelled)
      })
)

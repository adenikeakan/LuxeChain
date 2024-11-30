;; Error codes
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

;; Data Types
(define-data-var last-item-id uint u0)

(define-map fashion-items
    { item-id: uint }
    {
        brand: (string-ascii 64),
        model: (string-ascii 64),
        serial-number: (string-ascii 32),
        creation-date: uint,
        initial-owner: principal,
        current-owner: principal,
        verified: bool,
        metadata: (string-utf8 256)
    }
)

;; Read-only functions
(define-read-only (get-fashion-item (item-id uint))
    (map-get? fashion-items { item-id: item-id })
)

(define-read-only (get-item-owner (item-id uint))
    (match (map-get? fashion-items { item-id: item-id })
        item (ok (get current-owner item))
        (err ERR_NOT_FOUND)
    )
)

;; Internal functions
(define-private (increment-item-id)
    (begin
        (var-set last-item-id (+ (var-get last-item-id) u1))
        (var-get last-item-id)
    )
)

;; Import traits and constants from other contracts
(use-trait sip009-nft-trait .sip009-nft-trait.sip009-nft-trait)
(contract-call? .fashion-item get-fashion-item)
(contract-call? .authentication is-authorized-verifier)

;; Contract Variables
(define-data-var contract-owner principal tx-sender)

;; Public Functions
(define-public (register-item 
    (brand (string-ascii 64))
    (model (string-ascii 64))
    (serial-number (string-ascii 32))
    (metadata (string-utf8 256)))
    (let
        ((new-id (increment-item-id))
         (sender tx-sender))
        (begin
            (asserts! (is-eq sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
            (map-set fashion-items
                { item-id: new-id }
                {
                    brand: brand,
                    model: model,
                    serial-number: serial-number,
                    creation-date: block-height,
                    initial-owner: sender,
                    current-owner: sender,
                    verified: false,
                    metadata: metadata
                }
            )
            (ok new-id)
        )
    )
)

(define-public (verify-item
    (item-id uint)
    (verification-method (string-ascii 64))
    (verification-details (string-utf8 256)))
    (let
        ((sender tx-sender))
        (begin
            (asserts! (is-authorized-verifier sender) ERR_NOT_AUTHORIZED)
            (asserts! (map-get? fashion-items { item-id: item-id }) ERR_NOT_FOUND)
            (map-set auth-records
                { item-id: item-id }
                {
                    verifier: sender,
                    timestamp: block-height,
                    verification-method: verification-method,
                    verification-details: verification-details
                }
            )
            (ok true)
        )
    )
)

(define-public (transfer-item
    (item-id uint)
    (new-owner principal))
    (let
        ((sender tx-sender)
         (item (unwrap! (map-get? fashion-items { item-id: item-id }) ERR_NOT_FOUND)))
        (begin
            (asserts! (is-eq (get current-owner item) sender) ERR_NOT_AUTHORIZED)
            (map-set fashion-items
                { item-id: item-id }
                (merge item { current-owner: new-owner })
            )
            (ok true)
        )
    )
)

;; Admin Functions
(define-public (add-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
        (map-set authorized-verifiers
            { verifier: verifier }
            { active: true }
        )
        (ok true)
    )
)

(define-public (remove-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
        (map-set authorized-verifiers
            { verifier: verifier }
            { active: false }
        )
        (ok true)
    )
)

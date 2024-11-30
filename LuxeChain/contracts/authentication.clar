;; Authentication Records
(define-map auth-records
    { item-id: uint }
    {
        verifier: principal,
        timestamp: uint,
        verification-method: (string-ascii 64),
        verification-details: (string-utf8 256)
    }
)

;; Authorized Verifiers
(define-map authorized-verifiers
    { verifier: principal }
    { active: bool }
)

;; Read-only functions
(define-read-only (is-authorized-verifier (verifier principal))
    (default-to
        false
        (get active (map-get? authorized-verifiers { verifier: verifier }))
    )
)

(define-read-only (get-auth-record (item-id uint))
    (map-get? auth-records { item-id: item-id })
)

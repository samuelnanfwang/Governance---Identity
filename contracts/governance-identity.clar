(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-not-found (err u103))
(define-constant err-invalid-degree (err u104))
(define-constant err-university-not-registered (err u105))

(define-data-var next-degree-id uint u1)
(define-data-var total-universities uint u0)
(define-data-var total-degrees uint u0)

(define-map universities principal
    {
        name: (string-ascii 100),
        verified: bool,
        registration-block: uint
    })

(define-map university-admins principal principal)

(define-map degrees uint
    {
        student-address: principal,
        university: principal,
        degree-type: (string-ascii 50),
        field-of-study: (string-ascii 100),
        graduation-year: uint,
        gpa: (string-ascii 10),
        issue-block: uint,
        metadata-uri: (optional (string-ascii 200))
    })

(define-map student-degrees principal (list 50 uint))

(define-map degree-owners uint principal)

(define-public (register-university (university principal) (name (string-ascii 100)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? universities university)) err-already-exists)
        (map-set universities university
            {
                name: name,
                verified: true,
                registration-block: stacks-block-height
            })
        (var-set total-universities (+ (var-get total-universities) u1))
        (ok true)))

(define-public (add-university-admin (university principal) (admin principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-some (map-get? universities university)) err-not-found)
        (map-set university-admins admin university)
        (ok true)))

(define-public (issue-degree 
    (student principal)
    (degree-type (string-ascii 50))
    (field-of-study (string-ascii 100))
    (graduation-year uint)
    (gpa (string-ascii 10))
    (metadata-uri (optional (string-ascii 200))))
    (let
        ((degree-id (var-get next-degree-id))
         (university (default-to tx-sender (map-get? university-admins tx-sender)))
         (current-degrees (default-to (list) (map-get? student-degrees student))))
        (asserts! (is-some (map-get? universities university)) err-university-not-registered)
        (asserts! (< (len current-degrees) u50) err-invalid-degree)
        (map-set degrees degree-id
            {
                student-address: student,
                university: university,
                degree-type: degree-type,
                field-of-study: field-of-study,
                graduation-year: graduation-year,
                gpa: gpa,
                issue-block: stacks-block-height,
                metadata-uri: metadata-uri
            })
        (map-set degree-owners degree-id student)
        (map-set student-degrees student (unwrap! (as-max-len? (append current-degrees degree-id) u50) err-invalid-degree))
        (var-set next-degree-id (+ degree-id u1))
        (var-set total-degrees (+ (var-get total-degrees) u1))
        (ok degree-id)))

(define-public (revoke-degree (degree-id uint))
    (let
        ((degree-info (unwrap! (map-get? degrees degree-id) err-not-found))
         (university (get university degree-info))
         (student (get student-address degree-info)))
        (asserts! (or 
            (is-eq tx-sender university)
            (is-eq tx-sender (default-to tx-sender (map-get? university-admins tx-sender)))
            (is-eq tx-sender contract-owner)) err-not-authorized)
        (map-delete degrees degree-id)
        (map-delete degree-owners degree-id)
        (var-set total-degrees (- (var-get total-degrees) u1))
        (ok true)))

(define-public (update-university-verification (university principal) (verified bool))
    (let
        ((uni-info (unwrap! (map-get? universities university) err-not-found)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set universities university
            (merge uni-info { verified: verified }))
        (ok true)))

(define-public (transfer-degree (degree-id uint) (new-owner principal))
    (let
        ((current-owner (unwrap! (map-get? degree-owners degree-id) err-not-found)))
        (asserts! (is-eq tx-sender current-owner) err-not-authorized)
        (map-set degree-owners degree-id new-owner)
        (ok true)))

(define-read-only (get-university-info (university principal))
    (map-get? universities university))

(define-read-only (get-degree-info (degree-id uint))
    (map-get? degrees degree-id))

(define-read-only (get-degree-owner (degree-id uint))
    (map-get? degree-owners degree-id))

(define-read-only (get-student-degrees (student principal))
    (map-get? student-degrees student))

(define-read-only (verify-degree (degree-id uint))
    (match (map-get? degrees degree-id)
        degree-info
        (match (map-get? universities (get university degree-info))
            uni-info
            (ok {
                valid: (get verified uni-info),
                degree: degree-info,
                university: (some uni-info)
            })
            (ok {
                valid: false,
                degree: degree-info,
                university: none
            }))
        (err err-not-found)))

(define-read-only (get-total-universities)
    (var-get total-universities))

(define-read-only (get-total-degrees)
    (var-get total-degrees))

(define-read-only (get-next-degree-id)
    (var-get next-degree-id))

(define-read-only (is-university-admin (admin principal))
    (map-get? university-admins admin))

(define-read-only (verify-student-degree (student principal) (degree-id uint))
    (match (map-get? degrees degree-id)
        degree-info
        (if (is-eq (get student-address degree-info) student)
            (match (map-get? universities (get university degree-info))
                uni-info
                (ok {
                    belongs-to-student: true,
                    verified-university: (get verified uni-info),
                    degree: degree-info,
                    university: (some uni-info)
                })
                (ok {
                    belongs-to-student: true,
                    verified-university: false,
                    degree: degree-info,
                    university: none
                }))
            (ok {
                belongs-to-student: false,
                verified-university: false,
                degree: degree-info,
                university: none
            }))
        (err err-not-found)))

(define-read-only (get-degrees-by-university (university principal))
    (ok (list)))

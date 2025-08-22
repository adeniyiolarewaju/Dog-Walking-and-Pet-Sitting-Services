;; GPS Tracking Smart Contract
;; Records location data, routes, and service completion verification

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-ROUTE-NOT-FOUND (err u401))
(define-constant ERR-INVALID-INPUT (err u402))
(define-constant ERR-BOOKING-NOT-FOUND (err u403))
(define-constant ERR-ROUTE-ALREADY-EXISTS (err u404))
(define-constant ERR-INVALID-COORDINATES (err u405))
(define-constant ERR-ROUTE-ALREADY-COMPLETED (err u406))
(define-constant ERR-INVALID-TIMESTAMP (err u407))

;; Data variables
(define-data-var next-route-id uint u1)
(define-data-var next-checkpoint-id uint u1)
(define-data-var next-photo-id uint u1)

;; Route data structure
(define-map routes
  { route-id: uint }
  {
    booking-id: uint,
    walker-id: uint,
    pet-id: uint,
    start-time: uint,
    end-time: uint,
    total-distance: uint,
    total-duration: uint,
    average-speed: uint,
    max-speed: uint,
    calories-burned: uint,
    steps-taken: uint,
    route-status: uint,
    weather-conditions: (string-ascii 100),
    route-notes: (string-ascii 500),
    created-at: uint,
    completed-at: uint
  }
)

;; GPS checkpoints along the route
(define-map gps-checkpoints
  { checkpoint-id: uint }
  {
    route-id: uint,
    latitude: int,
    longitude: int,
    altitude: uint,
    accuracy: uint,
    timestamp: uint,
    speed: uint,
    heading: uint,
    checkpoint-type: uint,
    notes: (string-ascii 200)
  }
)

;; Route checkpoints mapping
(define-map route-checkpoints
  { route-id: uint }
  { checkpoint-ids: (list 500 uint) }
)

;; Photo updates during service
(define-map service-photos
  { photo-id: uint }
  {
    route-id: uint,
    booking-id: uint,
    walker-id: uint,
    photo-hash: (string-ascii 64),
    photo-url: (string-ascii 200),
    caption: (string-ascii 300),
    latitude: int,
    longitude: int,
    timestamp: uint,
    photo-type: uint
  }
)

;; Route photos mapping
(define-map route-photos
  { route-id: uint }
  { photo-ids: (list 50 uint) }
)

;; Exercise metrics and activity data
(define-map exercise-metrics
  { route-id: uint }
  {
    walking-time: uint,
    running-time: uint,
    resting-time: uint,
    playing-time: uint,
    hydration-breaks: uint,
    bathroom-breaks: uint,
    social-interactions: uint,
    energy-level-start: uint,
    energy-level-end: uint,
    behavior-notes: (string-ascii 500),
    health-observations: (string-ascii 300)
  }
)

;; Route status constants
(define-constant ROUTE-STATUS-STARTED u1)
(define-constant ROUTE-STATUS-IN-PROGRESS u2)
(define-constant ROUTE-STATUS-COMPLETED u3)
(define-constant ROUTE-STATUS-CANCELLED u4)

;; Checkpoint type constants
(define-constant CHECKPOINT-START u1)
(define-constant CHECKPOINT-WAYPOINT u2)
(define-constant CHECKPOINT-REST u3)
(define-constant CHECKPOINT-PLAY u4)
(define-constant CHECKPOINT-END u5)

;; Photo type constants
(define-constant PHOTO-START u1)
(define-constant PHOTO-ACTIVITY u2)
(define-constant PHOTO-REST u3)
(define-constant PHOTO-END u4)
(define-constant PHOTO-INCIDENT u5)

;; Start GPS tracking for a booking
(define-public (start-route-tracking
  (booking-id uint)
  (walker-id uint)
  (pet-id uint)
  (start-latitude int)
  (start-longitude int)
  (weather-conditions (string-ascii 100))
)
  (let
    (
      (route-id (var-get next-route-id))
      (checkpoint-id (var-get next-checkpoint-id))
    )
    ;; Validate input
    (asserts! (> booking-id u0) ERR-INVALID-INPUT)
    (asserts! (> walker-id u0) ERR-INVALID-INPUT)
    (asserts! (> pet-id u0) ERR-INVALID-INPUT)
    (asserts! (and (>= start-latitude -90000000) (<= start-latitude 90000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= start-longitude -180000000) (<= start-longitude 180000000)) ERR-INVALID-COORDINATES)

    ;; Create route record
    (map-set routes
      { route-id: route-id }
      {
        booking-id: booking-id,
        walker-id: walker-id,
        pet-id: pet-id,
        start-time: block-height,
        end-time: u0,
        total-distance: u0,
        total-duration: u0,
        average-speed: u0,
        max-speed: u0,
        calories-burned: u0,
        steps-taken: u0,
        route-status: ROUTE-STATUS-STARTED,
        weather-conditions: weather-conditions,
        route-notes: "",
        created-at: block-height,
        completed-at: u0
      }
    )

    ;; Add starting checkpoint
    (map-set gps-checkpoints
      { checkpoint-id: checkpoint-id }
      {
        route-id: route-id,
        latitude: start-latitude,
        longitude: start-longitude,
        altitude: u0,
        accuracy: u0,
        timestamp: block-height,
        speed: u0,
        heading: u0,
        checkpoint-type: CHECKPOINT-START,
        notes: "Route started"
      }
    )

    ;; Initialize checkpoint list
    (map-set route-checkpoints
      { route-id: route-id }
      { checkpoint-ids: (list checkpoint-id) }
    )

    ;; Initialize photo list
    (map-set route-photos
      { route-id: route-id }
      { photo-ids: (list) }
    )

    ;; Increment counters
    (var-set next-route-id (+ route-id u1))
    (var-set next-checkpoint-id (+ checkpoint-id u1))

    (ok route-id)
  )
)

;; Add GPS checkpoint during route
(define-public (add-gps-checkpoint
  (route-id uint)
  (latitude int)
  (longitude int)
  (altitude uint)
  (accuracy uint)
  (speed uint)
  (heading uint)
  (checkpoint-type uint)
  (notes (string-ascii 200))
)
  (let
    (
      (route-data (unwrap! (map-get? routes { route-id: route-id }) ERR-ROUTE-NOT-FOUND))
      (checkpoint-id (var-get next-checkpoint-id))
    )
    ;; Validate route is active
    (asserts! (not (is-eq (get route-status route-data) ROUTE-STATUS-COMPLETED)) ERR-ROUTE-ALREADY-COMPLETED)

    ;; Validate coordinates
    (asserts! (and (>= latitude -90000000) (<= latitude 90000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= longitude -180000000) (<= longitude 180000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= checkpoint-type u1) (<= checkpoint-type u5)) ERR-INVALID-INPUT)

    ;; Add checkpoint
    (map-set gps-checkpoints
      { checkpoint-id: checkpoint-id }
      {
        route-id: route-id,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        accuracy: accuracy,
        timestamp: block-height,
        speed: speed,
        heading: heading,
        checkpoint-type: checkpoint-type,
        notes: notes
      }
    )

    ;; Update checkpoint list
    (let
      (
        (current-checkpoints (default-to (list) (get checkpoint-ids (map-get? route-checkpoints { route-id: route-id }))))
      )
      (map-set route-checkpoints
        { route-id: route-id }
        { checkpoint-ids: (unwrap! (as-max-len? (append current-checkpoints checkpoint-id) u500) ERR-INVALID-INPUT) }
      )
    )

    ;; Update route status if not already in progress
    (if (is-eq (get route-status route-data) ROUTE-STATUS-STARTED)
      (map-set routes
        { route-id: route-id }
        (merge route-data { route-status: ROUTE-STATUS-IN-PROGRESS })
      )
      true
    )

    ;; Increment checkpoint counter
    (var-set next-checkpoint-id (+ checkpoint-id u1))

    (ok checkpoint-id)
  )
)

;; Add photo update during service
(define-public (add-service-photo
  (route-id uint)
  (photo-hash (string-ascii 64))
  (photo-url (string-ascii 200))
  (caption (string-ascii 300))
  (latitude int)
  (longitude int)
  (photo-type uint)
)
  (let
    (
      (route-data (unwrap! (map-get? routes { route-id: route-id }) ERR-ROUTE-NOT-FOUND))
      (photo-id (var-get next-photo-id))
    )
    ;; Validate route is active
    (asserts! (not (is-eq (get route-status route-data) ROUTE-STATUS-COMPLETED)) ERR-ROUTE-ALREADY-COMPLETED)

    ;; Validate input
    (asserts! (> (len photo-hash) u0) ERR-INVALID-INPUT)
    (asserts! (> (len photo-url) u0) ERR-INVALID-INPUT)
    (asserts! (and (>= photo-type u1) (<= photo-type u5)) ERR-INVALID-INPUT)

    ;; Add photo record
    (map-set service-photos
      { photo-id: photo-id }
      {
        route-id: route-id,
        booking-id: (get booking-id route-data),
        walker-id: (get walker-id route-data),
        photo-hash: photo-hash,
        photo-url: photo-url,
        caption: caption,
        latitude: latitude,
        longitude: longitude,
        timestamp: block-height,
        photo-type: photo-type
      }
    )

    ;; Update photo list
    (let
      (
        (current-photos (default-to (list) (get photo-ids (map-get? route-photos { route-id: route-id }))))
      )
      (map-set route-photos
        { route-id: route-id }
        { photo-ids: (unwrap! (as-max-len? (append current-photos photo-id) u50) ERR-INVALID-INPUT) }
      )
    )

    ;; Increment photo counter
    (var-set next-photo-id (+ photo-id u1))

    (ok photo-id)
  )
)

;; Complete route tracking
(define-public (complete-route-tracking
  (route-id uint)
  (end-latitude int)
  (end-longitude int)
  (total-distance uint)
  (calories-burned uint)
  (steps-taken uint)
  (route-notes (string-ascii 500))
)
  (let
    (
      (route-data (unwrap! (map-get? routes { route-id: route-id }) ERR-ROUTE-NOT-FOUND))
      (checkpoint-id (var-get next-checkpoint-id))
      (duration (- block-height (get start-time route-data)))
    )
    ;; Validate route is active
    (asserts! (not (is-eq (get route-status route-data) ROUTE-STATUS-COMPLETED)) ERR-ROUTE-ALREADY-COMPLETED)

    ;; Validate coordinates
    (asserts! (and (>= end-latitude -90000000) (<= end-latitude 90000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= end-longitude -180000000) (<= end-longitude 180000000)) ERR-INVALID-COORDINATES)

    ;; Add ending checkpoint
    (map-set gps-checkpoints
      { checkpoint-id: checkpoint-id }
      {
        route-id: route-id,
        latitude: end-latitude,
        longitude: end-longitude,
        altitude: u0,
        accuracy: u0,
        timestamp: block-height,
        speed: u0,
        heading: u0,
        checkpoint-type: CHECKPOINT-END,
        notes: "Route completed"
      }
    )

    ;; Update checkpoint list
    (let
      (
        (current-checkpoints (default-to (list) (get checkpoint-ids (map-get? route-checkpoints { route-id: route-id }))))
      )
      (map-set route-checkpoints
        { route-id: route-id }
        { checkpoint-ids: (unwrap! (as-max-len? (append current-checkpoints checkpoint-id) u500) ERR-INVALID-INPUT) }
      )
    )

    ;; Calculate average speed (distance per time unit)
    (let
      (
        (avg-speed (if (> duration u0) (/ total-distance duration) u0))
      )
      ;; Update route with completion data
      (map-set routes
        { route-id: route-id }
        (merge route-data {
          end-time: block-height,
          total-distance: total-distance,
          total-duration: duration,
          average-speed: avg-speed,
          calories-burned: calories-burned,
          steps-taken: steps-taken,
          route-status: ROUTE-STATUS-COMPLETED,
          route-notes: route-notes,
          completed-at: block-height
        })
      )
    )

    ;; Increment checkpoint counter
    (var-set next-checkpoint-id (+ checkpoint-id u1))

    (ok true)
  )
)

;; Add exercise metrics
(define-public (add-exercise-metrics
  (route-id uint)
  (walking-time uint)
  (running-time uint)
  (resting-time uint)
  (playing-time uint)
  (hydration-breaks uint)
  (bathroom-breaks uint)
  (social-interactions uint)
  (energy-level-start uint)
  (energy-level-end uint)
  (behavior-notes (string-ascii 500))
  (health-observations (string-ascii 300))
)
  (let
    (
      (route-data (unwrap! (map-get? routes { route-id: route-id }) ERR-ROUTE-NOT-FOUND))
    )
    ;; Validate energy levels
    (asserts! (and (>= energy-level-start u1) (<= energy-level-start u10)) ERR-INVALID-INPUT)
    (asserts! (and (>= energy-level-end u1) (<= energy-level-end u10)) ERR-INVALID-INPUT)

    ;; Add exercise metrics
    (map-set exercise-metrics
      { route-id: route-id }
      {
        walking-time: walking-time,
        running-time: running-time,
        resting-time: resting-time,
        playing-time: playing-time,
        hydration-breaks: hydration-breaks,
        bathroom-breaks: bathroom-breaks,
        social-interactions: social-interactions,
        energy-level-start: energy-level-start,
        energy-level-end: energy-level-end,
        behavior-notes: behavior-notes,
        health-observations: health-observations
      }
    )

    (ok true)
  )
)

;; Read-only functions

;; Get route information
(define-read-only (get-route-info (route-id uint))
  (map-get? routes { route-id: route-id })
)

;; Get GPS checkpoint
(define-read-only (get-gps-checkpoint (checkpoint-id uint))
  (map-get? gps-checkpoints { checkpoint-id: checkpoint-id })
)

;; Get route checkpoints
(define-read-only (get-route-checkpoints (route-id uint))
  (map-get? route-checkpoints { route-id: route-id })
)

;; Get service photo
(define-read-only (get-service-photo (photo-id uint))
  (map-get? service-photos { photo-id: photo-id })
)

;; Get route photos
(define-read-only (get-route-photos (route-id uint))
  (map-get? route-photos { route-id: route-id })
)

;; Get exercise metrics
(define-read-only (get-exercise-metrics (route-id uint))
  (map-get? exercise-metrics { route-id: route-id })
)

;; Check if route is completed
(define-read-only (is-route-completed (route-id uint))
  (match (map-get? routes { route-id: route-id })
    route-data (is-eq (get route-status route-data) ROUTE-STATUS-COMPLETED)
    false
  )
)

;; Get route duration
(define-read-only (get-route-duration (route-id uint))
  (match (map-get? routes { route-id: route-id })
    route-data (get total-duration route-data)
    u0
  )
)

;; Get next route ID
(define-read-only (get-next-route-id)
  (var-get next-route-id)
)

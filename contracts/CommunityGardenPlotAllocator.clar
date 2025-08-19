;; GardenPlotAllocator: A decentralized system for community garden plot allocation
;; Core Data Structures
(define-map gardeners principal uint)         ;; Tracks gardeners and their preferred plots
(define-map garden-plots uint uint)           ;; Tracks plots and their preference counts
(define-data-var total-plots uint u0)         ;; Keeps count of available garden plots

;; Public function to register a new garden plot
(define-public (register-plot)
  (let ((plot-number (+ (var-get total-plots) u1)))
    (map-set garden-plots plot-number u0)     ;; Initialize preferences for the new plot to 0
    (var-set total-plots plot-number)         ;; Increment total-plots counter
    (ok plot-number)
  )
)

;; Public function to express preference for a garden plot
(define-public (choose-plot (plot-number uint))
  (let ((gardener tx-sender))
    (if (is-some (map-get? gardeners gardener))
        (err u3000)  ;; Error: Gardener has already chosen a preferred plot
        (if (is-none (map-get? garden-plots plot-number))
            (err u3001)  ;; Error: Garden plot does not exist
            (begin
              ;; Register the gardener's plot preference
              (map-set gardeners gardener plot-number)
              ;; Increment the plot's preference count
              (map-set garden-plots plot-number (+ (default-to u0 (map-get? garden-plots plot-number)) u1))
              (ok plot-number)
            )
        )
    )
  )
)

;; Read-only function to get total preferences for a plot
(define-read-only (get-plot-preferences (plot-number uint))
  (default-to u0 (map-get? garden-plots plot-number))
)

;; Read-only function to check if a gardener has chosen a plot
(define-read-only (has-chosen-plot (gardener principal))
  (is-some (map-get? gardeners gardener))
)

;; Read-only function to get the total number of available plots
(define-read-only (get-available-plots)
  (var-get total-plots)
)

;; Read-only function to find the higher preference count
(define-read-only (max-preferences (count-a uint) (count-b uint))
  (if (>= count-a count-b)
      count-a
      count-b
  )
)

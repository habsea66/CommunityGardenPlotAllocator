# Community Garden Plot Allocator

A decentralized smart contract system for fair allocation of community garden plots based on member preferences.

## Overview

The Garden Plot Allocator enables community members to express their preferences for available garden plots in a transparent and democratic way. Each gardener can choose one preferred plot, and the system tracks preference counts to facilitate fair allocation decisions.

## Features

- **Plot Registration**: Community managers can register new available garden plots
- **Preference Voting**: Gardeners can express preference for one plot per season
- **Transparent Tracking**: All preferences are recorded on-chain for transparency
- **Fair Allocation**: Preference counts help determine optimal plot assignments

## Smart Contract Functions

### Public Functions
- `register-plot()` - Register a new garden plot
- `choose-plot(plot-number)` - Express preference for a specific plot

### Read-Only Functions
- `get-plot-preferences(plot-number)` - Get preference count for a plot
- `has-chosen-plot(gardener)` - Check if gardener has made a choice
- `get-available-plots()` - Get total number of available plots

## Usage

Deploy the contract to the Stacks blockchain and interact through a web interface or CLI tools to manage community garden plot allocation fairly and transparently.
\`\`\`

```clarity file="project-2-startup-pitch/contracts/pitch-competition.clar"
;; PitchCompetition: A decentralized platform for startup pitch evaluation
;; Core Data Structures
(define-map investors principal uint)         ;; Tracks investors and their backed startups
(define-map startup-pitches uint uint)        ;; Tracks pitches and their backing counts
(define-data-var pitch-counter uint u0)       ;; Keeps count of total submitted pitches

;; Public function to submit a new startup pitch
(define-public (submit-pitch)
  (let ((pitch-id (+ (var-get pitch-counter) u1)))
    (map-set startup-pitches pitch-id u0)     ;; Initialize backing for the new pitch to 0
    (var-set pitch-counter pitch-id)          ;; Increment pitch-counter
    (ok pitch-id)
  )
)

;; Public function to back a startup pitch
(define-public (back-startup (pitch-id uint))
  (let ((investor tx-sender))
    (if (is-some (map-get? investors investor))
        (err u4000)  ;; Error: Investor has already backed a startup
        (if (is-none (map-get? startup-pitches pitch-id))
            (err u4001)  ;; Error: Startup pitch does not exist
            (begin
              ;; Register the investor's backing decision
              (map-set investors investor pitch-id)
              ;; Increment the pitch's backing count
              (map-set startup-pitches pitch-id (+ (default-to u0 (map-get? startup-pitches pitch-id)) u1))
              (ok pitch-id)
            )
        )
    )
  )
)

;; Read-only function to get total backing for a pitch
(define-read-only (get-backing-count (pitch-id uint))
  (default-to u0 (map-get? startup-pitches pitch-id))
)

;; Read-only function to check if an investor has backed any startup
(define-read-only (has-backed (investor principal))
  (is-some (map-get? investors investor))
)

;; Read-only function to get the total number of pitches
(define-read-only (get-total-pitches)
  (var-get pitch-counter)
)

;; Read-only function to compare backing counts
(define-read-only (higher-backing (backing-a uint) (backing-b uint))
  (if (>= backing-a backing-b)
      backing-a
      backing-b
  )
)

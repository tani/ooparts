;;; Generated checked memory places for the pinned SATCH layout.
;;; SPDX-License-Identifier: MIT; see licenses/satch-MIT.txt.

(uiop/package:define-package #:ooparts/sat/layout (:use #:cl #:ooparts/sat/runtime)
                             (:export #:analyzed-idx #:analyzed-idx-address
                              #:analyzed-stack-allocated #:analyzed-stack-allocated-address
                              #:analyzed-stack-begin #:analyzed-stack-begin-address
                              #:analyzed-stack-end #:analyzed-stack-end-address #:analyzed-stamp
                              #:analyzed-stamp-address #:averages-conflict-level
                              #:averages-conflict-level-address #:averages-decision-rate
                              #:averages-decision-rate-address #:averages-fast-exp
                              #:averages-fast-exp-address #:averages-fast-glue
                              #:averages-fast-glue-address #:averages-saved-decisions
                              #:averages-saved-decisions-address #:averages-slow-exp
                              #:averages-slow-exp-address #:averages-slow-glue
                              #:averages-slow-glue-address #:averages-trail-filled
                              #:averages-trail-filled-address #:clause-garbage
                              #:clause-garbage-address #:clause-glue #:clause-glue-address
                              #:clause-literals #:clause-literals-address #:clause-protected
                              #:clause-protected-address #:clause-redundant
                              #:clause-redundant-address #:clause-search #:clause-search-address
                              #:clause-shrunken #:clause-shrunken-address #:clause-size
                              #:clause-size-address #:clause-subsumed #:clause-subsumed-address
                              #:clause-used #:clause-used-address #:clause-vivify
                              #:clause-vivify-address #:clauses-allocated
                              #:clauses-allocated-address #:clauses-begin #:clauses-begin-address
                              #:clauses-end #:clauses-end-address #:control-allocated
                              #:control-allocated-address #:control-begin #:control-begin-address
                              #:control-end #:control-end-address #:flags-active
                              #:flags-active-address #:flags-eliminate #:flags-eliminate-address
                              #:flags-eliminated #:flags-eliminated-address #:flags-fixed
                              #:flags-fixed-address #:flags-subsume #:flags-subsume-address
                              #:header-binary #:header-binary-address #:header-blocking
                              #:header-blocking-address #:header-redundant
                              #:header-redundant-address #:heap-begin #:heap-begin-address
                              #:heap-end #:heap-end-address #:heap-factor #:heap-factor-address
                              #:heap-increment #:heap-increment-address #:heap-pos
                              #:heap-pos-address #:heap-score-slot #:heap-score-slot-address
                              #:heap-size #:heap-size-address #:int-stack-allocated
                              #:int-stack-allocated-address #:int-stack-begin
                              #:int-stack-begin-address #:int-stack-end #:int-stack-end-address
                              #:level-seen #:level-seen-address #:level-seen-count
                              #:level-seen-count-address #:level-seen-earliest
                              #:level-seen-earliest-address #:level-trail #:level-trail-address
                              #:limits-eliminate #:limits-eliminate-address
                              #:limits-eliminate-conflicts #:limits-eliminate-conflicts-address
                              #:limits-eliminate-fixed #:limits-eliminate-fixed-address
                              #:limits-eliminate-marked #:limits-eliminate-marked-address
                              #:limits-eliminate-search #:limits-eliminate-search-address
                              #:limits-eliminate-ticks #:limits-eliminate-ticks-address
                              #:limits-mode #:limits-mode-address #:limits-mode-conflicts
                              #:limits-mode-conflicts-address #:limits-mode-ticks
                              #:limits-mode-ticks-address #:limits-mode-ticks-interval
                              #:limits-mode-ticks-interval-address #:limits-mode-ticks-limit
                              #:limits-mode-ticks-limit-address #:limits-reduce
                              #:limits-reduce-address #:limits-reduce-conflicts
                              #:limits-reduce-conflicts-address #:limits-reduce-fixed
                              #:limits-reduce-fixed-address #:limits-rephase
                              #:limits-rephase-address #:limits-restart #:limits-restart-address
                              #:limits-subsume #:limits-subsume-address #:limits-subsume-marked
                              #:limits-subsume-marked-address #:limits-subsume-search
                              #:limits-subsume-search-address #:limits-subsume-ticks
                              #:limits-subsume-ticks-address #:limits-vivify
                              #:limits-vivify-address #:limits-vivify-conflicts
                              #:limits-vivify-conflicts-address #:limits-vivify-search
                              #:limits-vivify-search-address #:link-next #:link-next-address
                              #:link-prev #:link-prev-address #:link-stamp #:link-stamp-address
                              #:options-ascii #:options-ascii-address #:options-verbose
                              #:options-verbose-address #:profile-name #:profile-name-address
                              #:profile-start #:profile-start-address #:profile-time
                              #:profile-time-address #:profiles-begin #:profiles-begin-address
                              #:profiles-decide #:profiles-decide-address #:profiles-eliminate
                              #:profiles-eliminate-address #:profiles-end #:profiles-end-address
                              #:profiles-focused #:profiles-focused-address #:profiles-minishrink
                              #:profiles-minishrink-address #:profiles-parse
                              #:profiles-parse-address #:profiles-reduce #:profiles-reduce-address
                              #:profiles-solve #:profiles-solve-address #:profiles-stable
                              #:profiles-stable-address #:profiles-subsume
                              #:profiles-subsume-address #:profiles-total #:profiles-total-address
                              #:profiles-vivify #:profiles-vivify-address #:queue-first
                              #:queue-first-address #:queue-last #:queue-last-address #:queue-links
                              #:queue-links-address #:queue-search #:queue-search-address
                              #:queue-size #:queue-size-address #:queue-stamp #:queue-stamp-address
                              #:reluctant-u #:reluctant-u-address #:reluctant-v
                              #:reluctant-v-address #:rusage-ru-maxrss #:rusage-ru-maxrss-address
                              #:rusage-ru-stime #:rusage-ru-stime-address #:rusage-ru-utime
                              #:rusage-ru-utime-address #:solver-added #:solver-added-address
                              #:solver-analyzed #:solver-analyzed-address #:solver-averages
                              #:solver-averages-address #:solver-best #:solver-best-address
                              #:solver-bests #:solver-bests-address #:solver-binaries
                              #:solver-binaries-address #:solver-binary #:solver-binary-address
                              #:solver-blocks #:solver-blocks-address #:solver-capacity
                              #:solver-capacity-address #:solver-clause #:solver-clause-address
                              #:solver-control #:solver-control-address #:solver-dense
                              #:solver-dense-address #:solver-extend #:solver-extend-address
                              #:solver-flags #:solver-flags-address #:solver-frames
                              #:solver-frames-address #:solver-inconsistent
                              #:solver-inconsistent-address #:solver-irredundant
                              #:solver-irredundant-address #:solver-iterate
                              #:solver-iterate-address #:solver-level #:solver-level-address
                              #:solver-levels #:solver-levels-address #:solver-limits
                              #:solver-limits-address #:solver-marks #:solver-marks-address
                              #:solver-options #:solver-options-address #:solver-poisoned
                              #:solver-poisoned-address #:solver-position #:solver-position-address
                              #:solver-profiles #:solver-profiles-address #:solver-proof
                              #:solver-proof-address #:solver-put #:solver-put-address
                              #:solver-queue #:solver-queue-address #:solver-reasons
                              #:solver-reasons-address #:solver-redundant
                              #:solver-redundant-address #:solver-reluctant
                              #:solver-reluctant-address #:solver-removable
                              #:solver-removable-address #:solver-resolvents
                              #:solver-resolvents-address #:solver-saved #:solver-saved-address
                              #:solver-scores #:solver-scores-address #:solver-shrunken
                              #:solver-shrunken-address #:solver-size #:solver-size-address
                              #:solver-sorted #:solver-sorted-address #:solver-sorter
                              #:solver-sorter-address #:solver-stable #:solver-stable-address
                              #:solver-statistics #:solver-statistics-address #:solver-status
                              #:solver-status-address #:solver-target #:solver-target-address
                              #:solver-targets #:solver-targets-address #:solver-trail
                              #:solver-trail-address #:solver-unassigned
                              #:solver-unassigned-address #:solver-values #:solver-values-address
                              #:solver-vivification-schedule #:solver-vivification-schedule-address
                              #:solver-vivify-marks #:solver-vivify-marks-address
                              #:solver-vivifying #:solver-vivifying-address #:solver-watches
                              #:solver-watches-address #:statistics-activated
                              #:statistics-activated-address #:statistics-added
                              #:statistics-added-address #:statistics-bests
                              #:statistics-bests-address #:statistics-bumped
                              #:statistics-bumped-address #:statistics-chrono
                              #:statistics-chrono-address #:statistics-chronosaved
                              #:statistics-chronosaved-address #:statistics-collected
                              #:statistics-collected-address #:statistics-conflicts
                              #:statistics-conflicts-address #:statistics-decisions
                              #:statistics-decisions-address #:statistics-deduced
                              #:statistics-deduced-address #:statistics-deleted
                              #:statistics-deleted-address #:statistics-eliminated
                              #:statistics-eliminated-address #:statistics-elimination-ticks
                              #:statistics-elimination-ticks-address #:statistics-eliminations
                              #:statistics-eliminations-address #:statistics-fixed
                              #:statistics-fixed-address #:statistics-incremented
                              #:statistics-incremented-address #:statistics-irredundant
                              #:statistics-irredundant-address #:statistics-learned
                              #:statistics-learned-address #:statistics-marked-eliminate
                              #:statistics-marked-eliminate-address #:statistics-marked-subsume
                              #:statistics-marked-subsume-address #:statistics-minimized
                              #:statistics-minimized-address #:statistics-moved
                              #:statistics-moved-address #:statistics-probing-ticks
                              #:statistics-probing-ticks-address #:statistics-propagations
                              #:statistics-propagations-address #:statistics-reasons
                              #:statistics-reasons-address #:statistics-reduced
                              #:statistics-reduced-address #:statistics-reductions
                              #:statistics-reductions-address #:statistics-redundant
                              #:statistics-redundant-address #:statistics-remaining
                              #:statistics-remaining-address #:statistics-rephased
                              #:statistics-rephased-address #:statistics-reported
                              #:statistics-reported-address #:statistics-rescored
                              #:statistics-rescored-address #:statistics-resolutions
                              #:statistics-resolutions-address #:statistics-restamped
                              #:statistics-restamped-address #:statistics-restarts
                              #:statistics-restarts-address #:statistics-reused
                              #:statistics-reused-address #:statistics-sections
                              #:statistics-sections-address #:statistics-shrunken
                              #:statistics-shrunken-address #:statistics-solved
                              #:statistics-solved-address #:statistics-strengthened
                              #:statistics-strengthened-address #:statistics-subsumed
                              #:statistics-subsumed-address #:statistics-subsumption-ticks
                              #:statistics-subsumption-ticks-address #:statistics-subsumptions
                              #:statistics-subsumptions-address #:statistics-switched
                              #:statistics-switched-address #:statistics-targets
                              #:statistics-targets-address #:statistics-ticks
                              #:statistics-ticks-address #:statistics-variables
                              #:statistics-variables-address #:statistics-vivifications
                              #:statistics-vivifications-address #:statistics-vivified
                              #:statistics-vivified-address #:statistics-vivify-conflicts
                              #:statistics-vivify-conflicts-address #:statistics-vivify-implied
                              #:statistics-vivify-implied-address #:statistics-vivify-probes
                              #:statistics-vivify-probes-address #:statistics-vivify-propagations
                              #:statistics-vivify-propagations-address #:statistics-vivify-reused
                              #:statistics-vivify-reused-address #:statistics-vivify-strengthened
                              #:statistics-vivify-strengthened-address #:statistics-vivify-subsume
                              #:statistics-vivify-subsume-address #:timeval-tv-sec
                              #:timeval-tv-sec-address #:timeval-tv-usec #:timeval-tv-usec-address
                              #:trail-begin #:trail-begin-address #:trail-end #:trail-end-address
                              #:trail-propagate #:trail-propagate-address
                              #:unsigned-stack-allocated #:unsigned-stack-allocated-address
                              #:unsigned-stack-begin #:unsigned-stack-begin-address
                              #:unsigned-stack-end #:unsigned-stack-end-address #:watch-clause-slot
                              #:watch-clause-slot-address #:watch-header #:watch-header-address
                              #:watches-allocated #:watches-allocated-address #:watches-begin
                              #:watches-begin-address #:watches-end #:watches-end-address))

(in-package #:ooparts/sat/layout)

(defmacro analyzed-idx-address (object) `(+ ,object 0))

(defmacro analyzed-idx (object) `(m-u32 (+ ,object 0)))

(defsetf analyzed-idx (object) (value) `(setf (m-u32 (+ ,object 0)) ,value))

(defmacro analyzed-stack-allocated-address (object) `(+ ,object 16))

(defmacro analyzed-stack-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf analyzed-stack-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro analyzed-stack-begin-address (object) `(+ ,object 0))

(defmacro analyzed-stack-begin (object) `(m-ptr (+ ,object 0)))

(defsetf analyzed-stack-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro analyzed-stack-end-address (object) `(+ ,object 8))

(defmacro analyzed-stack-end (object) `(m-ptr (+ ,object 8)))

(defsetf analyzed-stack-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro analyzed-stamp-address (object) `(+ ,object 4))

(defmacro analyzed-stamp (object) `(m-u32 (+ ,object 4)))

(defsetf analyzed-stamp (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro averages-conflict-level-address (object) `(+ ,object 0))

(defmacro averages-conflict-level (object) `(m-f64 (+ ,object 0)))

(defsetf averages-conflict-level (object) (value) `(setf (m-f64 (+ ,object 0)) ,value))

(defmacro averages-decision-rate-address (object) `(+ ,object 32))

(defmacro averages-decision-rate (object) `(m-f64 (+ ,object 32)))

(defsetf averages-decision-rate (object) (value) `(setf (m-f64 (+ ,object 32)) ,value))

(defmacro averages-fast-exp-address (object) `(+ ,object 56))

(defmacro averages-fast-exp (object) `(m-f64 (+ ,object 56)))

(defsetf averages-fast-exp (object) (value) `(setf (m-f64 (+ ,object 56)) ,value))

(defmacro averages-fast-glue-address (object) `(+ ,object 48))

(defmacro averages-fast-glue (object) `(m-f64 (+ ,object 48)))

(defsetf averages-fast-glue (object) (value) `(setf (m-f64 (+ ,object 48)) ,value))

(defmacro averages-saved-decisions-address (object) `(+ ,object 40))

(defmacro averages-saved-decisions (object) `(m-u64 (+ ,object 40)))

(defsetf averages-saved-decisions (object) (value) `(setf (m-u64 (+ ,object 40)) ,value))

(defmacro averages-slow-exp-address (object) `(+ ,object 16))

(defmacro averages-slow-exp (object) `(m-f64 (+ ,object 16)))

(defsetf averages-slow-exp (object) (value) `(setf (m-f64 (+ ,object 16)) ,value))

(defmacro averages-slow-glue-address (object) `(+ ,object 8))

(defmacro averages-slow-glue (object) `(m-f64 (+ ,object 8)))

(defsetf averages-slow-glue (object) (value) `(setf (m-f64 (+ ,object 8)) ,value))

(defmacro averages-trail-filled-address (object) `(+ ,object 24))

(defmacro averages-trail-filled (object) `(m-f64 (+ ,object 24)))

(defsetf averages-trail-filled (object) (value) `(setf (m-f64 (+ ,object 24)) ,value))

(defmacro clause-garbage-address (object) `(+ ,object 0))

(defmacro clause-garbage (object) `(ldb (byte 1 0) (m-u8 (+ ,object 0))))

(defsetf clause-garbage (object) (value) `(set-bits (+ ,object 0) 0 1 ,value))

(defmacro clause-glue-address (object) `(+ ,object 4))

(defmacro clause-glue (object) `(m-u32 (+ ,object 4)))

(defsetf clause-glue (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro clause-literals-address (object) `(+ ,object 16))

(defmacro clause-literals (object) `(+ ,object 16))

(defsetf clause-literals (object) (value) `(copy-bytes (+ ,object 16) ,value 8))

(defmacro clause-protected-address (object) `(+ ,object 0))

(defmacro clause-protected (object) `(ldb (byte 1 1) (m-u8 (+ ,object 0))))

(defsetf clause-protected (object) (value) `(set-bits (+ ,object 0) 1 1 ,value))

(defmacro clause-redundant-address (object) `(+ ,object 0))

(defmacro clause-redundant (object) `(ldb (byte 1 2) (m-u8 (+ ,object 0))))

(defsetf clause-redundant (object) (value) `(set-bits (+ ,object 0) 2 1 ,value))

(defmacro clause-search-address (object) `(+ ,object 8))

(defmacro clause-search (object) `(m-u32 (+ ,object 8)))

(defsetf clause-search (object) (value) `(setf (m-u32 (+ ,object 8)) ,value))

(defmacro clause-shrunken-address (object) `(+ ,object 0))

(defmacro clause-shrunken (object) `(ldb (byte 1 6) (m-u8 (+ ,object 0))))

(defsetf clause-shrunken (object) (value) `(set-bits (+ ,object 0) 6 1 ,value))

(defmacro clause-size-address (object) `(+ ,object 12))

(defmacro clause-size (object) `(m-u32 (+ ,object 12)))

(defsetf clause-size (object) (value) `(setf (m-u32 (+ ,object 12)) ,value))

(defmacro clause-subsumed-address (object) `(+ ,object 0))

(defmacro clause-subsumed (object) `(ldb (byte 1 3) (m-u8 (+ ,object 0))))

(defsetf clause-subsumed (object) (value) `(set-bits (+ ,object 0) 3 1 ,value))

(defmacro clause-used-address (object) `(+ ,object 0))

(defmacro clause-used (object) `(ldb (byte 2 4) (m-u8 (+ ,object 0))))

(defsetf clause-used (object) (value) `(set-bits (+ ,object 0) 4 2 ,value))

(defmacro clause-vivify-address (object) `(+ ,object 0))

(defmacro clause-vivify (object) `(ldb (byte 2 7) (m-u16 (+ ,object 0))))

(defsetf clause-vivify (object) (value) `(set-bits (+ ,object 0) 7 2 ,value))

(defmacro clauses-allocated-address (object) `(+ ,object 16))

(defmacro clauses-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf clauses-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro clauses-begin-address (object) `(+ ,object 0))

(defmacro clauses-begin (object) `(m-ptr (+ ,object 0)))

(defsetf clauses-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro clauses-end-address (object) `(+ ,object 8))

(defmacro clauses-end (object) `(m-ptr (+ ,object 8)))

(defsetf clauses-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro control-allocated-address (object) `(+ ,object 16))

(defmacro control-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf control-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro control-begin-address (object) `(+ ,object 0))

(defmacro control-begin (object) `(m-ptr (+ ,object 0)))

(defsetf control-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro control-end-address (object) `(+ ,object 8))

(defmacro control-end (object) `(m-ptr (+ ,object 8)))

(defsetf control-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro flags-active-address (object) `(+ ,object 0))

(defmacro flags-active (object) `(ldb (byte 1 0) (m-u8 (+ ,object 0))))

(defsetf flags-active (object) (value) `(set-bits (+ ,object 0) 0 1 ,value))

(defmacro flags-eliminate-address (object) `(+ ,object 0))

(defmacro flags-eliminate (object) `(ldb (byte 1 1) (m-u8 (+ ,object 0))))

(defsetf flags-eliminate (object) (value) `(set-bits (+ ,object 0) 1 1 ,value))

(defmacro flags-eliminated-address (object) `(+ ,object 0))

(defmacro flags-eliminated (object) `(ldb (byte 1 2) (m-u8 (+ ,object 0))))

(defsetf flags-eliminated (object) (value) `(set-bits (+ ,object 0) 2 1 ,value))

(defmacro flags-fixed-address (object) `(+ ,object 0))

(defmacro flags-fixed (object) `(ldb (byte 1 3) (m-u8 (+ ,object 0))))

(defsetf flags-fixed (object) (value) `(set-bits (+ ,object 0) 3 1 ,value))

(defmacro flags-subsume-address (object) `(+ ,object 0))

(defmacro flags-subsume (object) `(ldb (byte 2 4) (m-u8 (+ ,object 0))))

(defsetf flags-subsume (object) (value) `(set-bits (+ ,object 0) 4 2 ,value))

(defmacro header-binary-address (object) `(+ ,object 0))

(defmacro header-binary (object) `(m-u8 (+ ,object 0)))

(defsetf header-binary (object) (value) `(setf (m-u8 (+ ,object 0)) ,value))

(defmacro header-blocking-address (object) `(+ ,object 4))

(defmacro header-blocking (object) `(m-u32 (+ ,object 4)))

(defsetf header-blocking (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro header-redundant-address (object) `(+ ,object 1))

(defmacro header-redundant (object) `(m-u8 (+ ,object 1)))

(defsetf header-redundant (object) (value) `(setf (m-u8 (+ ,object 1)) ,value))

(defmacro heap-begin-address (object) `(+ ,object 0))

(defmacro heap-begin (object) `(m-ptr (+ ,object 0)))

(defsetf heap-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro heap-end-address (object) `(+ ,object 8))

(defmacro heap-end (object) `(m-ptr (+ ,object 8)))

(defsetf heap-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro heap-factor-address (object) `(+ ,object 48))

(defmacro heap-factor (object) `(m-f64 (+ ,object 48)))

(defsetf heap-factor (object) (value) `(setf (m-f64 (+ ,object 48)) ,value))

(defmacro heap-increment-address (object) `(+ ,object 40))

(defmacro heap-increment (object) `(m-f64 (+ ,object 40)))

(defsetf heap-increment (object) (value) `(setf (m-f64 (+ ,object 40)) ,value))

(defmacro heap-pos-address (object) `(+ ,object 16))

(defmacro heap-pos (object) `(m-ptr (+ ,object 16)))

(defsetf heap-pos (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro heap-score-slot-address (object) `(+ ,object 24))

(defmacro heap-score-slot (object) `(m-ptr (+ ,object 24)))

(defsetf heap-score-slot (object) (value) `(setf (m-ptr (+ ,object 24)) ,value))

(defmacro heap-size-address (object) `(+ ,object 32))

(defmacro heap-size (object) `(m-u32 (+ ,object 32)))

(defsetf heap-size (object) (value) `(setf (m-u32 (+ ,object 32)) ,value))

(defmacro int-stack-allocated-address (object) `(+ ,object 16))

(defmacro int-stack-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf int-stack-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro int-stack-begin-address (object) `(+ ,object 0))

(defmacro int-stack-begin (object) `(m-ptr (+ ,object 0)))

(defsetf int-stack-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro int-stack-end-address (object) `(+ ,object 8))

(defmacro int-stack-end (object) `(m-ptr (+ ,object 8)))

(defsetf int-stack-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro level-seen-address (object) `(+ ,object 12))

(defmacro level-seen (object) `(+ ,object 12))

(defsetf level-seen (object) (value) `(copy-bytes (+ ,object 12) ,value 8))

(defmacro level-seen-count-address (object) `(+ ,object 4))

(defmacro level-seen-count (object) `(m-u32 (+ ,object 4)))

(defsetf level-seen-count (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro level-seen-earliest-address (object) `(+ ,object 0))

(defmacro level-seen-earliest (object) `(m-u32 (+ ,object 0)))

(defsetf level-seen-earliest (object) (value) `(setf (m-u32 (+ ,object 0)) ,value))

(defmacro level-trail-address (object) `(+ ,object 0))

(defmacro level-trail (object) `(m-ptr (+ ,object 0)))

(defsetf level-trail (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro limits-eliminate-address (object) `(+ ,object 0))

(defmacro limits-eliminate (object) `(+ ,object 0))

(defsetf limits-eliminate (object) (value) `(copy-bytes (+ ,object 0) ,value 40))

(defmacro limits-eliminate-conflicts-address (object) `(+ ,object 0))

(defmacro limits-eliminate-conflicts (object) `(m-u64 (+ ,object 0)))

(defsetf limits-eliminate-conflicts (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-eliminate-fixed-address (object) `(+ ,object 8))

(defmacro limits-eliminate-fixed (object) `(m-u64 (+ ,object 8)))

(defsetf limits-eliminate-fixed (object) (value) `(setf (m-u64 (+ ,object 8)) ,value))

(defmacro limits-eliminate-marked-address (object) `(+ ,object 16))

(defmacro limits-eliminate-marked (object) `(m-u64 (+ ,object 16)))

(defsetf limits-eliminate-marked (object) (value) `(setf (m-u64 (+ ,object 16)) ,value))

(defmacro limits-eliminate-search-address (object) `(+ ,object 32))

(defmacro limits-eliminate-search (object) `(m-u64 (+ ,object 32)))

(defsetf limits-eliminate-search (object) (value) `(setf (m-u64 (+ ,object 32)) ,value))

(defmacro limits-eliminate-ticks-address (object) `(+ ,object 24))

(defmacro limits-eliminate-ticks (object) `(m-u64 (+ ,object 24)))

(defsetf limits-eliminate-ticks (object) (value) `(setf (m-u64 (+ ,object 24)) ,value))

(defmacro limits-mode-address (object) `(+ ,object 96))

(defmacro limits-mode (object) `(+ ,object 96))

(defsetf limits-mode (object) (value) `(copy-bytes (+ ,object 96) ,value 24))

(defmacro limits-mode-conflicts-address (object) `(+ ,object 0))

(defmacro limits-mode-conflicts (object) `(m-u64 (+ ,object 0)))

(defsetf limits-mode-conflicts (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-mode-ticks-address (object) `(+ ,object 8))

(defmacro limits-mode-ticks (object) `(+ ,object 8))

(defsetf limits-mode-ticks (object) (value) `(copy-bytes (+ ,object 8) ,value 16))

(defmacro limits-mode-ticks-interval-address (object) `(+ ,object 8))

(defmacro limits-mode-ticks-interval (object) `(m-u64 (+ ,object 8)))

(defsetf limits-mode-ticks-interval (object) (value) `(setf (m-u64 (+ ,object 8)) ,value))

(defmacro limits-mode-ticks-limit-address (object) `(+ ,object 0))

(defmacro limits-mode-ticks-limit (object) `(m-u64 (+ ,object 0)))

(defsetf limits-mode-ticks-limit (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-reduce-address (object) `(+ ,object 64))

(defmacro limits-reduce (object) `(+ ,object 64))

(defsetf limits-reduce (object) (value) `(copy-bytes (+ ,object 64) ,value 16))

(defmacro limits-reduce-conflicts-address (object) `(+ ,object 0))

(defmacro limits-reduce-conflicts (object) `(m-u64 (+ ,object 0)))

(defsetf limits-reduce-conflicts (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-reduce-fixed-address (object) `(+ ,object 8))

(defmacro limits-reduce-fixed (object) `(m-u64 (+ ,object 8)))

(defsetf limits-reduce-fixed (object) (value) `(setf (m-u64 (+ ,object 8)) ,value))

(defmacro limits-rephase-address (object) `(+ ,object 80))

(defmacro limits-rephase (object) `(m-u64 (+ ,object 80)))

(defsetf limits-rephase (object) (value) `(setf (m-u64 (+ ,object 80)) ,value))

(defmacro limits-restart-address (object) `(+ ,object 88))

(defmacro limits-restart (object) `(m-u64 (+ ,object 88)))

(defsetf limits-restart (object) (value) `(setf (m-u64 (+ ,object 88)) ,value))

(defmacro limits-subsume-address (object) `(+ ,object 120))

(defmacro limits-subsume (object) `(+ ,object 120))

(defsetf limits-subsume (object) (value) `(copy-bytes (+ ,object 120) ,value 24))

(defmacro limits-subsume-marked-address (object) `(+ ,object 0))

(defmacro limits-subsume-marked (object) `(m-u64 (+ ,object 0)))

(defsetf limits-subsume-marked (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-subsume-search-address (object) `(+ ,object 16))

(defmacro limits-subsume-search (object) `(m-u64 (+ ,object 16)))

(defsetf limits-subsume-search (object) (value) `(setf (m-u64 (+ ,object 16)) ,value))

(defmacro limits-subsume-ticks-address (object) `(+ ,object 8))

(defmacro limits-subsume-ticks (object) `(m-u64 (+ ,object 8)))

(defsetf limits-subsume-ticks (object) (value) `(setf (m-u64 (+ ,object 8)) ,value))

(defmacro limits-vivify-address (object) `(+ ,object 40))

(defmacro limits-vivify (object) `(+ ,object 40))

(defsetf limits-vivify (object) (value) `(copy-bytes (+ ,object 40) ,value 24))

(defmacro limits-vivify-conflicts-address (object) `(+ ,object 0))

(defmacro limits-vivify-conflicts (object) `(m-u64 (+ ,object 0)))

(defsetf limits-vivify-conflicts (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro limits-vivify-search-address (object) `(+ ,object 16))

(defmacro limits-vivify-search (object) `(m-u64 (+ ,object 16)))

(defsetf limits-vivify-search (object) (value) `(setf (m-u64 (+ ,object 16)) ,value))

(defmacro link-next-address (object) `(+ ,object 4))

(defmacro link-next (object) `(m-u32 (+ ,object 4)))

(defsetf link-next (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro link-prev-address (object) `(+ ,object 0))

(defmacro link-prev (object) `(m-u32 (+ ,object 0)))

(defsetf link-prev (object) (value) `(setf (m-u32 (+ ,object 0)) ,value))

(defmacro link-stamp-address (object) `(+ ,object 8))

(defmacro link-stamp (object) `(m-u32 (+ ,object 8)))

(defsetf link-stamp (object) (value) `(setf (m-u32 (+ ,object 8)) ,value))

(defmacro options-ascii-address (object) `(+ ,object 0))

(defmacro options-ascii (object) `(m-u8 (+ ,object 0)))

(defsetf options-ascii (object) (value) `(setf (m-u8 (+ ,object 0)) ,value))

(defmacro options-verbose-address (object) `(+ ,object 4))

(defmacro options-verbose (object) `(m-u32 (+ ,object 4)))

(defsetf options-verbose (object) (value) `(setf (m-u32 (+ ,object 4)) ,value))

(defmacro profile-name-address (object) `(+ ,object 16))

(defmacro profile-name (object) `(m-ptr (+ ,object 16)))

(defsetf profile-name (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro profile-start-address (object) `(+ ,object 0))

(defmacro profile-start (object) `(m-f64 (+ ,object 0)))

(defsetf profile-start (object) (value) `(setf (m-f64 (+ ,object 0)) ,value))

(defmacro profile-time-address (object) `(+ ,object 8))

(defmacro profile-time (object) `(m-f64 (+ ,object 8)))

(defsetf profile-time (object) (value) `(setf (m-f64 (+ ,object 8)) ,value))

(defmacro profiles-begin-address (object) `(+ ,object 264))

(defmacro profiles-begin (object) `(+ ,object 264))

(defsetf profiles-begin (object) (value) `(copy-bytes (+ ,object 264) ,value 128))

(defmacro profiles-decide-address (object) `(+ ,object 168))

(defmacro profiles-decide (object) `(+ ,object 168))

(defsetf profiles-decide (object) (value) `(copy-bytes (+ ,object 168) ,value 24))

(defmacro profiles-eliminate-address (object) `(+ ,object 24))

(defmacro profiles-eliminate (object) `(+ ,object 24))

(defsetf profiles-eliminate (object) (value) `(copy-bytes (+ ,object 24) ,value 24))

(defmacro profiles-end-address (object) `(+ ,object 392))

(defmacro profiles-end (object) `(m-ptr (+ ,object 392)))

(defsetf profiles-end (object) (value) `(setf (m-ptr (+ ,object 392)) ,value))

(defmacro profiles-focused-address (object) `(+ ,object 0))

(defmacro profiles-focused (object) `(+ ,object 0))

(defsetf profiles-focused (object) (value) `(copy-bytes (+ ,object 0) ,value 24))

(defmacro profiles-minishrink-address (object) `(+ ,object 192))

(defmacro profiles-minishrink (object) `(+ ,object 192))

(defsetf profiles-minishrink (object) (value) `(copy-bytes (+ ,object 192) ,value 24))

(defmacro profiles-parse-address (object) `(+ ,object 48))

(defmacro profiles-parse (object) `(+ ,object 48))

(defsetf profiles-parse (object) (value) `(copy-bytes (+ ,object 48) ,value 24))

(defmacro profiles-reduce-address (object) `(+ ,object 72))

(defmacro profiles-reduce (object) `(+ ,object 72))

(defsetf profiles-reduce (object) (value) `(copy-bytes (+ ,object 72) ,value 24))

(defmacro profiles-solve-address (object) `(+ ,object 96))

(defmacro profiles-solve (object) `(+ ,object 96))

(defsetf profiles-solve (object) (value) `(copy-bytes (+ ,object 96) ,value 24))

(defmacro profiles-stable-address (object) `(+ ,object 120))

(defmacro profiles-stable (object) `(+ ,object 120))

(defsetf profiles-stable (object) (value) `(copy-bytes (+ ,object 120) ,value 24))

(defmacro profiles-subsume-address (object) `(+ ,object 144))

(defmacro profiles-subsume (object) `(+ ,object 144))

(defsetf profiles-subsume (object) (value) `(copy-bytes (+ ,object 144) ,value 24))

(defmacro profiles-total-address (object) `(+ ,object 240))

(defmacro profiles-total (object) `(+ ,object 240))

(defsetf profiles-total (object) (value) `(copy-bytes (+ ,object 240) ,value 24))

(defmacro profiles-vivify-address (object) `(+ ,object 216))

(defmacro profiles-vivify (object) `(+ ,object 216))

(defsetf profiles-vivify (object) (value) `(copy-bytes (+ ,object 216) ,value 24))

(defmacro queue-first-address (object) `(+ ,object 12))

(defmacro queue-first (object) `(m-u32 (+ ,object 12)))

(defsetf queue-first (object) (value) `(setf (m-u32 (+ ,object 12)) ,value))

(defmacro queue-last-address (object) `(+ ,object 16))

(defmacro queue-last (object) `(m-u32 (+ ,object 16)))

(defsetf queue-last (object) (value) `(setf (m-u32 (+ ,object 16)) ,value))

(defmacro queue-links-address (object) `(+ ,object 0))

(defmacro queue-links (object) `(m-ptr (+ ,object 0)))

(defsetf queue-links (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro queue-search-address (object) `(+ ,object 20))

(defmacro queue-search (object) `(m-u32 (+ ,object 20)))

(defsetf queue-search (object) (value) `(setf (m-u32 (+ ,object 20)) ,value))

(defmacro queue-size-address (object) `(+ ,object 8))

(defmacro queue-size (object) `(m-u32 (+ ,object 8)))

(defsetf queue-size (object) (value) `(setf (m-u32 (+ ,object 8)) ,value))

(defmacro queue-stamp-address (object) `(+ ,object 24))

(defmacro queue-stamp (object) `(m-u32 (+ ,object 24)))

(defsetf queue-stamp (object) (value) `(setf (m-u32 (+ ,object 24)) ,value))

(defmacro reluctant-u-address (object) `(+ ,object 0))

(defmacro reluctant-u (object) `(m-u64 (+ ,object 0)))

(defsetf reluctant-u (object) (value) `(setf (m-u64 (+ ,object 0)) ,value))

(defmacro reluctant-v-address (object) `(+ ,object 8))

(defmacro reluctant-v (object) `(m-u64 (+ ,object 8)))

(defsetf reluctant-v (object) (value) `(setf (m-u64 (+ ,object 8)) ,value))

(defmacro rusage-ru-maxrss-address (object) `(+ ,object 32))

(defmacro rusage-ru-maxrss (object) `(m-s64 (+ ,object 32)))

(defsetf rusage-ru-maxrss (object) (value) `(setf (m-s64 (+ ,object 32)) ,value))

(defmacro rusage-ru-stime-address (object) `(+ ,object 16))

(defmacro rusage-ru-stime (object) `(+ ,object 16))

(defsetf rusage-ru-stime (object) (value) `(copy-bytes (+ ,object 16) ,value 16))

(defmacro rusage-ru-utime-address (object) `(+ ,object 0))

(defmacro rusage-ru-utime (object) `(+ ,object 0))

(defsetf rusage-ru-utime (object) (value) `(copy-bytes (+ ,object 0) ,value 16))

(defmacro solver-added-address (object) `(+ ,object 1872))

(defmacro solver-added (object) `(+ ,object 1872))

(defsetf solver-added (object) (value) `(copy-bytes (+ ,object 1872) ,value 24))

(defmacro solver-analyzed-address (object) `(+ ,object 600))

(defmacro solver-analyzed (object) `(+ ,object 600))

(defsetf solver-analyzed (object) (value) `(copy-bytes (+ ,object 600) ,value 24))

(defmacro solver-averages-address (object) `(+ ,object 888))

(defmacro solver-averages (object) `(+ ,object 888))

(defsetf solver-averages (object) (value) `(copy-bytes (+ ,object 888) ,value 128))

(defmacro solver-best-address (object) `(+ ,object 88))

(defmacro solver-best (object) `(m-u32 (+ ,object 88)))

(defsetf solver-best (object) (value) `(setf (m-u32 (+ ,object 88)) ,value))

(defmacro solver-bests-address (object) `(+ ,object 80))

(defmacro solver-bests (object) `(m-ptr (+ ,object 80)))

(defsetf solver-bests (object) (value) `(setf (m-ptr (+ ,object 80)) ,value))

(defmacro solver-binaries-address (object) `(+ ,object 472))

(defmacro solver-binaries (object) `(+ ,object 472))

(defsetf solver-binaries (object) (value) `(copy-bytes (+ ,object 472) ,value 24))

(defmacro solver-binary-address (object) `(+ ,object 424))

(defmacro solver-binary (object) `(+ ,object 424))

(defsetf solver-binary (object) (value) `(copy-bytes (+ ,object 424) ,value 48))

(defmacro solver-blocks-address (object) `(+ ,object 648))

(defmacro solver-blocks (object) `(+ ,object 648))

(defsetf solver-blocks (object) (value) `(copy-bytes (+ ,object 648) ,value 24))

(defmacro solver-capacity-address (object) `(+ ,object 16))

(defmacro solver-capacity (object) `(m-size (+ ,object 16)))

(defsetf solver-capacity (object) (value) `(setf (m-size (+ ,object 16)) ,value))

(defmacro solver-clause-address (object) `(+ ,object 624))

(defmacro solver-clause (object) `(+ ,object 624))

(defsetf solver-clause (object) (value) `(copy-bytes (+ ,object 624) ,value 24))

(defmacro solver-control-address (object) `(+ ,object 576))

(defmacro solver-control (object) `(+ ,object 576))

(defsetf solver-control (object) (value) `(copy-bytes (+ ,object 576) ,value 24))

(defmacro solver-dense-address (object) `(+ ,object 7))

(defmacro solver-dense (object) `(m-u8 (+ ,object 7)))

(defsetf solver-dense (object) (value) `(setf (m-u8 (+ ,object 7)) ,value))

(defmacro solver-extend-address (object) `(+ ,object 496))

(defmacro solver-extend (object) `(+ ,object 496))

(defsetf solver-extend (object) (value) `(copy-bytes (+ ,object 496) ,value 24))

(defmacro solver-flags-address (object) `(+ ,object 48))

(defmacro solver-flags (object) `(m-ptr (+ ,object 48)))

(defsetf solver-flags (object) (value) `(setf (m-ptr (+ ,object 48)) ,value))

(defmacro solver-frames-address (object) `(+ ,object 232))

(defmacro solver-frames (object) `(m-ptr (+ ,object 232)))

(defsetf solver-frames (object) (value) `(setf (m-ptr (+ ,object 232)) ,value))

(defmacro solver-inconsistent-address (object) `(+ ,object 4))

(defmacro solver-inconsistent (object) `(m-u8 (+ ,object 4)))

(defsetf solver-inconsistent (object) (value) `(setf (m-u8 (+ ,object 4)) ,value))

(defmacro solver-irredundant-address (object) `(+ ,object 672))

(defmacro solver-irredundant (object) `(+ ,object 672))

(defsetf solver-irredundant (object) (value) `(copy-bytes (+ ,object 672) ,value 24))

(defmacro solver-iterate-address (object) `(+ ,object 5))

(defmacro solver-iterate (object) `(m-u8 (+ ,object 5)))

(defsetf solver-iterate (object) (value) `(setf (m-u8 (+ ,object 5)) ,value))

(defmacro solver-level-address (object) `(+ ,object 8))

(defmacro solver-level (object) `(m-u32 (+ ,object 8)))

(defsetf solver-level (object) (value) `(setf (m-u32 (+ ,object 8)) ,value))

(defmacro solver-levels-address (object) `(+ ,object 32))

(defmacro solver-levels (object) `(m-ptr (+ ,object 32)))

(defsetf solver-levels (object) (value) `(setf (m-ptr (+ ,object 32)) ,value))

(defmacro solver-limits-address (object) `(+ ,object 720))

(defmacro solver-limits (object) `(+ ,object 720))

(defsetf solver-limits (object) (value) `(copy-bytes (+ ,object 720) ,value 144))

(defmacro solver-marks-address (object) `(+ ,object 96))

(defmacro solver-marks (object) `(m-ptr (+ ,object 96)))

(defsetf solver-marks (object) (value) `(setf (m-ptr (+ ,object 96)) ,value))

(defmacro solver-options-address (object) `(+ ,object 880))

(defmacro solver-options (object) `(+ ,object 880))

(defsetf solver-options (object) (value) `(copy-bytes (+ ,object 880) ,value 8))

(defmacro solver-poisoned-address (object) `(+ ,object 152))

(defmacro solver-poisoned (object) `(+ ,object 152))

(defsetf solver-poisoned (object) (value) `(copy-bytes (+ ,object 152) ,value 24))

(defmacro solver-position-address (object) `(+ ,object 224))

(defmacro solver-position (object) `(m-ptr (+ ,object 224)))

(defsetf solver-position (object) (value) `(setf (m-ptr (+ ,object 224)) ,value))

(defmacro solver-profiles-address (object) `(+ ,object 1472))

(defmacro solver-profiles (object) `(+ ,object 1472))

(defsetf solver-profiles (object) (value) `(copy-bytes (+ ,object 1472) ,value 400))

(defmacro solver-proof-address (object) `(+ ,object 1896))

(defmacro solver-proof (object) `(m-ptr (+ ,object 1896)))

(defsetf solver-proof (object) (value) `(setf (m-ptr (+ ,object 1896)) ,value))

(defmacro solver-put-address (object) `(+ ,object 104))

(defmacro solver-put (object) `(+ ,object 104))

(defsetf solver-put (object) (value) `(copy-bytes (+ ,object 104) ,value 48))

(defmacro solver-queue-address (object) `(+ ,object 240))

(defmacro solver-queue (object) `(+ ,object 240))

(defsetf solver-queue (object) (value) `(copy-bytes (+ ,object 240) ,value 64))

(defmacro solver-reasons-address (object) `(+ ,object 416))

(defmacro solver-reasons (object) `(m-ptr (+ ,object 416)))

(defsetf solver-reasons (object) (value) `(setf (m-ptr (+ ,object 416)) ,value))

(defmacro solver-redundant-address (object) `(+ ,object 696))

(defmacro solver-redundant (object) `(+ ,object 696))

(defsetf solver-redundant (object) (value) `(copy-bytes (+ ,object 696) ,value 24))

(defmacro solver-reluctant-address (object) `(+ ,object 864))

(defmacro solver-reluctant (object) `(+ ,object 864))

(defsetf solver-reluctant (object) (value) `(copy-bytes (+ ,object 864) ,value 16))

(defmacro solver-removable-address (object) `(+ ,object 176))

(defmacro solver-removable (object) `(+ ,object 176))

(defsetf solver-removable (object) (value) `(copy-bytes (+ ,object 176) ,value 24))

(defmacro solver-resolvents-address (object) `(+ ,object 520))

(defmacro solver-resolvents (object) `(+ ,object 520))

(defsetf solver-resolvents (object) (value) `(copy-bytes (+ ,object 520) ,value 24))

(defmacro solver-saved-address (object) `(+ ,object 56))

(defmacro solver-saved (object) `(m-ptr (+ ,object 56)))

(defsetf solver-saved (object) (value) `(setf (m-ptr (+ ,object 56)) ,value))

(defmacro solver-scores-address (object) `(+ ,object 304))

(defmacro solver-scores (object) `(+ ,object 304))

(defsetf solver-scores (object) (value) `(copy-bytes (+ ,object 304) ,value 112))

(defmacro solver-shrunken-address (object) `(+ ,object 200))

(defmacro solver-shrunken (object) `(+ ,object 200))

(defsetf solver-shrunken (object) (value) `(copy-bytes (+ ,object 200) ,value 24))

(defmacro solver-size-address (object) `(+ ,object 12))

(defmacro solver-size (object) `(m-u32 (+ ,object 12)))

(defsetf solver-size (object) (value) `(setf (m-u32 (+ ,object 12)) ,value))

(defmacro solver-sorted-address (object) `(+ ,object 1904))

(defmacro solver-sorted (object) `(+ ,object 1904))

(defsetf solver-sorted (object) (value) `(copy-bytes (+ ,object 1904) ,value 24))

(defmacro solver-sorter-address (object) `(+ ,object 1928))

(defmacro solver-sorter (object) `(+ ,object 1928))

(defsetf solver-sorter (object) (value) `(copy-bytes (+ ,object 1928) ,value 24))

(defmacro solver-stable-address (object) `(+ ,object 6))

(defmacro solver-stable (object) `(m-u8 (+ ,object 6)))

(defsetf solver-stable (object) (value) `(setf (m-u8 (+ ,object 6)) ,value))

(defmacro solver-statistics-address (object) `(+ ,object 1016))

(defmacro solver-statistics (object) `(+ ,object 1016))

(defsetf solver-statistics (object) (value) `(copy-bytes (+ ,object 1016) ,value 456))

(defmacro solver-status-address (object) `(+ ,object 0))

(defmacro solver-status (object) `(m-s32 (+ ,object 0)))

(defsetf solver-status (object) (value) `(setf (m-s32 (+ ,object 0)) ,value))

(defmacro solver-target-address (object) `(+ ,object 72))

(defmacro solver-target (object) `(m-u32 (+ ,object 72)))

(defsetf solver-target (object) (value) `(setf (m-u32 (+ ,object 72)) ,value))

(defmacro solver-targets-address (object) `(+ ,object 64))

(defmacro solver-targets (object) `(m-ptr (+ ,object 64)))

(defsetf solver-targets (object) (value) `(setf (m-ptr (+ ,object 64)) ,value))

(defmacro solver-trail-address (object) `(+ ,object 552))

(defmacro solver-trail (object) `(+ ,object 552))

(defsetf solver-trail (object) (value) `(copy-bytes (+ ,object 552) ,value 24))

(defmacro solver-unassigned-address (object) `(+ ,object 24))

(defmacro solver-unassigned (object) `(m-u32 (+ ,object 24)))

(defsetf solver-unassigned (object) (value) `(setf (m-u32 (+ ,object 24)) ,value))

(defmacro solver-values-address (object) `(+ ,object 40))

(defmacro solver-values (object) `(m-ptr (+ ,object 40)))

(defsetf solver-values (object) (value) `(setf (m-ptr (+ ,object 40)) ,value))

(defmacro solver-vivification-schedule-address (object) `(+ ,object 1952))

(defmacro solver-vivification-schedule (object) `(+ ,object 1952))

(defsetf solver-vivification-schedule (object) (value) `(copy-bytes (+ ,object 1952) ,value 24))

(defmacro solver-vivify-marks-address (object) `(+ ,object 1976))

(defmacro solver-vivify-marks (object) `(m-ptr (+ ,object 1976)))

(defsetf solver-vivify-marks (object) (value) `(setf (m-ptr (+ ,object 1976)) ,value))

(defmacro solver-vivifying-address (object) `(+ ,object 1984))

(defmacro solver-vivifying (object) `(m-u8 (+ ,object 1984)))

(defsetf solver-vivifying (object) (value) `(setf (m-u8 (+ ,object 1984)) ,value))

(defmacro solver-watches-address (object) `(+ ,object 544))

(defmacro solver-watches (object) `(m-ptr (+ ,object 544)))

(defsetf solver-watches (object) (value) `(setf (m-ptr (+ ,object 544)) ,value))

(defmacro statistics-activated-address (object) `(+ ,object 0))

(defmacro statistics-activated (object) `(+ ,object 0))

(defsetf statistics-activated (object) (value) `(copy-bytes (+ ,object 0) ,value 16))

(defmacro statistics-added-address (object) `(+ ,object 16))

(defmacro statistics-added (object) `(m-u64 (+ ,object 16)))

(defsetf statistics-added (object) (value) `(setf (m-u64 (+ ,object 16)) ,value))

(defmacro statistics-bests-address (object) `(+ ,object 24))

(defmacro statistics-bests (object) `(m-u64 (+ ,object 24)))

(defsetf statistics-bests (object) (value) `(setf (m-u64 (+ ,object 24)) ,value))

(defmacro statistics-bumped-address (object) `(+ ,object 32))

(defmacro statistics-bumped (object) `(m-u64 (+ ,object 32)))

(defsetf statistics-bumped (object) (value) `(setf (m-u64 (+ ,object 32)) ,value))

(defmacro statistics-chrono-address (object) `(+ ,object 344))

(defmacro statistics-chrono (object) `(m-u64 (+ ,object 344)))

(defsetf statistics-chrono (object) (value) `(setf (m-u64 (+ ,object 344)) ,value))

(defmacro statistics-chronosaved-address (object) `(+ ,object 352))

(defmacro statistics-chronosaved (object) `(m-u64 (+ ,object 352)))

(defsetf statistics-chronosaved (object) (value) `(setf (m-u64 (+ ,object 352)) ,value))

(defmacro statistics-collected-address (object) `(+ ,object 40))

(defmacro statistics-collected (object) `(m-u64 (+ ,object 40)))

(defsetf statistics-collected (object) (value) `(setf (m-u64 (+ ,object 40)) ,value))

(defmacro statistics-conflicts-address (object) `(+ ,object 48))

(defmacro statistics-conflicts (object) `(m-u64 (+ ,object 48)))

(defsetf statistics-conflicts (object) (value) `(setf (m-u64 (+ ,object 48)) ,value))

(defmacro statistics-decisions-address (object) `(+ ,object 64))

(defmacro statistics-decisions (object) `(m-u64 (+ ,object 64)))

(defsetf statistics-decisions (object) (value) `(setf (m-u64 (+ ,object 64)) ,value))

(defmacro statistics-deduced-address (object) `(+ ,object 72))

(defmacro statistics-deduced (object) `(m-u64 (+ ,object 72)))

(defsetf statistics-deduced (object) (value) `(setf (m-u64 (+ ,object 72)) ,value))

(defmacro statistics-deleted-address (object) `(+ ,object 56))

(defmacro statistics-deleted (object) `(m-u64 (+ ,object 56)))

(defsetf statistics-deleted (object) (value) `(setf (m-u64 (+ ,object 56)) ,value))

(defmacro statistics-eliminated-address (object) `(+ ,object 80))

(defmacro statistics-eliminated (object) `(m-u64 (+ ,object 80)))

(defsetf statistics-eliminated (object) (value) `(setf (m-u64 (+ ,object 80)) ,value))

(defmacro statistics-elimination-ticks-address (object) `(+ ,object 88))

(defmacro statistics-elimination-ticks (object) `(m-u64 (+ ,object 88)))

(defsetf statistics-elimination-ticks (object) (value) `(setf (m-u64 (+ ,object 88)) ,value))

(defmacro statistics-eliminations-address (object) `(+ ,object 96))

(defmacro statistics-eliminations (object) `(m-u64 (+ ,object 96)))

(defsetf statistics-eliminations (object) (value) `(setf (m-u64 (+ ,object 96)) ,value))

(defmacro statistics-fixed-address (object) `(+ ,object 104))

(defmacro statistics-fixed (object) `(m-u64 (+ ,object 104)))

(defsetf statistics-fixed (object) (value) `(setf (m-u64 (+ ,object 104)) ,value))

(defmacro statistics-incremented-address (object) `(+ ,object 112))

(defmacro statistics-incremented (object) `(m-u64 (+ ,object 112)))

(defsetf statistics-incremented (object) (value) `(setf (m-u64 (+ ,object 112)) ,value))

(defmacro statistics-irredundant-address (object) `(+ ,object 120))

(defmacro statistics-irredundant (object) `(m-u64 (+ ,object 120)))

(defsetf statistics-irredundant (object) (value) `(setf (m-u64 (+ ,object 120)) ,value))

(defmacro statistics-learned-address (object) `(+ ,object 128))

(defmacro statistics-learned (object) `(m-u64 (+ ,object 128)))

(defsetf statistics-learned (object) (value) `(setf (m-u64 (+ ,object 128)) ,value))

(defmacro statistics-marked-eliminate-address (object) `(+ ,object 136))

(defmacro statistics-marked-eliminate (object) `(m-u64 (+ ,object 136)))

(defsetf statistics-marked-eliminate (object) (value) `(setf (m-u64 (+ ,object 136)) ,value))

(defmacro statistics-marked-subsume-address (object) `(+ ,object 144))

(defmacro statistics-marked-subsume (object) `(m-u64 (+ ,object 144)))

(defsetf statistics-marked-subsume (object) (value) `(setf (m-u64 (+ ,object 144)) ,value))

(defmacro statistics-minimized-address (object) `(+ ,object 152))

(defmacro statistics-minimized (object) `(m-u64 (+ ,object 152)))

(defsetf statistics-minimized (object) (value) `(setf (m-u64 (+ ,object 152)) ,value))

(defmacro statistics-moved-address (object) `(+ ,object 160))

(defmacro statistics-moved (object) `(m-u64 (+ ,object 160)))

(defsetf statistics-moved (object) (value) `(setf (m-u64 (+ ,object 160)) ,value))

(defmacro statistics-probing-ticks-address (object) `(+ ,object 440))

(defmacro statistics-probing-ticks (object) `(m-u64 (+ ,object 440)))

(defsetf statistics-probing-ticks (object) (value) `(setf (m-u64 (+ ,object 440)) ,value))

(defmacro statistics-propagations-address (object) `(+ ,object 168))

(defmacro statistics-propagations (object) `(m-u64 (+ ,object 168)))

(defsetf statistics-propagations (object) (value) `(setf (m-u64 (+ ,object 168)) ,value))

(defmacro statistics-reasons-address (object) `(+ ,object 176))

(defmacro statistics-reasons (object) `(m-u64 (+ ,object 176)))

(defsetf statistics-reasons (object) (value) `(setf (m-u64 (+ ,object 176)) ,value))

(defmacro statistics-reduced-address (object) `(+ ,object 192))

(defmacro statistics-reduced (object) `(m-u64 (+ ,object 192)))

(defsetf statistics-reduced (object) (value) `(setf (m-u64 (+ ,object 192)) ,value))

(defmacro statistics-reductions-address (object) `(+ ,object 200))

(defmacro statistics-reductions (object) `(m-u64 (+ ,object 200)))

(defsetf statistics-reductions (object) (value) `(setf (m-u64 (+ ,object 200)) ,value))

(defmacro statistics-redundant-address (object) `(+ ,object 208))

(defmacro statistics-redundant (object) `(m-u64 (+ ,object 208)))

(defsetf statistics-redundant (object) (value) `(setf (m-u64 (+ ,object 208)) ,value))

(defmacro statistics-remaining-address (object) `(+ ,object 216))

(defmacro statistics-remaining (object) `(m-u64 (+ ,object 216)))

(defsetf statistics-remaining (object) (value) `(setf (m-u64 (+ ,object 216)) ,value))

(defmacro statistics-rephased-address (object) `(+ ,object 224))

(defmacro statistics-rephased (object) `(m-u64 (+ ,object 224)))

(defsetf statistics-rephased (object) (value) `(setf (m-u64 (+ ,object 224)) ,value))

(defmacro statistics-reported-address (object) `(+ ,object 232))

(defmacro statistics-reported (object) `(m-u64 (+ ,object 232)))

(defsetf statistics-reported (object) (value) `(setf (m-u64 (+ ,object 232)) ,value))

(defmacro statistics-rescored-address (object) `(+ ,object 240))

(defmacro statistics-rescored (object) `(m-u64 (+ ,object 240)))

(defsetf statistics-rescored (object) (value) `(setf (m-u64 (+ ,object 240)) ,value))

(defmacro statistics-resolutions-address (object) `(+ ,object 184))

(defmacro statistics-resolutions (object) `(m-u64 (+ ,object 184)))

(defsetf statistics-resolutions (object) (value) `(setf (m-u64 (+ ,object 184)) ,value))

(defmacro statistics-restamped-address (object) `(+ ,object 248))

(defmacro statistics-restamped (object) `(m-u64 (+ ,object 248)))

(defsetf statistics-restamped (object) (value) `(setf (m-u64 (+ ,object 248)) ,value))

(defmacro statistics-restarts-address (object) `(+ ,object 256))

(defmacro statistics-restarts (object) `(m-u64 (+ ,object 256)))

(defsetf statistics-restarts (object) (value) `(setf (m-u64 (+ ,object 256)) ,value))

(defmacro statistics-reused-address (object) `(+ ,object 264))

(defmacro statistics-reused (object) `(m-u64 (+ ,object 264)))

(defsetf statistics-reused (object) (value) `(setf (m-u64 (+ ,object 264)) ,value))

(defmacro statistics-sections-address (object) `(+ ,object 272))

(defmacro statistics-sections (object) `(m-u64 (+ ,object 272)))

(defsetf statistics-sections (object) (value) `(setf (m-u64 (+ ,object 272)) ,value))

(defmacro statistics-shrunken-address (object) `(+ ,object 280))

(defmacro statistics-shrunken (object) `(m-u64 (+ ,object 280)))

(defsetf statistics-shrunken (object) (value) `(setf (m-u64 (+ ,object 280)) ,value))

(defmacro statistics-solved-address (object) `(+ ,object 288))

(defmacro statistics-solved (object) `(m-u64 (+ ,object 288)))

(defsetf statistics-solved (object) (value) `(setf (m-u64 (+ ,object 288)) ,value))

(defmacro statistics-strengthened-address (object) `(+ ,object 296))

(defmacro statistics-strengthened (object) `(m-u64 (+ ,object 296)))

(defsetf statistics-strengthened (object) (value) `(setf (m-u64 (+ ,object 296)) ,value))

(defmacro statistics-subsumed-address (object) `(+ ,object 320))

(defmacro statistics-subsumed (object) `(m-u64 (+ ,object 320)))

(defsetf statistics-subsumed (object) (value) `(setf (m-u64 (+ ,object 320)) ,value))

(defmacro statistics-subsumption-ticks-address (object) `(+ ,object 304))

(defmacro statistics-subsumption-ticks (object) `(m-u64 (+ ,object 304)))

(defsetf statistics-subsumption-ticks (object) (value) `(setf (m-u64 (+ ,object 304)) ,value))

(defmacro statistics-subsumptions-address (object) `(+ ,object 312))

(defmacro statistics-subsumptions (object) `(m-u64 (+ ,object 312)))

(defsetf statistics-subsumptions (object) (value) `(setf (m-u64 (+ ,object 312)) ,value))

(defmacro statistics-switched-address (object) `(+ ,object 328))

(defmacro statistics-switched (object) `(m-u64 (+ ,object 328)))

(defsetf statistics-switched (object) (value) `(setf (m-u64 (+ ,object 328)) ,value))

(defmacro statistics-targets-address (object) `(+ ,object 336))

(defmacro statistics-targets (object) `(m-u64 (+ ,object 336)))

(defsetf statistics-targets (object) (value) `(setf (m-u64 (+ ,object 336)) ,value))

(defmacro statistics-ticks-address (object) `(+ ,object 360))

(defmacro statistics-ticks (object) `(m-u64 (+ ,object 360)))

(defsetf statistics-ticks (object) (value) `(setf (m-u64 (+ ,object 360)) ,value))

(defmacro statistics-variables-address (object) `(+ ,object 368))

(defmacro statistics-variables (object) `(m-u64 (+ ,object 368)))

(defsetf statistics-variables (object) (value) `(setf (m-u64 (+ ,object 368)) ,value))

(defmacro statistics-vivifications-address (object) `(+ ,object 416))

(defmacro statistics-vivifications (object) `(m-u64 (+ ,object 416)))

(defsetf statistics-vivifications (object) (value) `(setf (m-u64 (+ ,object 416)) ,value))

(defmacro statistics-vivified-address (object) `(+ ,object 408))

(defmacro statistics-vivified (object) `(m-u64 (+ ,object 408)))

(defsetf statistics-vivified (object) (value) `(setf (m-u64 (+ ,object 408)) ,value))

(defmacro statistics-vivify-conflicts-address (object) `(+ ,object 432))

(defmacro statistics-vivify-conflicts (object) `(m-u64 (+ ,object 432)))

(defsetf statistics-vivify-conflicts (object) (value) `(setf (m-u64 (+ ,object 432)) ,value))

(defmacro statistics-vivify-implied-address (object) `(+ ,object 424))

(defmacro statistics-vivify-implied (object) `(m-u64 (+ ,object 424)))

(defsetf statistics-vivify-implied (object) (value) `(setf (m-u64 (+ ,object 424)) ,value))

(defmacro statistics-vivify-probes-address (object) `(+ ,object 384))

(defmacro statistics-vivify-probes (object) `(m-u64 (+ ,object 384)))

(defsetf statistics-vivify-probes (object) (value) `(setf (m-u64 (+ ,object 384)) ,value))

(defmacro statistics-vivify-propagations-address (object) `(+ ,object 448))

(defmacro statistics-vivify-propagations (object) `(m-u64 (+ ,object 448)))

(defsetf statistics-vivify-propagations (object) (value) `(setf (m-u64 (+ ,object 448)) ,value))

(defmacro statistics-vivify-reused-address (object) `(+ ,object 376))

(defmacro statistics-vivify-reused (object) `(m-u64 (+ ,object 376)))

(defsetf statistics-vivify-reused (object) (value) `(setf (m-u64 (+ ,object 376)) ,value))

(defmacro statistics-vivify-strengthened-address (object) `(+ ,object 392))

(defmacro statistics-vivify-strengthened (object) `(m-u64 (+ ,object 392)))

(defsetf statistics-vivify-strengthened (object) (value) `(setf (m-u64 (+ ,object 392)) ,value))

(defmacro statistics-vivify-subsume-address (object) `(+ ,object 400))

(defmacro statistics-vivify-subsume (object) `(m-u64 (+ ,object 400)))

(defsetf statistics-vivify-subsume (object) (value) `(setf (m-u64 (+ ,object 400)) ,value))

(defmacro timeval-tv-sec-address (object) `(+ ,object 0))

(defmacro timeval-tv-sec (object) `(m-s64 (+ ,object 0)))

(defsetf timeval-tv-sec (object) (value) `(setf (m-s64 (+ ,object 0)) ,value))

(defmacro timeval-tv-usec-address (object) `(+ ,object 8))

(defmacro timeval-tv-usec (object) `(m-s64 (+ ,object 8)))

(defsetf timeval-tv-usec (object) (value) `(setf (m-s64 (+ ,object 8)) ,value))

(defmacro trail-begin-address (object) `(+ ,object 0))

(defmacro trail-begin (object) `(m-ptr (+ ,object 0)))

(defsetf trail-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro trail-end-address (object) `(+ ,object 8))

(defmacro trail-end (object) `(m-ptr (+ ,object 8)))

(defsetf trail-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro trail-propagate-address (object) `(+ ,object 16))

(defmacro trail-propagate (object) `(m-ptr (+ ,object 16)))

(defsetf trail-propagate (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro unsigned-stack-allocated-address (object) `(+ ,object 16))

(defmacro unsigned-stack-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf unsigned-stack-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro unsigned-stack-begin-address (object) `(+ ,object 0))

(defmacro unsigned-stack-begin (object) `(m-ptr (+ ,object 0)))

(defsetf unsigned-stack-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro unsigned-stack-end-address (object) `(+ ,object 8))

(defmacro unsigned-stack-end (object) `(m-ptr (+ ,object 8)))

(defsetf unsigned-stack-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

(defmacro watch-clause-slot-address (object) `(+ ,object 0))

(defmacro watch-clause-slot (object) `(m-ptr (+ ,object 0)))

(defsetf watch-clause-slot (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro watch-header-address (object) `(+ ,object 0))

(defmacro watch-header (object) `(+ ,object 0))

(defsetf watch-header (object) (value) `(copy-bytes (+ ,object 0) ,value 8))

(defmacro watches-allocated-address (object) `(+ ,object 16))

(defmacro watches-allocated (object) `(m-ptr (+ ,object 16)))

(defsetf watches-allocated (object) (value) `(setf (m-ptr (+ ,object 16)) ,value))

(defmacro watches-begin-address (object) `(+ ,object 0))

(defmacro watches-begin (object) `(m-ptr (+ ,object 0)))

(defsetf watches-begin (object) (value) `(setf (m-ptr (+ ,object 0)) ,value))

(defmacro watches-end-address (object) `(+ ,object 8))

(defmacro watches-end (object) `(m-ptr (+ ,object 8)))

(defsetf watches-end (object) (value) `(setf (m-ptr (+ ,object 8)) ,value))

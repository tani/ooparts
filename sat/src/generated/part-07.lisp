(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:5869:1
(defun |c/reuse_scored_trail_from| (arg-v-solver-2368 arg-v-asserting_level-2369)
 (declare  (type c-address arg-v-solver-2368) (type (unsigned-byte 32) arg-v-asserting_level-2369))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-2368 0) (v-asserting_level-2369 0) (v-next-2370 0) (v-scores-2371 0) (v-reasons-2372 0) (v-control-2373 (stack-alloc 24)) (v-end-2374 0) (v-next_score-2375 0d0) (v-decision_score-2376 0d0) (v-control_position-2377 0) (v-lit-2381 0) (v-idx-2382 0) (v-score-2383 0d0) (v-level-2384 0))
 (declare (type c-address v-solver-2368) (type (unsigned-byte 32) v-asserting_level-2369) (type (unsigned-byte 32) v-next-2370) (type c-address v-scores-2371) (type c-address v-reasons-2372) (type c-address v-control-2373) (type c-address v-end-2374) (type double-float v-next_score-2375) (type double-float v-decision_score-2376) (type (unsigned-byte 32) v-control_position-2377) (type c-address v-lit-2381) (type (unsigned-byte 32) v-idx-2382) (type double-float v-score-2383) (type (unsigned-byte 32) v-level-2384) (ignorable v-solver-2368 v-asserting_level-2369 v-next-2370 v-scores-2371 v-reasons-2372 v-control-2373 v-end-2374 v-next_score-2375 v-decision_score-2376 v-control_position-2377 v-lit-2381 v-idx-2382 v-score-2383 v-level-2384))
 (tagbody
    (setf v-solver-2368 arg-v-solver-2368)
    (setf v-asserting_level-2369 arg-v-asserting_level-2369)
    (setf v-next-2370 (|c/max_score_unassigned_variable_on_binary_heap| v-solver-2368))
    (setf v-scores-2371 (m-ptr (+ (+ (+ v-solver-2368 304) (* 56 (m-u8 (+ v-solver-2368 6)))) 24)))
    (setf v-reasons-2372 (m-ptr (+ v-solver-2368 416)))
    (copy-bytes v-control-2373 (+ v-solver-2368 576) 24)
    (setf v-end-2374 (m-ptr (+ (+ v-solver-2368 552) 8)))
    (setf v-next_score-2375 (m-f64 (+ v-scores-2371 (* 8 v-next-2370))))
    (setf v-decision_score-2376 1d+150)
    (setf v-control_position-2377 (if (c-true v-asserting_level-2369) (c-u32 (- v-asserting_level-2369 (c-u32 1))) v-asserting_level-2369))
    (setf v-lit-2381 (m-ptr (+ (+ (m-ptr (+ v-control-2373 0)) (* 24 (progn 0 v-control_position-2377))) 0)))
    LOOP2378
    (unless (c-true (if (/= v-lit-2381 v-end-2374) 1 0)) (go ENDLOOP2379))
    (setf v-idx-2382 (|c/INDEX| (m-u32 v-lit-2381)))
    (setf v-score-2383 (m-f64 (+ v-scores-2371 (* 8 v-idx-2382))))
    (setf v-level-2384 (m-u32 (+ (m-ptr (+ v-solver-2368 32)) (* 4 v-idx-2382))))
    (unless (c-true (if (<= v-level-2384 v-asserting_level-2369) 1 0)) (go ELSE2385))
    (go CONTINUE2380)
    ELSE2385
    (unless (c-true (if (c-true (if (< v-decision_score-2376 v-score-2383) 1 0)) 1 (c-bool (if (< v-score-2383 v-next_score-2375) 1 0)))) (go ELSE2387))
    (return-from |c/reuse_scored_trail_from| (c-u32 (- v-level-2384 (c-u32 1))))
    ELSE2387
    (unless (c-true (if (c-true (m-ptr (+ v-reasons-2372 (* 8 v-idx-2382)))) 0 1)) (go ELSE2389))
    (progn (setf v-decision_score-2376 v-score-2383))
    (go ENDIF2390)
    ELSE2389
    ENDIF2390
    CONTINUE2380
    (let* ( (old2392 v-lit-2381)) (setf v-lit-2381 (+ old2392 (* 4 1))) v-lit-2381)
    (go LOOP2378)
    ENDLOOP2379
    (return-from |c/reuse_scored_trail_from| (c-u32 (- (m-u32 (+ v-solver-2368 8)) (c-u32 1))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:5899:1
(defun |c/reuse_stamped_trail_from| (arg-v-solver-2393 arg-v-asserting_level-2394)
 (declare  (type c-address arg-v-solver-2393) (type (unsigned-byte 32) arg-v-asserting_level-2394))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-2393 0) (v-asserting_level-2394 0) (v-next-2395 0) (v-links-2396 0) (v-reasons-2397 0) (v-control-2398 (stack-alloc 24)) (v-end-2399 0) (v-next_stamp-2400 0) (v-decision_stamp-2401 0) (v-control_position-2402 0) (v-lit-2406 0) (v-idx-2407 0) (v-stamp-2408 0) (v-level-2409 0))
 (declare (type c-address v-solver-2393) (type (unsigned-byte 32) v-asserting_level-2394) (type (unsigned-byte 32) v-next-2395) (type c-address v-links-2396) (type c-address v-reasons-2397) (type c-address v-control-2398) (type c-address v-end-2399) (type (unsigned-byte 32) v-next_stamp-2400) (type (unsigned-byte 32) v-decision_stamp-2401) (type (unsigned-byte 32) v-control_position-2402) (type c-address v-lit-2406) (type (unsigned-byte 32) v-idx-2407) (type (unsigned-byte 32) v-stamp-2408) (type (unsigned-byte 32) v-level-2409) (ignorable v-solver-2393 v-asserting_level-2394 v-next-2395 v-links-2396 v-reasons-2397 v-control-2398 v-end-2399 v-next_stamp-2400 v-decision_stamp-2401 v-control_position-2402 v-lit-2406 v-idx-2407 v-stamp-2408 v-level-2409))
 (tagbody
    (setf v-solver-2393 arg-v-solver-2393)
    (setf v-asserting_level-2394 arg-v-asserting_level-2394)
    (setf v-next-2395 (|c/max_stamped_unassigned_variable_on_decision_queue| v-solver-2393))
    (setf v-links-2396 (m-ptr (+ (+ (+ v-solver-2393 240) (* 32 (m-u8 (+ v-solver-2393 6)))) 0)))
    (setf v-reasons-2397 (m-ptr (+ v-solver-2393 416)))
    (copy-bytes v-control-2398 (+ v-solver-2393 576) 24)
    (setf v-end-2399 (m-ptr (+ (+ v-solver-2393 552) 8)))
    (setf v-next_stamp-2400 (m-u32 (+ (+ v-links-2396 (* 12 v-next-2395)) 8)))
    (setf v-decision_stamp-2401 4294967295)
    (setf v-control_position-2402 (if (c-true v-asserting_level-2394) (c-u32 (- v-asserting_level-2394 (c-u32 1))) v-asserting_level-2394))
    (setf v-lit-2406 (m-ptr (+ (+ (m-ptr (+ v-control-2398 0)) (* 24 (progn 0 v-control_position-2402))) 0)))
    LOOP2403
    (unless (c-true (if (/= v-lit-2406 v-end-2399) 1 0)) (go ENDLOOP2404))
    (setf v-idx-2407 (|c/INDEX| (m-u32 v-lit-2406)))
    (setf v-stamp-2408 (m-u32 (+ (+ v-links-2396 (* 12 v-idx-2407)) 8)))
    (setf v-level-2409 (m-u32 (+ (m-ptr (+ v-solver-2393 32)) (* 4 v-idx-2407))))
    (unless (c-true (if (<= v-level-2409 v-asserting_level-2394) 1 0)) (go ELSE2410))
    (go CONTINUE2405)
    ELSE2410
    (unless (c-true (if (c-true (if (< v-decision_stamp-2401 v-stamp-2408) 1 0)) 1 (c-bool (if (< v-stamp-2408 v-next_stamp-2400) 1 0)))) (go ELSE2412))
    (return-from |c/reuse_stamped_trail_from| (c-u32 (- v-level-2409 (c-u32 1))))
    ELSE2412
    (unless (c-true (if (c-true (m-ptr (+ v-reasons-2397 (* 8 v-idx-2407)))) 0 1)) (go ELSE2414))
    (progn (setf v-decision_stamp-2401 v-stamp-2408))
    (go ENDIF2415)
    ELSE2414
    ENDIF2415
    CONTINUE2405
    (let* ( (old2417 v-lit-2406)) (setf v-lit-2406 (+ old2417 (* 4 1))) v-lit-2406)
    (go LOOP2403)
    ENDLOOP2404
    (return-from |c/reuse_stamped_trail_from| (c-u32 (- (m-u32 (+ v-solver-2393 8)) (c-u32 1))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:5940:1
(defun |c/determine_jump_level| (arg-v-solver-2418 arg-v-conflict_level-2419 arg-v-asserting_level-2420)
 (declare  (type c-address arg-v-solver-2418) (type (unsigned-byte 32) arg-v-conflict_level-2419) (type c-address arg-v-asserting_level-2420))
 (let ((v-solver-2418 0) (v-conflict_level-2419 0) (v-asserting_level-2420 0) (v-frames-2421 0) (v-jump_level-2422 0) (v-lit_level-2426 0) (v-PTR_lit_level-2427 0) (v-END_lit_level-2428 0))
 (declare (type c-address v-solver-2418) (type (unsigned-byte 32) v-conflict_level-2419) (type c-address v-asserting_level-2420) (type c-address v-frames-2421) (type (unsigned-byte 32) v-jump_level-2422) (type (unsigned-byte 32) v-lit_level-2426) (type c-address v-PTR_lit_level-2427) (type c-address v-END_lit_level-2428) (ignorable v-solver-2418 v-conflict_level-2419 v-asserting_level-2420 v-frames-2421 v-jump_level-2422 v-lit_level-2426 v-PTR_lit_level-2427 v-END_lit_level-2428))
 (tagbody
    (setf v-solver-2418 arg-v-solver-2418)
    (setf v-conflict_level-2419 arg-v-conflict_level-2419)
    (setf v-asserting_level-2420 arg-v-asserting_level-2420)
    (setf v-frames-2421 (m-ptr (+ v-solver-2418 232)))
    (setf v-jump_level-2422 (c-u32 0))
    (progn (setf (m-u32 v-asserting_level-2420) (c-u32 0)))
    (setf v-PTR_lit_level-2427 (m-ptr (+ (+ v-solver-2418 648) 0)))
    (setf v-END_lit_level-2428 (m-ptr (+ (+ v-solver-2418 648) 8)))
    LOOP2423
    (unless (c-true (if (c-true (if (/= v-PTR_lit_level-2427 v-END_lit_level-2428) 1 0)) (c-bool (progn (setf v-lit_level-2426 (m-u32 v-PTR_lit_level-2427)) 1)) 0)) (go ENDLOOP2424))
    (progn (setf (m-s8 (+ v-frames-2421 (* 1 v-lit_level-2426))) (c-s8 0)))
    (unless (c-true (if (c-true (if (/= v-lit_level-2426 v-conflict_level-2419) 1 0)) (c-bool (if (< (m-u32 v-asserting_level-2420) v-lit_level-2426) 1 0)) 0)) (go ELSE2429))
    (progn (setf (m-u32 v-asserting_level-2420) v-lit_level-2426))
    (go ENDIF2430)
    ELSE2429
    ENDIF2430
    (unless (c-true v-lit_level-2426) (go ELSE2431))
    (progn (progn (setf (m-u32 (+ (+ (+ (m-ptr (+ (+ v-solver-2418 576) 0)) (* 24 (progn 0 (c-u32 (- v-lit_level-2426 (c-u32 1)))))) 12) 4)) (c-u32 0)) (setf (m-u32 (+ (+ (+ (m-ptr (+ (+ v-solver-2418 576) 0)) (* 24 (progn 0 (c-u32 (- v-lit_level-2426 (c-u32 1)))))) 12) 0)) 4294967295)))
    (go ENDIF2432)
    ELSE2431
    ENDIF2432
    (let* ( (old2434 v-PTR_lit_level-2427)) (setf v-PTR_lit_level-2427 (+ old2434 (* 4 1))) v-PTR_lit_level-2427)
    (go LOOP2423)
    ENDLOOP2424
    (progn v-solver-2418)
    (unless (c-true (if (c-true (if (c-true (if (< (c-u32 (- (m-u32 (+ v-solver-2418 8)) (m-u32 v-asserting_level-2420))) (c-u32 100)) 1 0)) 1 (c-bool (if (= (c-u32 (- (m-u32 (+ v-solver-2418 8)) (c-u32 1))) (m-u32 v-asserting_level-2420)) 1 0)))) 1 (c-bool (m-u8 (+ v-solver-2418 1984))))) (go ELSE2438))
    (progn v-solver-2418)
    (return-from |c/determine_jump_level| (m-u32 v-asserting_level-2420))
    ELSE2438
    (progn v-solver-2418)
    (unless (c-true (if (c-true (m-u32 (+ v-solver-2418 24))) 0 1)) (go ELSE2446))
    (progn (setf v-jump_level-2422 (c-u32 (- (m-u32 (+ v-solver-2418 8)) (c-u32 1)))))
    (unless (c-true (if (/= (m-u32 v-asserting_level-2420) (c-u32 (- (m-u32 (+ v-solver-2418 8)) (c-u32 1)))) 1 0)) (go ELSE2448))
    (progn (progn 0 (let* ((a2450 (+ (+ v-solver-2418 1016) 344)) (old2451 (m-u64 a2450))) (setf (m-u64 a2450) (c-u64 (c-u64 (+ old2451 (c-u64 1))))) (m-u64 a2450))))
    (progn (let ((a2455 (+ (+ v-solver-2418 1016) 352))) (setf (m-u64 a2455) (c-u64 (c-u64 (+ (m-u64 a2455) (c-u32 (- v-jump_level-2422 (m-u32 v-asserting_level-2420)))))))))
    (go ENDIF2449)
    ELSE2448
    ENDIF2449
    (return-from |c/determine_jump_level| v-jump_level-2422)
    ELSE2446
    (unless (c-true (if (c-true (m-u32 (+ (+ (+ v-solver-2418 240) (* 32 (m-u8 (+ v-solver-2418 6)))) 8))) 0 1)) (go ELSE2456))
    (return-from |c/determine_jump_level| (c-u32 (- (m-u32 (+ v-solver-2418 8)) (c-u32 1))))
    ELSE2456
    (unless (c-true (m-u8 (+ v-solver-2418 6))) (go ELSE2458))
    (progn (setf v-jump_level-2422 (|c/reuse_scored_trail_from| v-solver-2418 (m-u32 v-asserting_level-2420))))
    (go ENDIF2459)
    ELSE2458
    (progn (setf v-jump_level-2422 (|c/reuse_stamped_trail_from| v-solver-2418 (m-u32 v-asserting_level-2420))))
    ENDIF2459
    (unless (c-true (if (/= (m-u32 v-asserting_level-2420) v-jump_level-2422) 1 0)) (go ELSE2460))
    (progn (progn 0 (let* ((a2462 (+ (+ v-solver-2418 1016) 344)) (old2463 (m-u64 a2462))) (setf (m-u64 a2462) (c-u64 (c-u64 (+ old2463 (c-u64 1))))) (m-u64 a2462))))
    (progn (let ((a2467 (+ (+ v-solver-2418 1016) 352))) (setf (m-u64 a2467) (c-u64 (c-u64 (+ (m-u64 a2467) (c-u32 (- v-jump_level-2422 (m-u32 v-asserting_level-2420)))))))))
    (go ENDIF2461)
    ELSE2460
    ENDIF2461
    (return-from |c/determine_jump_level| v-jump_level-2422)
  )
  0))

;;; upstream/satch.c:6061:1
(defun |c/analyze_conflict| (arg-v-solver-2468 arg-v-conflict-2469)
 (declare (optimize (speed 1) (compilation-speed 3)) (notinline checked-address) (type c-address arg-v-solver-2468) (type c-address arg-v-conflict-2469))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-2468 0) (v-conflict-2469 0) (v-old_size-2483 0) (v-old_capacity-2484 0) (v-new_capacity-2485 0) (v-new_bytes-2486 0) (v-forced-2491 (stack-alloc 4)) (v-forcedp-2492 0) (v-conflict_level-2493 0) (v-other-2506 0) (v-reason-2507 0) (v-marks-2522 0) (v-levels-2523 0) (v-reasons-2524 0) (v-frames-2525 0) (v-reason-2526 0) (v-t-2527 0) (v-unresolved_on_current_level-2528 0) (v-uip-2529 0) (v-ticks-2530 0) (v-lit-2548 0) (v-P_lit-2549 0) (v-END_lit-2550 0) (v-lit_level-2553 0) (v-old_size-2571 0) (v-old_capacity-2572 0) (v-new_capacity-2573 0) (v-new_bytes-2574 0) (v-old_size-2587 0) (v-old_capacity-2588 0) (v-new_capacity-2589 0) (v-new_bytes-2590 0) (v-idx-2595 0) (v-level-2596 0) (v-saved-2599 0) (v-uip_idx-2611 0) (v-not_uip-2631 0) (v-size-2639 0) (v-glue-2644 0) (v-asserting_level-2645 (stack-alloc 4)) (v-jump_level-2646 0) (v-a-2650 0) (v-decisions-2651 0) (v-delta_decisions-2652 0) (v-trail_filled-2653 0d0) (v-analyzed-2671 (stack-alloc 8)) (v-PTR_analyzed-2672 0) (v-END_analyzed-2673 0) (v-idx-2674 0) (v-other-2694 0) (v-reason-2702 0) (v-p-2706 0) (v-q-2707 0) (v-lit-2708 0) (v-idx-2709 0) (v-lit_level-2710 0) (v-learned-2715 0))
 (declare (type c-address v-solver-2468) (type c-address v-conflict-2469) (type c-size v-old_size-2483) (type c-size v-old_capacity-2484) (type c-size v-new_capacity-2485) (type c-size v-new_bytes-2486) (type c-address v-forced-2491) (type c-address v-forcedp-2492) (type (unsigned-byte 32) v-conflict_level-2493) (type (unsigned-byte 32) v-other-2506) (type c-address v-reason-2507) (type c-address v-marks-2522) (type c-address v-levels-2523) (type c-address v-reasons-2524) (type c-address v-frames-2525) (type c-address v-reason-2526) (type c-address v-t-2527) (type (unsigned-byte 32) v-unresolved_on_current_level-2528) (type (unsigned-byte 32) v-uip-2529) (type (unsigned-byte 64) v-ticks-2530) (type (unsigned-byte 32) v-lit-2548) (type c-address v-P_lit-2549) (type c-address v-END_lit-2550) (type (unsigned-byte 32) v-lit_level-2553) (type c-size v-old_size-2571) (type c-size v-old_capacity-2572) (type c-size v-new_capacity-2573) (type c-size v-new_bytes-2574) (type c-size v-old_size-2587) (type c-size v-old_capacity-2588) (type c-size v-new_capacity-2589) (type c-size v-new_bytes-2590) (type (unsigned-byte 32) v-idx-2595) (type (unsigned-byte 32) v-level-2596) (type c-address v-saved-2599) (type (unsigned-byte 32) v-uip_idx-2611) (type (unsigned-byte 32) v-not_uip-2631) (type (unsigned-byte 32) v-size-2639) (type (unsigned-byte 32) v-glue-2644) (type c-address v-asserting_level-2645) (type (unsigned-byte 32) v-jump_level-2646) (type c-address v-a-2650) (type (unsigned-byte 64) v-decisions-2651) (type (unsigned-byte 64) v-delta_decisions-2652) (type double-float v-trail_filled-2653) (type c-address v-analyzed-2671) (type c-address v-PTR_analyzed-2672) (type c-address v-END_analyzed-2673) (type (unsigned-byte 32) v-idx-2674) (type (unsigned-byte 32) v-other-2694) (type c-address v-reason-2702) (type c-address v-p-2706) (type c-address v-q-2707) (type (unsigned-byte 32) v-lit-2708) (type (unsigned-byte 32) v-idx-2709) (type (unsigned-byte 32) v-lit_level-2710) (type c-address v-learned-2715) (ignorable v-solver-2468 v-conflict-2469 v-old_size-2483 v-old_capacity-2484 v-new_capacity-2485 v-new_bytes-2486 v-forced-2491 v-forcedp-2492 v-conflict_level-2493 v-other-2506 v-reason-2507 v-marks-2522 v-levels-2523 v-reasons-2524 v-frames-2525 v-reason-2526 v-t-2527 v-unresolved_on_current_level-2528 v-uip-2529 v-ticks-2530 v-lit-2548 v-P_lit-2549 v-END_lit-2550 v-lit_level-2553 v-old_size-2571 v-old_capacity-2572 v-new_capacity-2573 v-new_bytes-2574 v-old_size-2587 v-old_capacity-2588 v-new_capacity-2589 v-new_bytes-2590 v-idx-2595 v-level-2596 v-saved-2599 v-uip_idx-2611 v-not_uip-2631 v-size-2639 v-glue-2644 v-asserting_level-2645 v-jump_level-2646 v-a-2650 v-decisions-2651 v-delta_decisions-2652 v-trail_filled-2653 v-analyzed-2671 v-PTR_analyzed-2672 v-END_analyzed-2673 v-idx-2674 v-other-2694 v-reason-2702 v-p-2706 v-q-2707 v-lit-2708 v-idx-2709 v-lit_level-2710 v-learned-2715))
 (tagbody
    (setf v-solver-2468 arg-v-solver-2468)
    (setf v-conflict-2469 arg-v-conflict-2469)
    (unless (c-true (if (c-true (m-u32 (+ v-solver-2468 8))) 0 1)) (go ELSE2470))
    (progn v-solver-2468)
    (progn (|c/trace_and_check_empty_addition| v-solver-2468))
    (progn (setf (m-u8 (+ v-solver-2468 4)) (c-bool 1)))
    (return-from |c/analyze_conflict| (c-bool 0))
    ELSE2470
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 16))) 1 0)) (go ELSE2478))
    (setf v-old_size-2483 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4)))
    (setf v-old_capacity-2484 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 16)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4)))
    (setf v-new_capacity-2485 (if (c-true v-old_capacity-2484) (c-u64 (* (c-u64 2) v-old_capacity-2484)) (c-u64 1)))
    (setf v-new_bytes-2486 (c-u64 (* v-new_capacity-2485 4)))
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-2468 624) 0)) v-new_bytes-2486)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-2468 624) 0))) 0 1)) (go ELSE2487))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-2486))
    (go ENDIF2488)
    ELSE2487
    ENDIF2488
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 8)) (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 v-old_size-2483))))
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 16)) (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 v-new_capacity-2485))))
    (go ENDIF2479)
    ELSE2478
    ENDIF2479
    (progn (setf (m-u32 (let* ((a2489 (+ (+ v-solver-2468 624) 8)) (old2490 (m-ptr a2489))) (setf (m-ptr a2489) (+ old2490 (* 4 1))) old2490)) 4294967295))
    (setf (m-u32 v-forced-2491) 4294967295)
    (setf v-forcedp-2492 v-forced-2491)
    (setf v-conflict_level-2493 (c-u32 (|c/find_conflict_level| v-solver-2468 v-conflict-2469 v-forcedp-2492)))
    (unless (c-true (if (c-true v-conflict_level-2493) 0 1)) (go ELSE2494))
    (progn v-solver-2468)
    (progn (|c/trace_and_check_empty_addition| v-solver-2468))
    (progn (setf (m-u8 (+ v-solver-2468 4)) (c-bool 1)))
    (return-from |c/analyze_conflict| (c-bool 0))
    ELSE2494
    (unless (c-true (if (/= (m-u32 v-forcedp-2492) 4294967295) 1 0)) (go ELSE2499))
    (progn v-solver-2468)
    (progn (|c/backtrack| v-solver-2468 (c-u32 (- v-conflict_level-2493 (c-u32 1)))))
    (unless (c-true (if (c-true (|c/is_temporary_binary| v-solver-2468 v-conflict-2469)) 1 (c-bool (if (= (m-u32 (+ v-conflict-2469 12)) (c-u32 2)) 1 0)))) (go ELSE2504))
    (setf v-other-2506 (c-u32 (logxor (c-u32 (logxor (m-u32 v-forcedp-2492) (m-u32 (+ (+ v-conflict-2469 16) (* 4 0))))) (m-u32 (+ (+ v-conflict-2469 16) (* 4 1))))))
    (setf v-reason-2507 (|c/tag_binary_clause| (c-bool 1) v-other-2506))
    (progn (|c/assign| v-solver-2468 (m-u32 v-forcedp-2492) v-reason-2507 (c-bool 0)))
    (go ENDIF2505)
    ELSE2504
    (progn (|c/assign| v-solver-2468 (m-u32 v-forcedp-2492) v-conflict-2469 (c-bool 0)))
    ENDIF2505
    (progn (setf (m-ptr (+ (+ v-solver-2468 648) 8)) (m-ptr (+ (+ v-solver-2468 648) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))))
    (return-from |c/analyze_conflict| (c-bool 1))
    ELSE2499
    (unless (c-true (if (< v-conflict_level-2493 (m-u32 (+ v-solver-2468 8))) 1 0)) (go ELSE2514))
    (progn v-solver-2468)
    (progn (|c/backtrack| v-solver-2468 v-conflict_level-2493))
    (go ENDIF2515)
    ELSE2514
    (progn v-solver-2468)
    ENDIF2515
    (setf v-marks-2522 (m-ptr (+ v-solver-2468 96)))
    (setf v-levels-2523 (m-ptr (+ v-solver-2468 32)))
    (setf v-reasons-2524 (m-ptr (+ v-solver-2468 416)))
    (setf v-frames-2525 (m-ptr (+ v-solver-2468 232)))
    (setf v-reason-2526 v-conflict-2469)
    (setf v-t-2527 (m-ptr (+ (+ v-solver-2468 552) 8)))
    (setf v-unresolved_on_current_level-2528 (c-u32 0))
    (setf v-uip-2529 4294967295)
    (locally (declare (optimize (speed 1))) (setf v-ticks-2530 (c-u64 0)))
    LOOP2531
    (progn v-solver-2468)
    (unless (c-true (if (c-true (|c/is_temporary_binary| v-solver-2468 v-reason-2526)) 0 1)) (go ELSE2537))
    (unless (c-true (if (c-true (ldb (byte 2 4) (m-u8 (+ v-reason-2526 0)))) 0 1)) (go ELSE2539))
    (progn (set-bits (+ v-reason-2526 0) 4 2 (c-u32 1)))
    (go ENDIF2540)
    ELSE2539
    (unless (c-true (if (<= (m-u32 (+ v-reason-2526 4)) (c-u32 6)) 1 0)) (go ELSE2541))
    (progn (set-bits (+ v-reason-2526 0) 4 2 (c-u32 2)))
    (go ENDIF2542)
    ELSE2541
    ENDIF2542
    ENDIF2540
    (progn (let* ( (old2544 v-ticks-2530)) (setf v-ticks-2530 (c-u64 (c-u64 (+ old2544 (c-u64 1))))) old2544))
    (go ENDIF2538)
    ELSE2537
    ENDIF2538
    (setf v-P_lit-2549 (+ v-reason-2526 16))
    (setf v-END_lit-2550 (+ v-P_lit-2549 (* 4 (m-u32 (+ v-reason-2526 12)))))
    LOOP2545
    (unless (c-true (if (c-true (if (/= v-P_lit-2549 v-END_lit-2550) 1 0)) (c-bool (progn (setf v-lit-2548 (m-u32 v-P_lit-2549)) 1)) 0)) (go ENDLOOP2546))
    (unless (c-true (if (= v-lit-2548 v-uip-2529) 1 0)) (go ELSE2551))
    (go CONTINUE2547)
    ELSE2551
    (setf v-lit_level-2553 (|c/analyze_literal| v-solver-2468 v-lit-2548))
    (unless (c-true (if (= v-lit_level-2553 4294967295) 1 0)) (go ELSE2554))
    (go CONTINUE2547)
    ELSE2554
    (unless (c-true (if (< v-lit_level-2553 v-conflict_level-2493) 1 0)) (go ELSE2556))
    (unless (c-true (if (c-true (m-s8 (+ v-frames-2525 (* 1 v-lit_level-2553)))) 0 1)) (go ELSE2558))
    (progn v-solver-2468)
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-2468 648) 8)) (m-ptr (+ (+ v-solver-2468 648) 16))) 1 0)) (go ELSE2566))
    (setf v-old_size-2571 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 648) 8)) (m-ptr (+ (+ v-solver-2468 648) 0))) 4)))
    (setf v-old_capacity-2572 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 648) 16)) (m-ptr (+ (+ v-solver-2468 648) 0))) 4)))
    (setf v-new_capacity-2573 (if (c-true v-old_capacity-2572) (c-u64 (* (c-u64 2) v-old_capacity-2572)) (c-u64 1)))
    (setf v-new_bytes-2574 (c-u64 (* v-new_capacity-2573 4)))
    (progn (setf (m-ptr (+ (+ v-solver-2468 648) 0)) (c-realloc (m-ptr (+ (+ v-solver-2468 648) 0)) v-new_bytes-2574)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-2468 648) 0))) 0 1)) (go ELSE2575))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-2574))
    (go ENDIF2576)
    ELSE2575
    ENDIF2576
    (progn (setf (m-ptr (+ (+ v-solver-2468 648) 8)) (+ (m-ptr (+ (+ v-solver-2468 648) 0)) (* 4 v-old_size-2571))))
    (progn (setf (m-ptr (+ (+ v-solver-2468 648) 16)) (+ (m-ptr (+ (+ v-solver-2468 648) 0)) (* 4 v-new_capacity-2573))))
    (go ENDIF2567)
    ELSE2566
    ENDIF2567
    (progn (setf (m-u32 (let* ((a2577 (+ (+ v-solver-2468 648) 8)) (old2578 (m-ptr a2577))) (setf (m-ptr a2577) (+ old2578 (* 4 1))) old2578)) v-lit_level-2553))
    (progn (setf (m-s8 (+ v-frames-2525 (* 1 v-lit_level-2553))) (c-s8 1)))
    (go ENDIF2559)
    ELSE2558
    ENDIF2559
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 16))) 1 0)) (go ELSE2582))
    (setf v-old_size-2587 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4)))
    (setf v-old_capacity-2588 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 16)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4)))
    (setf v-new_capacity-2589 (if (c-true v-old_capacity-2588) (c-u64 (* (c-u64 2) v-old_capacity-2588)) (c-u64 1)))
    (setf v-new_bytes-2590 (c-u64 (* v-new_capacity-2589 4)))
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-2468 624) 0)) v-new_bytes-2590)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-2468 624) 0))) 0 1)) (go ELSE2591))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-2590))
    (go ENDIF2592)
    ELSE2591
    ENDIF2592
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 8)) (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 v-old_size-2587))))
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 16)) (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 v-new_capacity-2589))))
    (go ENDIF2583)
    ELSE2582
    ENDIF2583
    (progn (setf (m-u32 (let* ((a2593 (+ (+ v-solver-2468 624) 8)) (old2594 (m-ptr a2593))) (setf (m-ptr a2593) (+ old2594 (* 4 1))) old2594)) v-lit-2548))
    (setf v-idx-2595 (|c/INDEX| v-lit-2548))
    (setf v-level-2596 (m-u32 (+ (m-ptr (+ v-solver-2468 32)) (* 4 v-idx-2595))))
    (unless (c-true (if (/= v-level-2596 (c-u32 0)) 1 0)) (go ELSE2597))
    (setf v-saved-2599 (+ (m-ptr (+ (+ v-solver-2468 576) 0)) (* 24 (progn 0 (c-u32 (- v-level-2596 (c-u32 1)))))))
    (unless (c-true (if (> (m-u32 (+ (+ v-saved-2599 12) 0)) (m-u32 (+ (m-ptr (+ v-solver-2468 224)) (* 4 v-idx-2595)))) 1 0)) (go ELSE2600))
    (progn (setf (m-u32 (+ (+ v-saved-2599 12) 0)) (m-u32 (+ (m-ptr (+ v-solver-2468 224)) (* 4 v-idx-2595)))))
    (go ENDIF2601)
    ELSE2600
    ENDIF2601
    (progn (let* ((a2602 (+ (+ v-saved-2599 12) 4)) (old2603 (m-u32 a2602))) (setf (m-u32 a2602) (c-u32 (c-u32 (+ old2603 (c-u32 1))))) (m-u32 a2602)))
    (progn v-solver-2468)
    (go ENDIF2598)
    ELSE2597
    ENDIF2598
    (go ENDIF2557)
    ELSE2556
    (progn (let* ( (old2608 v-unresolved_on_current_level-2528)) (setf v-unresolved_on_current_level-2528 (c-u32 (c-u32 (+ old2608 (c-u32 1))))) old2608))
    ENDIF2557
    CONTINUE2547
    (let* ( (old2610 v-P_lit-2549)) (setf v-P_lit-2549 (+ old2610 (* 4 1))) v-P_lit-2549)
    (go LOOP2545)
    ENDLOOP2546
    LOOP2612
    (unless (c-true (if (= (m-u32 (+ (m-ptr (+ v-solver-2468 32)) (* 4 (|c/INDEX| (m-u32 (let* ( (old2618 v-t-2527)) (setf v-t-2527 (- old2618 (* 4 1))) v-t-2527)))))) (m-u32 (+ v-solver-2468 8))) 1 0)) (go ELSE2615))
    (progn (setf v-uip-2529 (m-u32 v-t-2527)))
    (go ENDIF2616)
    ELSE2615
    (progn (setf v-uip-2529 4294967295))
    ENDIF2616
    (when (c-true (if (c-true (if (= v-uip-2529 4294967295) 1 0)) 1 (c-bool (if (c-true (m-s8 (+ v-marks-2522 (* 1 (setf v-uip_idx-2611 (|c/INDEX| v-uip-2529)))))) 0 1)))) (go LOOP2612))
    (progn v-solver-2468)
    (unless (c-true (if (c-true (let* ( (old2625 v-unresolved_on_current_level-2528)) (setf v-unresolved_on_current_level-2528 (c-u32 (c-u32 (- old2625 (c-u32 1))))) v-unresolved_on_current_level-2528)) 0 1)) (go ELSE2622))
    (go ENDLOOP2532)
    ELSE2622
    (progn (setf v-reason-2526 (m-ptr (+ v-reasons-2524 (* 8 v-uip_idx-2611)))))
    (unless (c-true (|c/is_tagged_clause| v-reason-2526)) (go ELSE2626))
    (progn (setf v-reason-2526 (|c/untag_clause| v-solver-2468 (c-u32 0) v-uip-2529 v-reason-2526)))
    (go ENDIF2627)
    ELSE2626
    ENDIF2627
    (go LOOP2531)
    ENDLOOP2532
    (progn v-solver-2468)
    (setf v-not_uip-2631 (|c/NOT| v-uip-2529))
    (progn (setf (m-u32 (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 (progn 0 0)))) v-not_uip-2631))
    (progn (let ((a2635 (+ (+ v-solver-2468 1016) 360))) (setf (m-u64 a2635) (c-u64 (c-u64 (+ (m-u64 a2635) v-ticks-2530))))))
    (progn v-solver-2468)
    (setf v-size-2639 (c-u32 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4))))
    (progn (let ((a2643 (+ (+ v-solver-2468 1016) 72))) (setf (m-u64 a2643) (c-u64 (c-u64 (+ (m-u64 a2643) v-size-2639))))))
    (progn (|c/sort_deduced_clause| v-solver-2468))
    (progn (|c/start_profiling| v-solver-2468 (+ (+ v-solver-2468 1472) 192)))
    (progn (|c/shrink_deduced_clause| v-solver-2468))
    (progn (|c/reset_removable_and_poisoned| v-solver-2468))
    (progn (|c/stop_profiling| v-solver-2468 (+ (+ v-solver-2468 1472) 192) (|c/process_time|)))
    (progn (setf v-size-2639 (c-u32 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))) 4)))))
    (setf v-glue-2644 (c-u32 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 648) 8)) (m-ptr (+ (+ v-solver-2468 648) 0))) 4))))
    (setf (m-u32 v-asserting_level-2645) (c-u32 0))
    (setf v-jump_level-2646 (|c/determine_jump_level| v-solver-2468 v-conflict_level-2493 v-asserting_level-2645))
    (progn (setf (m-ptr (+ (+ v-solver-2468 648) 8)) (m-ptr (+ (+ v-solver-2468 648) 0))))
    (setf v-a-2650 (|c/averages| v-solver-2468))
    (progn (|c/update_fast_average| (+ v-a-2650 48) v-glue-2644))
    (progn (|c/update_slow_average| (+ v-a-2650 8) v-glue-2644))
    (progn (|c/update_slow_average| (+ v-a-2650 0) v-conflict_level-2493))
    (locally (declare (optimize (speed 1))) (setf v-decisions-2651 (m-u64 (+ (+ v-solver-2468 1016) 64))))
    (locally (declare (optimize (speed 1))) (setf v-delta_decisions-2652 (c-u64 (- v-decisions-2651 (m-u64 (+ v-a-2650 40))))))
    (progn (setf (m-u64 (+ v-a-2650 40)) v-decisions-2651))
    (progn (|c/update_slow_average| (+ v-a-2650 32) (c-u32 v-delta_decisions-2652)))
    (setf v-trail_filled-2653 (|c/percent| (integer64-double (the c-size (truncate (- (m-ptr (+ (+ v-solver-2468 552) 8)) (m-ptr (+ (+ v-solver-2468 552) 0))) 4)) nil) (integer64-double (m-u64 (+ (+ v-solver-2468 1016) 216)) nil)))
    (progn (|c/update_slow_average| (+ v-a-2650 24) (values (the (unsigned-byte 32) (truncate v-trail_filled-2653)))))
    (progn (|c/update_betas| v-solver-2468))
    (progn v-solver-2468)
    (progn v-solver-2468)
    (progn v-solver-2468)
    (progn v-solver-2468)
    (progn (|c/bump_reason_side_literals| v-solver-2468))
    (unless (c-true (if (c-true (m-u8 (+ v-solver-2468 6))) 0 1)) (go ELSE2666))
    (progn (|c/sort_analyzed| v-solver-2468))
    (go ENDIF2667)
    ELSE2666
    ENDIF2667
    (setf v-PTR_analyzed-2672 (m-ptr (+ (+ v-solver-2468 600) 0)))
    (setf v-END_analyzed-2673 (m-ptr (+ (+ v-solver-2468 600) 8)))
    LOOP2668
    (unless (c-true (if (c-true (if (/= v-PTR_analyzed-2672 v-END_analyzed-2673) 1 0)) (c-bool (progn (copy-bytes v-analyzed-2671 v-PTR_analyzed-2672 8) 1)) 0)) (go ENDLOOP2669))
    (setf v-idx-2674 (m-u32 (+ v-analyzed-2671 0)))
    (progn (progn 0 (let* ((a2675 (+ (+ v-solver-2468 1016) 32)) (old2676 (m-u64 a2675))) (setf (m-u64 a2675) (c-u64 (c-u64 (+ old2676 (c-u64 1))))) (m-u64 a2675))))
    (unless (c-true (m-u8 (+ v-solver-2468 6))) (go ELSE2677))
    (progn (|c/bump_variable_score| v-solver-2468 v-idx-2674))
    (go ENDIF2678)
    ELSE2677
    (progn (|c/move_variable_to_front| v-solver-2468 v-idx-2674))
    ENDIF2678
    (progn (setf (m-s8 (+ v-marks-2522 (* 1 v-idx-2674))) (c-s8 0)))
    (let* ( (old2680 v-PTR_analyzed-2672)) (setf v-PTR_analyzed-2672 (+ old2680 (* 8 1))) v-PTR_analyzed-2672)
    (go LOOP2668)
    ENDLOOP2669
    (progn (setf (m-ptr (+ (+ v-solver-2468 600) 8)) (m-ptr (+ (+ v-solver-2468 600) 0))))
    (unless (c-true (m-u8 (+ v-solver-2468 6))) (go ELSE2684))
    (progn (|c/bump_score_increment| v-solver-2468))
    (go ENDIF2685)
    ELSE2684
    ENDIF2685
    (progn (|c/trace_and_check_temporary_addition| v-solver-2468))
    (progn (|c/backtrack| v-solver-2468 (c-u32 (- (m-u32 (+ v-solver-2468 8)) (c-u32 1)))))
    (unless (c-true (m-u8 (+ v-solver-2468 6))) (go ELSE2686))
    (progn (|c/update_phases| v-solver-2468))
    (go ENDIF2687)
    ELSE2686
    ENDIF2687
    (unless (c-true (if (< v-jump_level-2646 (m-u32 (+ v-solver-2468 8))) 1 0)) (go ELSE2688))
    (progn (|c/backtrack| v-solver-2468 v-jump_level-2646))
    (go ENDIF2689)
    ELSE2688
    ENDIF2689
    (unless (c-true (if (= v-size-2639 (c-u32 1)) 1 0)) (go ELSE2690))
    (progn (setf (m-u8 (+ v-solver-2468 5)) (c-bool 1)))
    (progn (|c/assign| v-solver-2468 v-not_uip-2631 0 (c-bool 1)))
    (go ENDIF2691)
    ELSE2690
    (unless (c-true (if (= v-size-2639 (c-u32 2)) 1 0)) (go ELSE2692))
    (setf v-other-2694 (m-u32 (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 (progn 0 1)))))
    (progn v-solver-2468)
    (progn (|c/add_new_binary_and_watch_it| v-solver-2468 (c-bool 1)))
    (progn (let ((a2701 (+ (+ v-solver-2468 1016) 128))) (setf (m-u64 a2701) (c-u64 (c-u64 (+ (m-u64 a2701) (c-u64 2)))))))
    (setf v-reason-2702 (|c/tag_binary_clause| (c-bool 1) v-other-2694))
    (progn (|c/assign| v-solver-2468 v-not_uip-2631 v-reason-2702 (c-bool 0)))
    (go ENDIF2693)
    ELSE2692
    (setf v-p-2706 (+ (m-ptr (+ (+ v-solver-2468 624) 0)) (* 4 1)))
    (setf v-q-2707 v-p-2706)
    LOOP2703
    (setf v-lit-2708 (m-u32 v-q-2707))
    (setf v-idx-2709 (|c/INDEX| v-lit-2708))
    (setf v-lit_level-2710 (m-u32 (+ v-levels-2523 (* 4 v-idx-2709))))
    (unless (c-true (if (= v-lit_level-2710 (m-u32 v-asserting_level-2645)) 1 0)) (go ELSE2711))
    (progn (setf (m-u32 v-q-2707) (m-u32 v-p-2706)))
    (progn (setf (m-u32 v-p-2706) v-lit-2708))
    (go ENDLOOP2704)
    ELSE2711
    (let* ( (old2714 v-q-2707)) (setf v-q-2707 (+ old2714 (* 4 1))) old2714)
    (go LOOP2703)
    ENDLOOP2704
    (setf v-learned-2715 (|c/new_redundant_clause| v-solver-2468 v-glue-2644))
    (unless (c-true (if (<= v-glue-2644 (c-u32 6)) 1 0)) (go ELSE2716))
    (progn (set-bits (+ v-learned-2715 0) 4 2 (c-u32 2)))
    (go ENDIF2717)
    ELSE2716
    (progn (set-bits (+ v-learned-2715 0) 4 2 (c-u32 1)))
    ENDIF2717
    (progn v-solver-2468)
    (progn (let ((a2724 (+ (+ v-solver-2468 1016) 128))) (setf (m-u64 a2724) (c-u64 (c-u64 (+ (m-u64 a2724) v-size-2639))))))
    (progn (|c/watch_clause| v-solver-2468 v-learned-2715))
    (progn (|c/assign| v-solver-2468 v-not_uip-2631 v-learned-2715 (c-bool 0)))
    ENDIF2693
    ENDIF2691
    (progn (setf (m-ptr (+ (+ v-solver-2468 624) 8)) (m-ptr (+ (+ v-solver-2468 624) 0))))
    (return-from |c/analyze_conflict| (c-bool 1))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:6450:1
(defun |c/max_stamped_unassigned_variable_on_decision_queue| (arg-v-solver-2728)
 (declare  (type c-address arg-v-solver-2728))
 (let ((v-solver-2728 0) (v-queue-2729 0) (v-links-2730 0) (v-values-2731 0) (v-idx-2732 0) (v-lit-2736 0) (v-value-2737 0))
 (declare (type c-address v-solver-2728) (type c-address v-queue-2729) (type c-address v-links-2730) (type c-address v-values-2731) (type (unsigned-byte 32) v-idx-2732) (type (unsigned-byte 32) v-lit-2736) (type (signed-byte 8) v-value-2737) (ignorable v-solver-2728 v-queue-2729 v-links-2730 v-values-2731 v-idx-2732 v-lit-2736 v-value-2737))
 (tagbody
    (setf v-solver-2728 arg-v-solver-2728)
    (setf v-queue-2729 (|c/get_queue| v-solver-2728))
    (setf v-links-2730 (m-ptr (+ v-queue-2729 0)))
    (setf v-values-2731 (m-ptr (+ v-solver-2728 40)))
    (setf v-idx-2732 (m-u32 (+ v-queue-2729 20)))
    LOOP2733
    (setf v-lit-2736 (|c/LITERAL| v-idx-2732))
    (setf v-value-2737 (m-s8 (+ v-values-2731 (* 1 v-lit-2736))))
    (unless (c-true (if (c-true v-value-2737) 0 1)) (go ELSE2738))
    (go ENDLOOP2734)
    ELSE2738
    (progn (setf v-idx-2732 (m-u32 (+ (+ v-links-2730 (* 12 v-idx-2732)) 0))))
    (go LOOP2733)
    ENDLOOP2734
    (progn (setf (m-u32 (+ v-queue-2729 20)) v-idx-2732))
    (progn v-solver-2728)
    (return-from |c/max_stamped_unassigned_variable_on_decision_queue| v-idx-2732)
  )
  0))

;;; upstream/satch.c:6479:1
(defun |c/max_score_unassigned_variable_on_binary_heap| (arg-v-solver-2743)
 (declare  (type c-address arg-v-solver-2743))
 (let ((v-solver-2743 0) (v-values-2744 0) (v-scores-2745 0) (v-idx-2746 0) (v-lit-2750 0) (v-value-2751 0))
 (declare (type c-address v-solver-2743) (type c-address v-values-2744) (type c-address v-scores-2745) (type (unsigned-byte 32) v-idx-2746) (type (unsigned-byte 32) v-lit-2750) (type (signed-byte 8) v-value-2751) (ignorable v-solver-2743 v-values-2744 v-scores-2745 v-idx-2746 v-lit-2750 v-value-2751))
 (tagbody
    (setf v-solver-2743 arg-v-solver-2743)
    (setf v-values-2744 (m-ptr (+ v-solver-2743 40)))
    (setf v-scores-2745 (|c/get_scores| v-solver-2743))
    LOOP2747
    (progn (setf v-idx-2746 (|c/max_heap| v-scores-2745)))
    (setf v-lit-2750 (|c/LITERAL| v-idx-2746))
    (setf v-value-2751 (m-s8 (+ v-values-2744 (* 1 v-lit-2750))))
    (unless (c-true (if (c-true v-value-2751) 0 1)) (go ELSE2752))
    (go ENDLOOP2748)
    ELSE2752
    (progn (|c/pop_heap| v-solver-2743 v-scores-2745))
    (go LOOP2747)
    ENDLOOP2748
    (progn v-solver-2743)
    (return-from |c/max_score_unassigned_variable_on_binary_heap| v-idx-2746)
  )
  0))

;;; upstream/satch.c:6516:1
(defun |c/decide_variable| (arg-v-solver-2757)
 (declare  (type c-address arg-v-solver-2757))
 (let ((v-solver-2757 0) (v-idx-2758 0))
 (declare (type c-address v-solver-2757) (type (unsigned-byte 32) v-idx-2758) (ignorable v-solver-2757 v-idx-2758))
 (tagbody
    (setf v-solver-2757 arg-v-solver-2757)
    (unless (c-true (m-u8 (+ v-solver-2757 6))) (go ELSE2759))
    (progn (setf v-idx-2758 (|c/max_score_unassigned_variable_on_binary_heap| v-solver-2757)))
    (go ENDIF2760)
    ELSE2759
    (progn (setf v-idx-2758 (|c/max_stamped_unassigned_variable_on_decision_queue| v-solver-2757)))
    ENDIF2760
    (progn v-solver-2757)
    (return-from |c/decide_variable| v-idx-2758)
  )
  0))

;;; upstream/satch.c:6547:1
(defun |c/original_phase| ()
 (declare  )
 (let ()
 
 (tagbody
    (return-from |c/original_phase| 1)
  )
  0))

;;; upstream/satch.c:6557:1
(defun |c/decide_phase| (arg-v-solver-2764 arg-v-idx-2765)
 (declare  (type c-address arg-v-solver-2764) (type (unsigned-byte 32) arg-v-idx-2765))
 (let ((v-solver-2764 0) (v-idx-2765 0) (v-value-2766 0))
 (declare (type c-address v-solver-2764) (type (unsigned-byte 32) v-idx-2765) (type (signed-byte 8) v-value-2766) (ignorable v-solver-2764 v-idx-2765 v-value-2766))
 (tagbody
    (setf v-solver-2764 arg-v-solver-2764)
    (setf v-idx-2765 arg-v-idx-2765)
    (setf v-value-2766 (c-s8 0))
    (unless (c-true (m-u8 (+ v-solver-2764 6))) (go ELSE2767))
    (progn (setf v-value-2766 (m-s8 (+ (m-ptr (+ v-solver-2764 64)) (* 1 v-idx-2765)))))
    (go ENDIF2768)
    ELSE2767
    ENDIF2768
    (unless (c-true (if (c-true v-value-2766) 0 1)) (go ELSE2769))
    (progn (setf v-value-2766 (m-s8 (+ (m-ptr (+ v-solver-2764 56)) (* 1 v-idx-2765)))))
    (go ENDIF2770)
    ELSE2769
    ENDIF2770
    (unless (c-true (if (c-true v-value-2766) 0 1)) (go ELSE2771))
    (progn (setf v-value-2766 (c-s8 (|c/original_phase|))))
    (go ENDIF2772)
    ELSE2771
    ENDIF2772
    (progn v-solver-2764)
    (progn v-idx-2765)
    (return-from |c/decide_phase| v-value-2766)
  )
  0))

;;; upstream/satch.c:6580:1
(defun |c/decide| (arg-v-solver-2776)
 (declare  (type c-address arg-v-solver-2776))
 (let ((v-solver-2776 0) (v-idx-2781 0) (v-value-2782 0) (v-lit-2783 0) (v-decision-2784 0))
 (declare (type c-address v-solver-2776) (type (unsigned-byte 32) v-idx-2781) (type (signed-byte 32) v-value-2782) (type (unsigned-byte 32) v-lit-2783) (type (unsigned-byte 32) v-decision-2784) (ignorable v-solver-2776 v-idx-2781 v-value-2782 v-lit-2783 v-decision-2784))
 (tagbody
    (setf v-solver-2776 arg-v-solver-2776)
    (progn (|c/start_profiling| v-solver-2776 (+ (+ v-solver-2776 1472) 168)))
    (progn (progn 0 (let* ((a2777 (+ (+ v-solver-2776 1016) 64)) (old2778 (m-u64 a2777))) (setf (m-u64 a2777) (c-u64 (c-u64 (+ old2778 (c-u64 1))))) (m-u64 a2777))))
    (progn (let* ((a2779 (+ v-solver-2776 8)) (old2780 (m-u32 a2779))) (setf (m-u32 a2779) (c-u32 (c-u32 (+ old2780 (c-u32 1))))) old2780))
    (setf v-idx-2781 (|c/decide_variable| v-solver-2776))
    (setf v-value-2782 (|c/decide_phase| v-solver-2776 v-idx-2781))
    (setf v-lit-2783 (|c/LITERAL| v-idx-2781))
    (setf v-decision-2784 (if (c-true (if (< v-value-2782 0) 1 0)) (|c/NOT| v-lit-2783) v-lit-2783))
    (progn v-solver-2776)
    (progn (|c/assign| v-solver-2776 v-decision-2784 0 (c-bool 0)))
    (progn (|c/stop_profiling| v-solver-2776 (+ (+ v-solver-2776 1472) 168) (|c/process_time|)))
  )
  0))

;;; upstream/satch.c:6694:1
(defun |c/report| (arg-v-solver-2788 arg-v-verbose-2789 arg-v-type-2790)
 (declare (optimize (speed 1) (safety 1)) (notinline checked-address) (type c-address arg-v-solver-2788) (type (unsigned-byte 32) arg-v-verbose-2789) (type (signed-byte 32) arg-v-type-2790))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-2788 0) (v-verbose-2789 0) (v-type-2790 0) (v-a-2795 0) (v-seconds-2796 0d0) (v-MB-2797 0d0) (v-level-2798 0d0) (v-switched-2799 0) (v-reductions-2800 0) (v-restarts-2801 0) (v-rate-2802 0d0) (v-conflicts-2803 0) (v-redundant-2804 0) (v-trail-2805 0d0) (v-glue-2806 0d0) (v-irredundant-2807 0) (v-variables-2808 0) (v-remaining-2809 0d0) (v-num_reported-2810 0) (v-column-2811 (stack-alloc 64)) (v-line-2812 (stack-alloc 256)) (v-end_line-2813 0) (v-buffer-2824 (stack-alloc 32)) (v-p-2828 0) (v-buffer-2837 (stack-alloc 32)) (v-p-2841 0) (v-buffer-2850 (stack-alloc 32)) (v-p-2854 0) (v-buffer-2863 (stack-alloc 32)) (v-p-2867 0) (v-buffer-2876 (stack-alloc 32)) (v-p-2880 0) (v-buffer-2889 (stack-alloc 32)) (v-p-2893 0) (v-buffer-2902 (stack-alloc 32)) (v-p-2906 0) (v-buffer-2915 (stack-alloc 32)) (v-p-2919 0) (v-buffer-2928 (stack-alloc 32)) (v-p-2932 0) (v-buffer-2941 (stack-alloc 32)) (v-p-2945 0) (v-buffer-2954 (stack-alloc 32)) (v-p-2958 0) (v-buffer-2967 (stack-alloc 32)) (v-p-2971 0) (v-buffer-2980 (stack-alloc 32)) (v-p-2984 0) (v-buffer-2993 (stack-alloc 32)) (v-p-2997 0) (v-colors-3002 0) (v-terminal_file-3003 0) (v-header-3006 (stack-alloc 768)) (v-end_header-3007 (stack-alloc 12)) (v-i-3011 0) (v-reported-3014 0) (v-row-3015 0) (v-start-3018 0) (v-end-3021 0) (v-value_width-3022 0) (v-name_width-3023 0) (v-target-3024 0) (v-p-3035 0) (v-row-3040 0) (v-start-3043 0) (v-end-3046 0) (v-value_width-3047 0) (v-name_width-3048 0) (v-target-3049 0) (v-p-3060 0) (v-row-3065 0) (v-start-3068 0) (v-end-3071 0) (v-value_width-3072 0) (v-name_width-3073 0) (v-target-3074 0) (v-p-3085 0) (v-row-3090 0) (v-start-3093 0) (v-end-3096 0) (v-value_width-3097 0) (v-name_width-3098 0) (v-target-3099 0) (v-p-3110 0) (v-row-3115 0) (v-start-3118 0) (v-end-3121 0) (v-value_width-3122 0) (v-name_width-3123 0) (v-target-3124 0) (v-p-3135 0) (v-row-3140 0) (v-start-3143 0) (v-end-3146 0) (v-value_width-3147 0) (v-name_width-3148 0) (v-target-3149 0) (v-p-3160 0) (v-row-3165 0) (v-start-3168 0) (v-end-3171 0) (v-value_width-3172 0) (v-name_width-3173 0) (v-target-3174 0) (v-p-3185 0) (v-row-3190 0) (v-start-3193 0) (v-end-3196 0) (v-value_width-3197 0) (v-name_width-3198 0) (v-target-3199 0) (v-p-3210 0) (v-row-3215 0) (v-start-3218 0) (v-end-3221 0) (v-value_width-3222 0) (v-name_width-3223 0) (v-target-3224 0) (v-p-3235 0) (v-row-3240 0) (v-start-3243 0) (v-end-3246 0) (v-value_width-3247 0) (v-name_width-3248 0) (v-target-3249 0) (v-p-3260 0) (v-row-3265 0) (v-start-3268 0) (v-end-3271 0) (v-value_width-3272 0) (v-name_width-3273 0) (v-target-3274 0) (v-p-3285 0) (v-row-3290 0) (v-start-3293 0) (v-end-3296 0) (v-value_width-3297 0) (v-name_width-3298 0) (v-target-3299 0) (v-p-3310 0) (v-row-3315 0) (v-start-3318 0) (v-end-3321 0) (v-value_width-3322 0) (v-name_width-3323 0) (v-target-3324 0) (v-p-3335 0) (v-row-3340 0) (v-start-3343 0) (v-end-3346 0) (v-value_width-3347 0) (v-name_width-3348 0) (v-target-3349 0) (v-p-3360 0) (v-i-3368 0) (v-j-3377 0) (v-reset-3387 0) (v-magenta-3390 0) (switch3392 0) (v-i-3410 0))
 (declare (type c-address v-solver-2788) (type (unsigned-byte 32) v-verbose-2789) (type (signed-byte 32) v-type-2790) (type c-address v-a-2795) (type double-float v-seconds-2796) (type double-float v-MB-2797) (type double-float v-level-2798) (type (unsigned-byte 64) v-switched-2799) (type (unsigned-byte 64) v-reductions-2800) (type (unsigned-byte 64) v-restarts-2801) (type double-float v-rate-2802) (type (unsigned-byte 64) v-conflicts-2803) (type (unsigned-byte 64) v-redundant-2804) (type double-float v-trail-2805) (type double-float v-glue-2806) (type (unsigned-byte 64) v-irredundant-2807) (type (unsigned-byte 64) v-variables-2808) (type double-float v-remaining-2809) (type (signed-byte 32) v-num_reported-2810) (type c-address v-column-2811) (type c-address v-line-2812) (type (signed-byte 32) v-end_line-2813) (type c-address v-buffer-2824) (type c-address v-p-2828) (type c-address v-buffer-2837) (type c-address v-p-2841) (type c-address v-buffer-2850) (type c-address v-p-2854) (type c-address v-buffer-2863) (type c-address v-p-2867) (type c-address v-buffer-2876) (type c-address v-p-2880) (type c-address v-buffer-2889) (type c-address v-p-2893) (type c-address v-buffer-2902) (type c-address v-p-2906) (type c-address v-buffer-2915) (type c-address v-p-2919) (type c-address v-buffer-2928) (type c-address v-p-2932) (type c-address v-buffer-2941) (type c-address v-p-2945) (type c-address v-buffer-2954) (type c-address v-p-2958) (type c-address v-buffer-2967) (type c-address v-p-2971) (type c-address v-buffer-2980) (type c-address v-p-2984) (type c-address v-buffer-2993) (type c-address v-p-2997) (type (integer 0 1) v-colors-3002) (type c-address v-terminal_file-3003) (type c-address v-header-3006) (type c-address v-end_header-3007) (type (signed-byte 32) v-i-3011) (type (signed-byte 32) v-reported-3014) (type (signed-byte 32) v-row-3015) (type (signed-byte 32) v-start-3018) (type (signed-byte 32) v-end-3021) (type (signed-byte 32) v-value_width-3022) (type (signed-byte 32) v-name_width-3023) (type (signed-byte 32) v-target-3024) (type c-address v-p-3035) (type (signed-byte 32) v-row-3040) (type (signed-byte 32) v-start-3043) (type (signed-byte 32) v-end-3046) (type (signed-byte 32) v-value_width-3047) (type (signed-byte 32) v-name_width-3048) (type (signed-byte 32) v-target-3049) (type c-address v-p-3060) (type (signed-byte 32) v-row-3065) (type (signed-byte 32) v-start-3068) (type (signed-byte 32) v-end-3071) (type (signed-byte 32) v-value_width-3072) (type (signed-byte 32) v-name_width-3073) (type (signed-byte 32) v-target-3074) (type c-address v-p-3085) (type (signed-byte 32) v-row-3090) (type (signed-byte 32) v-start-3093) (type (signed-byte 32) v-end-3096) (type (signed-byte 32) v-value_width-3097) (type (signed-byte 32) v-name_width-3098) (type (signed-byte 32) v-target-3099) (type c-address v-p-3110) (type (signed-byte 32) v-row-3115) (type (signed-byte 32) v-start-3118) (type (signed-byte 32) v-end-3121) (type (signed-byte 32) v-value_width-3122) (type (signed-byte 32) v-name_width-3123) (type (signed-byte 32) v-target-3124) (type c-address v-p-3135) (type (signed-byte 32) v-row-3140) (type (signed-byte 32) v-start-3143) (type (signed-byte 32) v-end-3146) (type (signed-byte 32) v-value_width-3147) (type (signed-byte 32) v-name_width-3148) (type (signed-byte 32) v-target-3149) (type c-address v-p-3160) (type (signed-byte 32) v-row-3165) (type (signed-byte 32) v-start-3168) (type (signed-byte 32) v-end-3171) (type (signed-byte 32) v-value_width-3172) (type (signed-byte 32) v-name_width-3173) (type (signed-byte 32) v-target-3174) (type c-address v-p-3185) (type (signed-byte 32) v-row-3190) (type (signed-byte 32) v-start-3193) (type (signed-byte 32) v-end-3196) (type (signed-byte 32) v-value_width-3197) (type (signed-byte 32) v-name_width-3198) (type (signed-byte 32) v-target-3199) (type c-address v-p-3210) (type (signed-byte 32) v-row-3215) (type (signed-byte 32) v-start-3218) (type (signed-byte 32) v-end-3221) (type (signed-byte 32) v-value_width-3222) (type (signed-byte 32) v-name_width-3223) (type (signed-byte 32) v-target-3224) (type c-address v-p-3235) (type (signed-byte 32) v-row-3240) (type (signed-byte 32) v-start-3243) (type (signed-byte 32) v-end-3246) (type (signed-byte 32) v-value_width-3247) (type (signed-byte 32) v-name_width-3248) (type (signed-byte 32) v-target-3249) (type c-address v-p-3260) (type (signed-byte 32) v-row-3265) (type (signed-byte 32) v-start-3268) (type (signed-byte 32) v-end-3271) (type (signed-byte 32) v-value_width-3272) (type (signed-byte 32) v-name_width-3273) (type (signed-byte 32) v-target-3274) (type c-address v-p-3285) (type (signed-byte 32) v-row-3290) (type (signed-byte 32) v-start-3293) (type (signed-byte 32) v-end-3296) (type (signed-byte 32) v-value_width-3297) (type (signed-byte 32) v-name_width-3298) (type (signed-byte 32) v-target-3299) (type c-address v-p-3310) (type (signed-byte 32) v-row-3315) (type (signed-byte 32) v-start-3318) (type (signed-byte 32) v-end-3321) (type (signed-byte 32) v-value_width-3322) (type (signed-byte 32) v-name_width-3323) (type (signed-byte 32) v-target-3324) (type c-address v-p-3335) (type (signed-byte 32) v-row-3340) (type (signed-byte 32) v-start-3343) (type (signed-byte 32) v-end-3346) (type (signed-byte 32) v-value_width-3347) (type (signed-byte 32) v-name_width-3348) (type (signed-byte 32) v-target-3349) (type c-address v-p-3360) (type (signed-byte 32) v-i-3368) (type (signed-byte 32) v-j-3377) (type (integer 0 1) v-reset-3387) (type (integer 0 1) v-magenta-3390) (type (signed-byte 32) switch3392) (type (signed-byte 32) v-i-3410) (ignorable v-solver-2788 v-verbose-2789 v-type-2790 v-a-2795 v-seconds-2796 v-MB-2797 v-level-2798 v-switched-2799 v-reductions-2800 v-restarts-2801 v-rate-2802 v-conflicts-2803 v-redundant-2804 v-trail-2805 v-glue-2806 v-irredundant-2807 v-variables-2808 v-remaining-2809 v-num_reported-2810 v-column-2811 v-line-2812 v-end_line-2813 v-buffer-2824 v-p-2828 v-buffer-2837 v-p-2841 v-buffer-2850 v-p-2854 v-buffer-2863 v-p-2867 v-buffer-2876 v-p-2880 v-buffer-2889 v-p-2893 v-buffer-2902 v-p-2906 v-buffer-2915 v-p-2919 v-buffer-2928 v-p-2932 v-buffer-2941 v-p-2945 v-buffer-2954 v-p-2958 v-buffer-2967 v-p-2971 v-buffer-2980 v-p-2984 v-buffer-2993 v-p-2997 v-colors-3002 v-terminal_file-3003 v-header-3006 v-end_header-3007 v-i-3011 v-reported-3014 v-row-3015 v-start-3018 v-end-3021 v-value_width-3022 v-name_width-3023 v-target-3024 v-p-3035 v-row-3040 v-start-3043 v-end-3046 v-value_width-3047 v-name_width-3048 v-target-3049 v-p-3060 v-row-3065 v-start-3068 v-end-3071 v-value_width-3072 v-name_width-3073 v-target-3074 v-p-3085 v-row-3090 v-start-3093 v-end-3096 v-value_width-3097 v-name_width-3098 v-target-3099 v-p-3110 v-row-3115 v-start-3118 v-end-3121 v-value_width-3122 v-name_width-3123 v-target-3124 v-p-3135 v-row-3140 v-start-3143 v-end-3146 v-value_width-3147 v-name_width-3148 v-target-3149 v-p-3160 v-row-3165 v-start-3168 v-end-3171 v-value_width-3172 v-name_width-3173 v-target-3174 v-p-3185 v-row-3190 v-start-3193 v-end-3196 v-value_width-3197 v-name_width-3198 v-target-3199 v-p-3210 v-row-3215 v-start-3218 v-end-3221 v-value_width-3222 v-name_width-3223 v-target-3224 v-p-3235 v-row-3240 v-start-3243 v-end-3246 v-value_width-3247 v-name_width-3248 v-target-3249 v-p-3260 v-row-3265 v-start-3268 v-end-3271 v-value_width-3272 v-name_width-3273 v-target-3274 v-p-3285 v-row-3290 v-start-3293 v-end-3296 v-value_width-3297 v-name_width-3298 v-target-3299 v-p-3310 v-row-3315 v-start-3318 v-end-3321 v-value_width-3322 v-name_width-3323 v-target-3324 v-p-3335 v-row-3340 v-start-3343 v-end-3346 v-value_width-3347 v-name_width-3348 v-target-3349 v-p-3360 v-i-3368 v-j-3377 v-reset-3387 v-magenta-3390 switch3392 v-i-3410))
 (tagbody
    (setf v-solver-2788 arg-v-solver-2788)
    (setf v-verbose-2789 arg-v-verbose-2789)
    (setf v-type-2790 arg-v-type-2790)
    (unless (c-true (if (< (m-u32 (+ (+ v-solver-2788 880) 4)) v-verbose-2789) 1 0)) (go ELSE2791))
    (return-from |c/report| 0)
    ELSE2791
    (progn (progn 0 (let* ((a2793 (+ (+ v-solver-2788 1016) 232)) (old2794 (m-u64 a2793))) (setf (m-u64 a2793) (c-u64 (c-u64 (+ old2794 (c-u64 1))))) (m-u64 a2793))))
    (setf v-a-2795 (|c/averages| v-solver-2788))
    (setf v-seconds-2796 (|c/process_time|))
    (setf v-MB-2797 (float (/ (integer64-double (|c/current_resident_set_size|) nil) (float (c-s32 (ash (c-s32 1) 20)) 1d0)) 1d0))
    (setf v-level-2798 (|c/unbiased_slow_average| v-a-2795 (m-f64 (+ v-a-2795 0))))
    (locally (declare (optimize (speed 1))) (setf v-switched-2799 (m-u64 (+ (+ v-solver-2788 1016) 328))))
    (locally (declare (optimize (speed 1))) (setf v-reductions-2800 (m-u64 (+ (+ v-solver-2788 1016) 200))))
    (locally (declare (optimize (speed 1))) (setf v-restarts-2801 (m-u64 (+ (+ v-solver-2788 1016) 256))))
    (setf v-rate-2802 (|c/unbiased_slow_average| v-a-2795 (m-f64 (+ v-a-2795 32))))
    (locally (declare (optimize (speed 1))) (setf v-conflicts-2803 (m-u64 (+ (+ v-solver-2788 1016) 48))))
    (locally (declare (optimize (speed 1))) (setf v-redundant-2804 (m-u64 (+ (+ v-solver-2788 1016) 208))))
    (setf v-trail-2805 (|c/unbiased_slow_average| v-a-2795 (m-f64 (+ v-a-2795 24))))
    (setf v-glue-2806 (|c/unbiased_slow_average| v-a-2795 (m-f64 (+ v-a-2795 8))))
    (locally (declare (optimize (speed 1))) (setf v-irredundant-2807 (m-u64 (+ (+ v-solver-2788 1016) 120))))
    (locally (declare (optimize (speed 1))) (setf v-variables-2808 (m-u64 (+ (+ v-solver-2788 1016) 216))))
    (setf v-remaining-2809 (|c/percent| (integer64-double v-variables-2808 nil) (integer64-double (m-u64 (+ (+ v-solver-2788 1016) 368)) nil)))
    (setf v-num_reported-2810 0)
    (setf v-end_line-2813 0)
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2815 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2815 1)))) old2815)))) (c-s8 99)))
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2817 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2817 1)))) old2817)))) (c-s8 32)))
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2819 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2819 1)))) old2819)))) (c-s8 v-type-2790)))
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2821 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2821 1)))) old2821)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2823 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2823 1)))) old2823)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2824 |c/string/109| v-seconds-2796))
    (setf v-p-2828 v-buffer-2824)
    LOOP2825
    (unless (c-true (m-s8 v-p-2828)) (go ENDLOOP2826))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2830 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2830 1)))) old2830)))) (m-s8 v-p-2828))))
    (let* ( (old2832 v-p-2828)) (setf v-p-2828 (+ old2832 (* 1 1))) old2832)
    (go LOOP2825)
    ENDLOOP2826
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2834 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2834 1)))) old2834)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2836 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2836 1)))) old2836)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2837 |c/string/110| v-MB-2797))
    (setf v-p-2841 v-buffer-2837)
    LOOP2838
    (unless (c-true (m-s8 v-p-2841)) (go ENDLOOP2839))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2843 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2843 1)))) old2843)))) (m-s8 v-p-2841))))
    (let* ( (old2845 v-p-2841)) (setf v-p-2841 (+ old2845 (* 1 1))) old2845)
    (go LOOP2838)
    ENDLOOP2839
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2847 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2847 1)))) old2847)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2849 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2849 1)))) old2849)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2850 |c/string/110| v-level-2798))
    (setf v-p-2854 v-buffer-2850)
    LOOP2851
    (unless (c-true (m-s8 v-p-2854)) (go ENDLOOP2852))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2856 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2856 1)))) old2856)))) (m-s8 v-p-2854))))
    (let* ( (old2858 v-p-2854)) (setf v-p-2854 (+ old2858 (* 1 1))) old2858)
    (go LOOP2851)
    ENDLOOP2852
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2860 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2860 1)))) old2860)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2862 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2862 1)))) old2862)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2863 |c/string/111| v-switched-2799))
    (setf v-p-2867 v-buffer-2863)
    LOOP2864
    (unless (c-true (m-s8 v-p-2867)) (go ENDLOOP2865))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2869 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2869 1)))) old2869)))) (m-s8 v-p-2867))))
    (let* ( (old2871 v-p-2867)) (setf v-p-2867 (+ old2871 (* 1 1))) old2871)
    (go LOOP2864)
    ENDLOOP2865
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2873 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2873 1)))) old2873)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2875 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2875 1)))) old2875)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2876 |c/string/111| v-reductions-2800))
    (setf v-p-2880 v-buffer-2876)
    LOOP2877
    (unless (c-true (m-s8 v-p-2880)) (go ENDLOOP2878))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2882 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2882 1)))) old2882)))) (m-s8 v-p-2880))))
    (let* ( (old2884 v-p-2880)) (setf v-p-2880 (+ old2884 (* 1 1))) old2884)
    (go LOOP2877)
    ENDLOOP2878
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2886 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2886 1)))) old2886)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2888 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2888 1)))) old2888)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2889 |c/string/111| v-restarts-2801))
    (setf v-p-2893 v-buffer-2889)
    LOOP2890
    (unless (c-true (m-s8 v-p-2893)) (go ENDLOOP2891))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2895 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2895 1)))) old2895)))) (m-s8 v-p-2893))))
    (let* ( (old2897 v-p-2893)) (setf v-p-2893 (+ old2897 (* 1 1))) old2897)
    (go LOOP2890)
    ENDLOOP2891
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2899 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2899 1)))) old2899)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2901 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2901 1)))) old2901)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2902 |c/string/110| v-rate-2802))
    (setf v-p-2906 v-buffer-2902)
    LOOP2903
    (unless (c-true (m-s8 v-p-2906)) (go ENDLOOP2904))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2908 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2908 1)))) old2908)))) (m-s8 v-p-2906))))
    (let* ( (old2910 v-p-2906)) (setf v-p-2906 (+ old2910 (* 1 1))) old2910)
    (go LOOP2903)
    ENDLOOP2904
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2912 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2912 1)))) old2912)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2914 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2914 1)))) old2914)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2915 |c/string/111| v-conflicts-2803))
    (setf v-p-2919 v-buffer-2915)
    LOOP2916
    (unless (c-true (m-s8 v-p-2919)) (go ENDLOOP2917))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2921 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2921 1)))) old2921)))) (m-s8 v-p-2919))))
    (let* ( (old2923 v-p-2919)) (setf v-p-2919 (+ old2923 (* 1 1))) old2923)
    (go LOOP2916)
    ENDLOOP2917
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2925 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2925 1)))) old2925)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2927 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2927 1)))) old2927)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2928 |c/string/111| v-redundant-2804))
    (setf v-p-2932 v-buffer-2928)
    LOOP2929
    (unless (c-true (m-s8 v-p-2932)) (go ENDLOOP2930))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2934 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2934 1)))) old2934)))) (m-s8 v-p-2932))))
    (let* ( (old2936 v-p-2932)) (setf v-p-2932 (+ old2936 (* 1 1))) old2936)
    (go LOOP2929)
    ENDLOOP2930
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2938 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2938 1)))) old2938)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2940 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2940 1)))) old2940)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2941 |c/string/112| v-trail-2805))
    (setf v-p-2945 v-buffer-2941)
    LOOP2942
    (unless (c-true (m-s8 v-p-2945)) (go ENDLOOP2943))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2947 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2947 1)))) old2947)))) (m-s8 v-p-2945))))
    (let* ( (old2949 v-p-2945)) (setf v-p-2945 (+ old2949 (* 1 1))) old2949)
    (go LOOP2942)
    ENDLOOP2943
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2951 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2951 1)))) old2951)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2953 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2953 1)))) old2953)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2954 |c/string/110| v-glue-2806))
    (setf v-p-2958 v-buffer-2954)
    LOOP2955
    (unless (c-true (m-s8 v-p-2958)) (go ENDLOOP2956))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2960 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2960 1)))) old2960)))) (m-s8 v-p-2958))))
    (let* ( (old2962 v-p-2958)) (setf v-p-2958 (+ old2962 (* 1 1))) old2962)
    (go LOOP2955)
    ENDLOOP2956
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2964 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2964 1)))) old2964)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2966 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2966 1)))) old2966)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2967 |c/string/111| v-irredundant-2807))
    (setf v-p-2971 v-buffer-2967)
    LOOP2968
    (unless (c-true (m-s8 v-p-2971)) (go ENDLOOP2969))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2973 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2973 1)))) old2973)))) (m-s8 v-p-2971))))
    (let* ( (old2975 v-p-2971)) (setf v-p-2971 (+ old2975 (* 1 1))) old2975)
    (go LOOP2968)
    ENDLOOP2969
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2977 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2977 1)))) old2977)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2979 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2979 1)))) old2979)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2980 |c/string/111| v-variables-2808))
    (setf v-p-2984 v-buffer-2980)
    LOOP2981
    (unless (c-true (m-s8 v-p-2984)) (go ENDLOOP2982))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2986 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2986 1)))) old2986)))) (m-s8 v-p-2984))))
    (let* ( (old2988 v-p-2984)) (setf v-p-2984 (+ old2988 (* 1 1))) old2988)
    (go LOOP2981)
    ENDLOOP2982
    (progn (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2990 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2990 1)))) old2990)))) (c-s8 32)))
    (progn (setf (m-s32 (+ v-column-2811 (* 4 (let* ( (old2992 v-num_reported-2810)) (setf v-num_reported-2810 (c-s32 (c-s32 (+ old2992 1)))) old2992)))) v-end_line-2813))
    (progn (c-sprintf v-buffer-2993 |c/string/112| v-remaining-2809))
    (setf v-p-2997 v-buffer-2993)
    LOOP2994
    (unless (c-true (m-s8 v-p-2997)) (go ENDLOOP2995))
    (progn (progn 0 (setf (m-s8 (+ v-line-2812 (* 1 (let* ( (old2999 v-end_line-2813)) (setf v-end_line-2813 (c-s32 (c-s32 (+ old2999 1)))) old2999)))) (m-s8 v-p-2997))))
    (let* ( (old3001 v-p-2997)) (setf v-p-2997 (+ old3001 (* 1 1))) old3001)
    (go LOOP2994)
    ENDLOOP2995
    (setf v-colors-3002 (c-bool (c-isatty 1)))
    (setf v-terminal_file-3003 (if (c-true (if (= 1 1) 1 0)) 1 2))
    (progn v-terminal_file-3003)
    (unless (c-true (if (= (c-u64 (rem (m-u64 (+ (+ v-solver-2788 1016) 232)) (c-u64 16))) (c-u64 1)) 1 0)) (go ELSE3004))
    (setf v-i-3011 0)
    LOOP3008
    (unless (c-true (if (< v-i-3011 3) 1 0)) (go ENDLOOP3009))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-i-3011)) (* 1 0))) (c-s8 99)))
    (progn (setf (m-s32 (+ v-end_header-3007 (* 4 v-i-3011))) 1))
    (let* ( (old3013 v-i-3011)) (setf v-i-3011 (c-s32 (c-s32 (+ old3013 1)))) old3013)
    (go LOOP3008)
    ENDLOOP3009
    (setf v-reported-3014 0)
    (setf v-row-3015 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3015)) (* 1 (let* ((a3016 (+ v-end_header-3007 (* 4 v-row-3015))) (old3017 (m-s32 a3016))) (setf (m-s32 a3016) (c-s32 (c-s32 (+ old3017 1)))) old3017)))) (c-s8 32)))
    (setf v-start-3018 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3020 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3020 1)))) old3020)))))
    (setf v-end-3021 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3022 (c-s32 (- (c-s32 (- v-end-3021 v-start-3018)) 1)))
    (setf v-name_width-3023 (c-s32 (c-strlen |c/string/113|)))
    (unless (c-true (if (> v-name_width-3023 v-value_width-3022) 1 0)) (go ELSE3025))
    (progn (setf v-target-3024 (c-s32 (- v-start-3018 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3023 v-value_width-3022)) 1)) 2))))))
    (go ENDIF3026)
    ELSE3025
    (progn (setf v-target-3024 (c-s32 (+ v-start-3018 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3022 v-name_width-3023)) 1)) 2))))))
    ENDIF3026
    LOOP3027
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3015))) v-target-3024) 1 0)) (go ENDLOOP3028))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3015)) (* 1 (let* ((a3030 (+ v-end_header-3007 (* 4 v-row-3015))) (old3031 (m-s32 a3030))) (setf (m-s32 a3030) (c-s32 (c-s32 (+ old3031 1)))) old3031)))) (c-s8 32)))
    (go LOOP3027)
    ENDLOOP3028
    (setf v-p-3035 |c/string/113|)
    LOOP3032
    (unless (c-true (m-s8 v-p-3035)) (go ENDLOOP3033))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3015)) (* 1 (let* ((a3036 (+ v-end_header-3007 (* 4 v-row-3015))) (old3037 (m-s32 a3036))) (setf (m-s32 a3036) (c-s32 (c-s32 (+ old3037 1)))) old3037)))) (m-s8 v-p-3035)))
    (let* ( (old3039 v-p-3035)) (setf v-p-3035 (+ old3039 (* 1 1))) old3039)
    (go LOOP3032)
    ENDLOOP3033
    (setf v-row-3040 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3040)) (* 1 (let* ((a3041 (+ v-end_header-3007 (* 4 v-row-3040))) (old3042 (m-s32 a3041))) (setf (m-s32 a3041) (c-s32 (c-s32 (+ old3042 1)))) old3042)))) (c-s8 32)))
    (setf v-start-3043 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3045 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3045 1)))) old3045)))))
    (setf v-end-3046 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3047 (c-s32 (- (c-s32 (- v-end-3046 v-start-3043)) 1)))
    (setf v-name_width-3048 (c-s32 (c-strlen |c/string/114|)))
    (unless (c-true (if (> v-name_width-3048 v-value_width-3047) 1 0)) (go ELSE3050))
    (progn (setf v-target-3049 (c-s32 (- v-start-3043 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3048 v-value_width-3047)) 1)) 2))))))
    (go ENDIF3051)
    ELSE3050
    (progn (setf v-target-3049 (c-s32 (+ v-start-3043 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3047 v-name_width-3048)) 1)) 2))))))
    ENDIF3051
    LOOP3052
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3040))) v-target-3049) 1 0)) (go ENDLOOP3053))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3040)) (* 1 (let* ((a3055 (+ v-end_header-3007 (* 4 v-row-3040))) (old3056 (m-s32 a3055))) (setf (m-s32 a3055) (c-s32 (c-s32 (+ old3056 1)))) old3056)))) (c-s8 32)))
    (go LOOP3052)
    ENDLOOP3053
    (setf v-p-3060 |c/string/114|)
    LOOP3057
    (unless (c-true (m-s8 v-p-3060)) (go ENDLOOP3058))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3040)) (* 1 (let* ((a3061 (+ v-end_header-3007 (* 4 v-row-3040))) (old3062 (m-s32 a3061))) (setf (m-s32 a3061) (c-s32 (c-s32 (+ old3062 1)))) old3062)))) (m-s8 v-p-3060)))
    (let* ( (old3064 v-p-3060)) (setf v-p-3060 (+ old3064 (* 1 1))) old3064)
    (go LOOP3057)
    ENDLOOP3058
    (setf v-row-3065 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3065)) (* 1 (let* ((a3066 (+ v-end_header-3007 (* 4 v-row-3065))) (old3067 (m-s32 a3066))) (setf (m-s32 a3066) (c-s32 (c-s32 (+ old3067 1)))) old3067)))) (c-s8 32)))
    (setf v-start-3068 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3070 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3070 1)))) old3070)))))
    (setf v-end-3071 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3072 (c-s32 (- (c-s32 (- v-end-3071 v-start-3068)) 1)))
    (setf v-name_width-3073 (c-s32 (c-strlen |c/string/115|)))
    (unless (c-true (if (> v-name_width-3073 v-value_width-3072) 1 0)) (go ELSE3075))
    (progn (setf v-target-3074 (c-s32 (- v-start-3068 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3073 v-value_width-3072)) 1)) 2))))))
    (go ENDIF3076)
    ELSE3075
    (progn (setf v-target-3074 (c-s32 (+ v-start-3068 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3072 v-name_width-3073)) 1)) 2))))))
    ENDIF3076
    LOOP3077
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3065))) v-target-3074) 1 0)) (go ENDLOOP3078))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3065)) (* 1 (let* ((a3080 (+ v-end_header-3007 (* 4 v-row-3065))) (old3081 (m-s32 a3080))) (setf (m-s32 a3080) (c-s32 (c-s32 (+ old3081 1)))) old3081)))) (c-s8 32)))
    (go LOOP3077)
    ENDLOOP3078
    (setf v-p-3085 |c/string/115|)
    LOOP3082
    (unless (c-true (m-s8 v-p-3085)) (go ENDLOOP3083))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3065)) (* 1 (let* ((a3086 (+ v-end_header-3007 (* 4 v-row-3065))) (old3087 (m-s32 a3086))) (setf (m-s32 a3086) (c-s32 (c-s32 (+ old3087 1)))) old3087)))) (m-s8 v-p-3085)))
    (let* ( (old3089 v-p-3085)) (setf v-p-3085 (+ old3089 (* 1 1))) old3089)
    (go LOOP3082)
    ENDLOOP3083
    (setf v-row-3090 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3090)) (* 1 (let* ((a3091 (+ v-end_header-3007 (* 4 v-row-3090))) (old3092 (m-s32 a3091))) (setf (m-s32 a3091) (c-s32 (c-s32 (+ old3092 1)))) old3092)))) (c-s8 32)))
    (setf v-start-3093 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3095 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3095 1)))) old3095)))))
    (setf v-end-3096 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3097 (c-s32 (- (c-s32 (- v-end-3096 v-start-3093)) 1)))
    (setf v-name_width-3098 (c-s32 (c-strlen |c/string/116|)))
    (unless (c-true (if (> v-name_width-3098 v-value_width-3097) 1 0)) (go ELSE3100))
    (progn (setf v-target-3099 (c-s32 (- v-start-3093 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3098 v-value_width-3097)) 1)) 2))))))
    (go ENDIF3101)
    ELSE3100
    (progn (setf v-target-3099 (c-s32 (+ v-start-3093 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3097 v-name_width-3098)) 1)) 2))))))
    ENDIF3101
    LOOP3102
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3090))) v-target-3099) 1 0)) (go ENDLOOP3103))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3090)) (* 1 (let* ((a3105 (+ v-end_header-3007 (* 4 v-row-3090))) (old3106 (m-s32 a3105))) (setf (m-s32 a3105) (c-s32 (c-s32 (+ old3106 1)))) old3106)))) (c-s8 32)))
    (go LOOP3102)
    ENDLOOP3103
    (setf v-p-3110 |c/string/116|)
    LOOP3107
    (unless (c-true (m-s8 v-p-3110)) (go ENDLOOP3108))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3090)) (* 1 (let* ((a3111 (+ v-end_header-3007 (* 4 v-row-3090))) (old3112 (m-s32 a3111))) (setf (m-s32 a3111) (c-s32 (c-s32 (+ old3112 1)))) old3112)))) (m-s8 v-p-3110)))
    (let* ( (old3114 v-p-3110)) (setf v-p-3110 (+ old3114 (* 1 1))) old3114)
    (go LOOP3107)
    ENDLOOP3108
    (setf v-row-3115 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3115)) (* 1 (let* ((a3116 (+ v-end_header-3007 (* 4 v-row-3115))) (old3117 (m-s32 a3116))) (setf (m-s32 a3116) (c-s32 (c-s32 (+ old3117 1)))) old3117)))) (c-s8 32)))
    (setf v-start-3118 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3120 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3120 1)))) old3120)))))
    (setf v-end-3121 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3122 (c-s32 (- (c-s32 (- v-end-3121 v-start-3118)) 1)))
    (setf v-name_width-3123 (c-s32 (c-strlen |c/string/117|)))
    (unless (c-true (if (> v-name_width-3123 v-value_width-3122) 1 0)) (go ELSE3125))
    (progn (setf v-target-3124 (c-s32 (- v-start-3118 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3123 v-value_width-3122)) 1)) 2))))))
    (go ENDIF3126)
    ELSE3125
    (progn (setf v-target-3124 (c-s32 (+ v-start-3118 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3122 v-name_width-3123)) 1)) 2))))))
    ENDIF3126
    LOOP3127
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3115))) v-target-3124) 1 0)) (go ENDLOOP3128))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3115)) (* 1 (let* ((a3130 (+ v-end_header-3007 (* 4 v-row-3115))) (old3131 (m-s32 a3130))) (setf (m-s32 a3130) (c-s32 (c-s32 (+ old3131 1)))) old3131)))) (c-s8 32)))
    (go LOOP3127)
    ENDLOOP3128
    (setf v-p-3135 |c/string/117|)
    LOOP3132
    (unless (c-true (m-s8 v-p-3135)) (go ENDLOOP3133))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3115)) (* 1 (let* ((a3136 (+ v-end_header-3007 (* 4 v-row-3115))) (old3137 (m-s32 a3136))) (setf (m-s32 a3136) (c-s32 (c-s32 (+ old3137 1)))) old3137)))) (m-s8 v-p-3135)))
    (let* ( (old3139 v-p-3135)) (setf v-p-3135 (+ old3139 (* 1 1))) old3139)
    (go LOOP3132)
    ENDLOOP3133
    (setf v-row-3140 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3140)) (* 1 (let* ((a3141 (+ v-end_header-3007 (* 4 v-row-3140))) (old3142 (m-s32 a3141))) (setf (m-s32 a3141) (c-s32 (c-s32 (+ old3142 1)))) old3142)))) (c-s8 32)))
    (setf v-start-3143 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3145 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3145 1)))) old3145)))))
    (setf v-end-3146 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3147 (c-s32 (- (c-s32 (- v-end-3146 v-start-3143)) 1)))
    (setf v-name_width-3148 (c-s32 (c-strlen |c/string/118|)))
    (unless (c-true (if (> v-name_width-3148 v-value_width-3147) 1 0)) (go ELSE3150))
    (progn (setf v-target-3149 (c-s32 (- v-start-3143 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3148 v-value_width-3147)) 1)) 2))))))
    (go ENDIF3151)
    ELSE3150
    (progn (setf v-target-3149 (c-s32 (+ v-start-3143 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3147 v-name_width-3148)) 1)) 2))))))
    ENDIF3151
    LOOP3152
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3140))) v-target-3149) 1 0)) (go ENDLOOP3153))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3140)) (* 1 (let* ((a3155 (+ v-end_header-3007 (* 4 v-row-3140))) (old3156 (m-s32 a3155))) (setf (m-s32 a3155) (c-s32 (c-s32 (+ old3156 1)))) old3156)))) (c-s8 32)))
    (go LOOP3152)
    ENDLOOP3153
    (setf v-p-3160 |c/string/118|)
    LOOP3157
    (unless (c-true (m-s8 v-p-3160)) (go ENDLOOP3158))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3140)) (* 1 (let* ((a3161 (+ v-end_header-3007 (* 4 v-row-3140))) (old3162 (m-s32 a3161))) (setf (m-s32 a3161) (c-s32 (c-s32 (+ old3162 1)))) old3162)))) (m-s8 v-p-3160)))
    (let* ( (old3164 v-p-3160)) (setf v-p-3160 (+ old3164 (* 1 1))) old3164)
    (go LOOP3157)
    ENDLOOP3158
    (setf v-row-3165 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3165)) (* 1 (let* ((a3166 (+ v-end_header-3007 (* 4 v-row-3165))) (old3167 (m-s32 a3166))) (setf (m-s32 a3166) (c-s32 (c-s32 (+ old3167 1)))) old3167)))) (c-s8 32)))
    (setf v-start-3168 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3170 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3170 1)))) old3170)))))
    (setf v-end-3171 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3172 (c-s32 (- (c-s32 (- v-end-3171 v-start-3168)) 1)))
    (setf v-name_width-3173 (c-s32 (c-strlen |c/string/119|)))
    (unless (c-true (if (> v-name_width-3173 v-value_width-3172) 1 0)) (go ELSE3175))
    (progn (setf v-target-3174 (c-s32 (- v-start-3168 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3173 v-value_width-3172)) 1)) 2))))))
    (go ENDIF3176)
    ELSE3175
    (progn (setf v-target-3174 (c-s32 (+ v-start-3168 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3172 v-name_width-3173)) 1)) 2))))))
    ENDIF3176
    LOOP3177
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3165))) v-target-3174) 1 0)) (go ENDLOOP3178))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3165)) (* 1 (let* ((a3180 (+ v-end_header-3007 (* 4 v-row-3165))) (old3181 (m-s32 a3180))) (setf (m-s32 a3180) (c-s32 (c-s32 (+ old3181 1)))) old3181)))) (c-s8 32)))
    (go LOOP3177)
    ENDLOOP3178
    (setf v-p-3185 |c/string/119|)
    LOOP3182
    (unless (c-true (m-s8 v-p-3185)) (go ENDLOOP3183))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3165)) (* 1 (let* ((a3186 (+ v-end_header-3007 (* 4 v-row-3165))) (old3187 (m-s32 a3186))) (setf (m-s32 a3186) (c-s32 (c-s32 (+ old3187 1)))) old3187)))) (m-s8 v-p-3185)))
    (let* ( (old3189 v-p-3185)) (setf v-p-3185 (+ old3189 (* 1 1))) old3189)
    (go LOOP3182)
    ENDLOOP3183
    (setf v-row-3190 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3190)) (* 1 (let* ((a3191 (+ v-end_header-3007 (* 4 v-row-3190))) (old3192 (m-s32 a3191))) (setf (m-s32 a3191) (c-s32 (c-s32 (+ old3192 1)))) old3192)))) (c-s8 32)))
    (setf v-start-3193 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3195 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3195 1)))) old3195)))))
    (setf v-end-3196 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3197 (c-s32 (- (c-s32 (- v-end-3196 v-start-3193)) 1)))
    (setf v-name_width-3198 (c-s32 (c-strlen |c/string/120|)))
    (unless (c-true (if (> v-name_width-3198 v-value_width-3197) 1 0)) (go ELSE3200))
    (progn (setf v-target-3199 (c-s32 (- v-start-3193 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3198 v-value_width-3197)) 1)) 2))))))
    (go ENDIF3201)
    ELSE3200
    (progn (setf v-target-3199 (c-s32 (+ v-start-3193 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3197 v-name_width-3198)) 1)) 2))))))
    ENDIF3201
    LOOP3202
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3190))) v-target-3199) 1 0)) (go ENDLOOP3203))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3190)) (* 1 (let* ((a3205 (+ v-end_header-3007 (* 4 v-row-3190))) (old3206 (m-s32 a3205))) (setf (m-s32 a3205) (c-s32 (c-s32 (+ old3206 1)))) old3206)))) (c-s8 32)))
    (go LOOP3202)
    ENDLOOP3203
    (setf v-p-3210 |c/string/120|)
    LOOP3207
    (unless (c-true (m-s8 v-p-3210)) (go ENDLOOP3208))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3190)) (* 1 (let* ((a3211 (+ v-end_header-3007 (* 4 v-row-3190))) (old3212 (m-s32 a3211))) (setf (m-s32 a3211) (c-s32 (c-s32 (+ old3212 1)))) old3212)))) (m-s8 v-p-3210)))
    (let* ( (old3214 v-p-3210)) (setf v-p-3210 (+ old3214 (* 1 1))) old3214)
    (go LOOP3207)
    ENDLOOP3208
    (setf v-row-3215 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3215)) (* 1 (let* ((a3216 (+ v-end_header-3007 (* 4 v-row-3215))) (old3217 (m-s32 a3216))) (setf (m-s32 a3216) (c-s32 (c-s32 (+ old3217 1)))) old3217)))) (c-s8 32)))
    (setf v-start-3218 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3220 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3220 1)))) old3220)))))
    (setf v-end-3221 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3222 (c-s32 (- (c-s32 (- v-end-3221 v-start-3218)) 1)))
    (setf v-name_width-3223 (c-s32 (c-strlen |c/string/121|)))
    (unless (c-true (if (> v-name_width-3223 v-value_width-3222) 1 0)) (go ELSE3225))
    (progn (setf v-target-3224 (c-s32 (- v-start-3218 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3223 v-value_width-3222)) 1)) 2))))))
    (go ENDIF3226)
    ELSE3225
    (progn (setf v-target-3224 (c-s32 (+ v-start-3218 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3222 v-name_width-3223)) 1)) 2))))))
    ENDIF3226
    LOOP3227
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3215))) v-target-3224) 1 0)) (go ENDLOOP3228))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3215)) (* 1 (let* ((a3230 (+ v-end_header-3007 (* 4 v-row-3215))) (old3231 (m-s32 a3230))) (setf (m-s32 a3230) (c-s32 (c-s32 (+ old3231 1)))) old3231)))) (c-s8 32)))
    (go LOOP3227)
    ENDLOOP3228
    (setf v-p-3235 |c/string/121|)
    LOOP3232
    (unless (c-true (m-s8 v-p-3235)) (go ENDLOOP3233))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3215)) (* 1 (let* ((a3236 (+ v-end_header-3007 (* 4 v-row-3215))) (old3237 (m-s32 a3236))) (setf (m-s32 a3236) (c-s32 (c-s32 (+ old3237 1)))) old3237)))) (m-s8 v-p-3235)))
    (let* ( (old3239 v-p-3235)) (setf v-p-3235 (+ old3239 (* 1 1))) old3239)
    (go LOOP3232)
    ENDLOOP3233
    (setf v-row-3240 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3240)) (* 1 (let* ((a3241 (+ v-end_header-3007 (* 4 v-row-3240))) (old3242 (m-s32 a3241))) (setf (m-s32 a3241) (c-s32 (c-s32 (+ old3242 1)))) old3242)))) (c-s8 32)))
    (setf v-start-3243 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3245 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3245 1)))) old3245)))))
    (setf v-end-3246 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3247 (c-s32 (- (c-s32 (- v-end-3246 v-start-3243)) 1)))
    (setf v-name_width-3248 (c-s32 (c-strlen |c/string/122|)))
    (unless (c-true (if (> v-name_width-3248 v-value_width-3247) 1 0)) (go ELSE3250))
    (progn (setf v-target-3249 (c-s32 (- v-start-3243 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3248 v-value_width-3247)) 1)) 2))))))
    (go ENDIF3251)
    ELSE3250
    (progn (setf v-target-3249 (c-s32 (+ v-start-3243 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3247 v-name_width-3248)) 1)) 2))))))
    ENDIF3251
    LOOP3252
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3240))) v-target-3249) 1 0)) (go ENDLOOP3253))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3240)) (* 1 (let* ((a3255 (+ v-end_header-3007 (* 4 v-row-3240))) (old3256 (m-s32 a3255))) (setf (m-s32 a3255) (c-s32 (c-s32 (+ old3256 1)))) old3256)))) (c-s8 32)))
    (go LOOP3252)
    ENDLOOP3253
    (setf v-p-3260 |c/string/122|)
    LOOP3257
    (unless (c-true (m-s8 v-p-3260)) (go ENDLOOP3258))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3240)) (* 1 (let* ((a3261 (+ v-end_header-3007 (* 4 v-row-3240))) (old3262 (m-s32 a3261))) (setf (m-s32 a3261) (c-s32 (c-s32 (+ old3262 1)))) old3262)))) (m-s8 v-p-3260)))
    (let* ( (old3264 v-p-3260)) (setf v-p-3260 (+ old3264 (* 1 1))) old3264)
    (go LOOP3257)
    ENDLOOP3258
    (setf v-row-3265 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3265)) (* 1 (let* ((a3266 (+ v-end_header-3007 (* 4 v-row-3265))) (old3267 (m-s32 a3266))) (setf (m-s32 a3266) (c-s32 (c-s32 (+ old3267 1)))) old3267)))) (c-s8 32)))
    (setf v-start-3268 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3270 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3270 1)))) old3270)))))
    (setf v-end-3271 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3272 (c-s32 (- (c-s32 (- v-end-3271 v-start-3268)) 1)))
    (setf v-name_width-3273 (c-s32 (c-strlen |c/string/123|)))
    (unless (c-true (if (> v-name_width-3273 v-value_width-3272) 1 0)) (go ELSE3275))
    (progn (setf v-target-3274 (c-s32 (- v-start-3268 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3273 v-value_width-3272)) 1)) 2))))))
    (go ENDIF3276)
    ELSE3275
    (progn (setf v-target-3274 (c-s32 (+ v-start-3268 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3272 v-name_width-3273)) 1)) 2))))))
    ENDIF3276
    LOOP3277
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3265))) v-target-3274) 1 0)) (go ENDLOOP3278))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3265)) (* 1 (let* ((a3280 (+ v-end_header-3007 (* 4 v-row-3265))) (old3281 (m-s32 a3280))) (setf (m-s32 a3280) (c-s32 (c-s32 (+ old3281 1)))) old3281)))) (c-s8 32)))
    (go LOOP3277)
    ENDLOOP3278
    (setf v-p-3285 |c/string/123|)
    LOOP3282
    (unless (c-true (m-s8 v-p-3285)) (go ENDLOOP3283))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3265)) (* 1 (let* ((a3286 (+ v-end_header-3007 (* 4 v-row-3265))) (old3287 (m-s32 a3286))) (setf (m-s32 a3286) (c-s32 (c-s32 (+ old3287 1)))) old3287)))) (m-s8 v-p-3285)))
    (let* ( (old3289 v-p-3285)) (setf v-p-3285 (+ old3289 (* 1 1))) old3289)
    (go LOOP3282)
    ENDLOOP3283
    (setf v-row-3290 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3290)) (* 1 (let* ((a3291 (+ v-end_header-3007 (* 4 v-row-3290))) (old3292 (m-s32 a3291))) (setf (m-s32 a3291) (c-s32 (c-s32 (+ old3292 1)))) old3292)))) (c-s8 32)))
    (setf v-start-3293 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3295 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3295 1)))) old3295)))))
    (setf v-end-3296 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3297 (c-s32 (- (c-s32 (- v-end-3296 v-start-3293)) 1)))
    (setf v-name_width-3298 (c-s32 (c-strlen |c/string/124|)))
    (unless (c-true (if (> v-name_width-3298 v-value_width-3297) 1 0)) (go ELSE3300))
    (progn (setf v-target-3299 (c-s32 (- v-start-3293 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3298 v-value_width-3297)) 1)) 2))))))
    (go ENDIF3301)
    ELSE3300
    (progn (setf v-target-3299 (c-s32 (+ v-start-3293 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3297 v-name_width-3298)) 1)) 2))))))
    ENDIF3301
    LOOP3302
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3290))) v-target-3299) 1 0)) (go ENDLOOP3303))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3290)) (* 1 (let* ((a3305 (+ v-end_header-3007 (* 4 v-row-3290))) (old3306 (m-s32 a3305))) (setf (m-s32 a3305) (c-s32 (c-s32 (+ old3306 1)))) old3306)))) (c-s8 32)))
    (go LOOP3302)
    ENDLOOP3303
    (setf v-p-3310 |c/string/124|)
    LOOP3307
    (unless (c-true (m-s8 v-p-3310)) (go ENDLOOP3308))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3290)) (* 1 (let* ((a3311 (+ v-end_header-3007 (* 4 v-row-3290))) (old3312 (m-s32 a3311))) (setf (m-s32 a3311) (c-s32 (c-s32 (+ old3312 1)))) old3312)))) (m-s8 v-p-3310)))
    (let* ( (old3314 v-p-3310)) (setf v-p-3310 (+ old3314 (* 1 1))) old3314)
    (go LOOP3307)
    ENDLOOP3308
    (setf v-row-3315 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3315)) (* 1 (let* ((a3316 (+ v-end_header-3007 (* 4 v-row-3315))) (old3317 (m-s32 a3316))) (setf (m-s32 a3316) (c-s32 (c-s32 (+ old3317 1)))) old3317)))) (c-s8 32)))
    (setf v-start-3318 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3320 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3320 1)))) old3320)))))
    (setf v-end-3321 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3322 (c-s32 (- (c-s32 (- v-end-3321 v-start-3318)) 1)))
    (setf v-name_width-3323 (c-s32 (c-strlen |c/string/125|)))
    (unless (c-true (if (> v-name_width-3323 v-value_width-3322) 1 0)) (go ELSE3325))
    (progn (setf v-target-3324 (c-s32 (- v-start-3318 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3323 v-value_width-3322)) 1)) 2))))))
    (go ENDIF3326)
    ELSE3325
    (progn (setf v-target-3324 (c-s32 (+ v-start-3318 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3322 v-name_width-3323)) 1)) 2))))))
    ENDIF3326
    LOOP3327
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3315))) v-target-3324) 1 0)) (go ENDLOOP3328))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3315)) (* 1 (let* ((a3330 (+ v-end_header-3007 (* 4 v-row-3315))) (old3331 (m-s32 a3330))) (setf (m-s32 a3330) (c-s32 (c-s32 (+ old3331 1)))) old3331)))) (c-s8 32)))
    (go LOOP3327)
    ENDLOOP3328
    (setf v-p-3335 |c/string/125|)
    LOOP3332
    (unless (c-true (m-s8 v-p-3335)) (go ENDLOOP3333))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3315)) (* 1 (let* ((a3336 (+ v-end_header-3007 (* 4 v-row-3315))) (old3337 (m-s32 a3336))) (setf (m-s32 a3336) (c-s32 (c-s32 (+ old3337 1)))) old3337)))) (m-s8 v-p-3335)))
    (let* ( (old3339 v-p-3335)) (setf v-p-3335 (+ old3339 (* 1 1))) old3339)
    (go LOOP3332)
    ENDLOOP3333
    (setf v-row-3340 (c-s32 (rem v-reported-3014 3)))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3340)) (* 1 (let* ((a3341 (+ v-end_header-3007 (* 4 v-row-3340))) (old3342 (m-s32 a3341))) (setf (m-s32 a3341) (c-s32 (c-s32 (+ old3342 1)))) old3342)))) (c-s8 32)))
    (setf v-start-3343 (m-s32 (+ v-column-2811 (* 4 (let* ( (old3345 v-reported-3014)) (setf v-reported-3014 (c-s32 (c-s32 (+ old3345 1)))) old3345)))))
    (setf v-end-3346 (if (c-true (if (= v-reported-3014 v-num_reported-2810) 1 0)) v-end_line-2813 (m-s32 (+ v-column-2811 (* 4 v-reported-3014)))))
    (setf v-value_width-3347 (c-s32 (- (c-s32 (- v-end-3346 v-start-3343)) 1)))
    (setf v-name_width-3348 (c-s32 (c-strlen |c/string/126|)))
    (unless (c-true (if (> v-name_width-3348 v-value_width-3347) 1 0)) (go ELSE3350))
    (progn (setf v-target-3349 (c-s32 (- v-start-3343 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-name_width-3348 v-value_width-3347)) 1)) 2))))))
    (go ENDIF3351)
    ELSE3350
    (progn (setf v-target-3349 (c-s32 (+ v-start-3343 (c-s32 (truncate (c-s32 (+ (c-s32 (- v-value_width-3347 v-name_width-3348)) 1)) 2))))))
    ENDIF3351
    LOOP3352
    (unless (c-true (if (< (m-s32 (+ v-end_header-3007 (* 4 v-row-3340))) v-target-3349) 1 0)) (go ENDLOOP3353))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3340)) (* 1 (let* ((a3355 (+ v-end_header-3007 (* 4 v-row-3340))) (old3356 (m-s32 a3355))) (setf (m-s32 a3355) (c-s32 (c-s32 (+ old3356 1)))) old3356)))) (c-s8 32)))
    (go LOOP3352)
    ENDLOOP3353
    (setf v-p-3360 |c/string/126|)
    LOOP3357
    (unless (c-true (m-s8 v-p-3360)) (go ENDLOOP3358))
    (progn (setf (m-s8 (+ (+ v-header-3006 (* 256 v-row-3340)) (* 1 (let* ((a3361 (+ v-end_header-3007 (* 4 v-row-3340))) (old3362 (m-s32 a3361))) (setf (m-s32 a3361) (c-s32 (c-s32 (+ old3362 1)))) old3362)))) (m-s8 v-p-3360)))
    (let* ( (old3364 v-p-3360)) (setf v-p-3360 (+ old3364 (* 1 1))) old3364)
    (go LOOP3357)
    ENDLOOP3358
    (progn (c-fputs |c/string/8| 1))
    (setf v-i-3368 0)
    LOOP3365
    (unless (c-true (if (< v-i-3368 3) 1 0)) (go ENDLOOP3366))
    (progn (c-fputc 99 1))
    (unless (c-true v-colors-3002) (go ELSE3372))
    (progn (c-fputs |c/string/127| v-terminal_file-3003))
    (go ENDIF3373)
    ELSE3372
    ENDIF3373
    (setf v-j-3377 1)
    LOOP3374
    (unless (c-true (if (< v-j-3377 (m-s32 (+ v-end_header-3007 (* 4 v-i-3368)))) 1 0)) (go ENDLOOP3375))
    (progn (c-fputc (m-s8 (+ (+ v-header-3006 (* 256 v-i-3368)) (* 1 v-j-3377))) 1))
    (let* ( (old3379 v-j-3377)) (setf v-j-3377 (c-s32 (c-s32 (+ old3379 1)))) old3379)
    (go LOOP3374)
    ENDLOOP3375
    (unless (c-true v-colors-3002) (go ELSE3383))
    (progn (c-fputs |c/string/4| v-terminal_file-3003))
    (go ENDIF3384)
    ELSE3383
    ENDIF3384
    (progn (c-fputc 10 1))
    (let* ( (old3386 v-i-3368)) (setf v-i-3368 (c-s32 (c-s32 (+ old3386 1)))) old3386)
    (go LOOP3365)
    ENDLOOP3366
    (progn (c-fputs |c/string/8| 1))
    (go ENDIF3005)
    ELSE3004
    ENDIF3005
    (progn (c-fputs |c/string/6| 1))
    (setf v-reset-3387 (c-bool 0))
    (unless (c-true v-colors-3002) (go ELSE3388))
    (setf v-magenta-3390 (c-bool 0))
    (setf switch3392 v-type-2790)
    (when (= switch3392 48) (go CASE3393))
    (when (= switch3392 49) (go CASE3394))
    (when (= switch3392 63) (go CASE3395))
    (when (= switch3392 105) (go CASE3396))
    (when (= switch3392 115) (go CASE3397))
    (when (= switch3392 101) (go CASE3398))
    (when (= switch3392 91) (go CASE3399))
    (when (= switch3392 93) (go CASE3400))
    (go ENDSWITCH3391)
    CASE3393
    CASE3394
    CASE3395
    CASE3396
    (progn (c-fputs |c/string/1| 1))
    (progn (setf v-reset-3387 (c-bool 1)))
    (go ENDSWITCH3391)
    CASE3397
    (progn (c-fputs |c/string/128| 1))
    (progn (setf v-reset-3387 (c-bool 1)))
    (go ENDSWITCH3391)
    CASE3398
    (progn (c-fputs |c/string/129| 1))
    (progn (setf v-reset-3387 (c-bool 1)))
    (go ENDSWITCH3391)
    CASE3399
    CASE3400
    (progn (c-fputs |c/string/130| 1))
    (progn (setf v-magenta-3390 (c-bool 1)))
    ENDSWITCH3391
    (progn (c-fputc (m-s8 (+ v-line-2812 (* 1 2))) 1))
    (unless (c-true v-reset-3387) (go ELSE3401))
    (progn (c-fputs |c/string/4| 1))
    (go ENDIF3402)
    ELSE3401
    ENDIF3402
    (unless (c-true v-magenta-3390) (go ELSE3403))
    (progn (setf v-reset-3387 (c-bool 1)))
    (go ENDIF3404)
    ELSE3403
    (unless (c-true (m-u8 (+ v-solver-2788 6))) (go ELSE3405))
    (progn (c-fputs |c/string/130| 1))
    (progn (setf v-reset-3387 (c-bool 1)))
    (go ENDIF3406)
    ELSE3405
    ENDIF3406
    ENDIF3404
    (go ENDIF3389)
    ELSE3388
    (progn (c-fputc (m-s8 (+ v-line-2812 (* 1 2))) 1))
    ENDIF3389
    (setf v-i-3410 3)
    LOOP3407
    (unless (c-true (if (< v-i-3410 v-end_line-2813) 1 0)) (go ENDLOOP3408))
    (progn (c-fputc (m-s8 (+ v-line-2812 (* 1 v-i-3410))) 1))
    (let* ( (old3412 v-i-3410)) (setf v-i-3410 (c-s32 (c-s32 (+ old3412 1)))) old3412)
    (go LOOP3407)
    ENDLOOP3408
    (unless (c-true v-reset-3387) (go ELSE3413))
    (progn (c-fputs |c/string/4| 1))
    (go ENDIF3414)
    ELSE3413
    ENDIF3414
    (progn (c-fputc 10 1))
    (progn (c-fflush 1))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:6916:1
(defun |c/iterate| (arg-v-solver-3415)
 (declare  (type c-address arg-v-solver-3415))
 (let ((v-solver-3415 0))
 (declare (type c-address v-solver-3415) (ignorable v-solver-3415))
 (tagbody
    (setf v-solver-3415 arg-v-solver-3415)
    (progn (|c/report| v-solver-3415 (c-u32 1) 105))
    (progn (setf (m-u8 (+ v-solver-3415 5)) (c-bool 0)))
  )
  0))

;;; upstream/satch.c:6929:1
(defun |c/logn| (arg-v-n-3416)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3416))
 (let ((v-n-3416 0) (v-res-3417 0d0))
 (declare (type (unsigned-byte 64) v-n-3416) (type double-float v-res-3417) (ignorable v-n-3416 v-res-3417))
 (tagbody
    (setf v-n-3416 arg-v-n-3416)
    (setf v-res-3417 (c-log10 (integer64-double (c-u64 (+ v-n-3416 (c-u64 9))) nil)))
    (return-from |c/logn| v-res-3417)
  )
  0))

;;; upstream/satch.c:6942:1
(defun |c/nlognlogn| (arg-v-n-3418)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3418))
 (let ((v-n-3418 0) (v-tmp-3419 0d0) (v-res-3420 0d0))
 (declare (type (unsigned-byte 64) v-n-3418) (type double-float v-tmp-3419) (type double-float v-res-3420) (ignorable v-n-3418 v-tmp-3419 v-res-3420))
 (tagbody
    (setf v-n-3418 arg-v-n-3418)
    (setf v-tmp-3419 (c-log10 (integer64-double (c-u64 (+ v-n-3418 (c-u64 9))) nil)))
    (setf v-res-3420 (float (* (float (* (integer64-double v-n-3418 nil) v-tmp-3419) 1d0) v-tmp-3419) 1d0))
    (return-from |c/nlognlogn| v-res-3420)
  )
  0))

;;; upstream/satch.c:6955:1
(defun |c/nlogn| (arg-v-n-3421)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3421))
 (let ((v-n-3421 0) (v-tmp-3422 0d0) (v-res-3423 0d0))
 (declare (type (unsigned-byte 64) v-n-3421) (type double-float v-tmp-3422) (type double-float v-res-3423) (ignorable v-n-3421 v-tmp-3422 v-res-3423))
 (tagbody
    (setf v-n-3421 arg-v-n-3421)
    (setf v-tmp-3422 (c-log10 (integer64-double (c-u64 (+ v-n-3421 (c-u64 9))) nil)))
    (setf v-res-3423 (float (* (integer64-double v-n-3421 nil) v-tmp-3422) 1d0))
    (return-from |c/nlogn| v-res-3423)
  )
  0))

;;; upstream/satch.c:6970:1
(defun |c/nlognlognlogn| (arg-v-n-3424)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3424))
 (let ((v-n-3424 0) (v-tmp-3425 0d0) (v-res-3426 0d0))
 (declare (type (unsigned-byte 64) v-n-3424) (type double-float v-tmp-3425) (type double-float v-res-3426) (ignorable v-n-3424 v-tmp-3425 v-res-3426))
 (tagbody
    (setf v-n-3424 arg-v-n-3424)
    (setf v-tmp-3425 (c-log10 (integer64-double (c-u64 (+ v-n-3424 (c-u64 9))) nil)))
    (setf v-res-3426 (float (* (float (* (float (* (integer64-double v-n-3424 nil) v-tmp-3425) 1d0) v-tmp-3425) 1d0) v-tmp-3425) 1d0))
    (return-from |c/nlognlognlogn| v-res-3426)
  )
  0))

;;; upstream/satch.c:6985:1
(defun |c/ndivlogn| (arg-v-n-3427)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3427))
 (let ((v-n-3427 0) (v-div-3428 0d0) (v-res-3429 0d0))
 (declare (type (unsigned-byte 64) v-n-3427) (type double-float v-div-3428) (type double-float v-res-3429) (ignorable v-n-3427 v-div-3428 v-res-3429))
 (tagbody
    (setf v-n-3427 arg-v-n-3427)
    (setf v-div-3428 (c-log10 (integer64-double (c-u64 (+ v-n-3427 (c-u64 9))) nil)))
    (setf v-res-3429 (float (/ (integer64-double v-n-3427 nil) v-div-3428) 1d0))
    (return-from |c/ndivlogn| v-res-3429)
  )
  0))

;;; upstream/satch.c:7000:1
(defun |c/quadratic| (arg-v-n-3430)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-n-3430))
 (let ((v-n-3430 0) (v-res-3431 0d0))
 (declare (type (unsigned-byte 64) v-n-3430) (type double-float v-res-3431) (ignorable v-n-3430 v-res-3431))
 (tagbody
    (setf v-n-3430 arg-v-n-3430)
    (setf v-res-3431 (integer64-double (c-u64 (* v-n-3430 v-n-3430)) nil))
    (return-from |c/quadratic| v-res-3431)
  )
  0))

;;; upstream/satch.c:7030:1
(defun |c/scale_interval| (arg-v-base-3432 arg-v-scale-3433 arg-v-count-3434)
 (declare (optimize (speed 1) (safety 1)) (type (unsigned-byte 64) arg-v-base-3432) (type c-address arg-v-scale-3433) (type (unsigned-byte 64) arg-v-count-3434))
 (let ((v-base-3432 0) (v-scale-3433 0) (v-count-3434 0) (v-scaling-3435 0d0) (v-res-3436 0d0))
 (declare (type (unsigned-byte 64) v-base-3432) (type c-address v-scale-3433) (type (unsigned-byte 64) v-count-3434) (type double-float v-scaling-3435) (type double-float v-res-3436) (ignorable v-base-3432 v-scale-3433 v-count-3434 v-scaling-3435 v-res-3436))
 (tagbody
    (setf v-base-3432 arg-v-base-3432)
    (setf v-scale-3433 arg-v-scale-3433)
    (setf v-count-3434 arg-v-count-3434)
    (setf v-scaling-3435 (funcall (the (function ((unsigned-byte 64)) (values double-float &optional)) (function-from-handle v-scale-3433)) v-count-3434))
    (setf v-res-3436 (float (* (integer64-double v-base-3432 nil) v-scaling-3435) 1d0))
    (return-from |c/scale_interval| v-res-3436)
  )
  0))

;;; upstream/satch.c:7059:1
(defun |c/reuse_stamped_trail| (arg-v-solver-3437)
 (declare  (type c-address arg-v-solver-3437))
 (let ((v-solver-3437 0))
 (declare (type c-address v-solver-3437) (ignorable v-solver-3437))
 (tagbody
    (setf v-solver-3437 arg-v-solver-3437)
    (return-from |c/reuse_stamped_trail| (|c/reuse_stamped_trail_from| v-solver-3437 (c-u32 1)))
  )
  0))


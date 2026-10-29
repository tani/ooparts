(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:4179:1
(defun |c/import_literal| (arg-v-solver-1383 arg-v-elit-1384)
 (declare  (type c-address arg-v-solver-1383) (type (signed-byte 32) arg-v-elit-1384))
 (let ((v-solver-1383 0) (v-elit-1384 0) (v-eidx-1385 0) (v-iidx-1386 0) (v-ilit-1389 0))
 (declare (type c-address v-solver-1383) (type (signed-byte 32) v-elit-1384) (type (signed-byte 32) v-eidx-1385) (type (unsigned-byte 32) v-iidx-1386) (type (unsigned-byte 32) v-ilit-1389) (ignorable v-solver-1383 v-elit-1384 v-eidx-1385 v-iidx-1386 v-ilit-1389))
 (tagbody
    (setf v-solver-1383 arg-v-solver-1383)
    (setf v-elit-1384 arg-v-elit-1384)
    (setf v-eidx-1385 (c-abs v-elit-1384))
    (setf v-iidx-1386 (c-u32 (c-s32 (- v-eidx-1385 1))))
    (unless (c-true (if (>= v-iidx-1386 (m-u32 (+ v-solver-1383 12))) 1 0)) (go ELSE1387))
    (progn (|c/increase_size| v-solver-1383 (c-u32 (+ v-iidx-1386 (c-u32 1)))))
    (go ENDIF1388)
    ELSE1387
    ENDIF1388
    (setf v-ilit-1389 (|c/LITERAL| v-iidx-1386))
    (unless (c-true (if (< v-elit-1384 0) 1 0)) (go ELSE1390))
    (progn (setf v-ilit-1389 (|c/NOT| v-ilit-1389)))
    (go ENDIF1391)
    ELSE1390
    ENDIF1391
    (progn v-solver-1383)
    (return-from |c/import_literal| v-ilit-1389)
  )
  0))

;;; upstream/satch.c:4213:1
(defun |c/cache_lines| (arg-v-begin-1395 arg-v-end-1396)
 (declare  (type c-address arg-v-begin-1395) (type c-address arg-v-end-1396))
 (let ((v-begin-1395 0) (v-end-1396 0) (v-round-1397 0) (v-bytes-1398 0) (v-res-1399 0))
 (declare (type c-address v-begin-1395) (type c-address v-end-1396) (type c-size v-round-1397) (type c-size v-bytes-1398) (type c-size v-res-1399) (ignorable v-begin-1395 v-end-1396 v-round-1397 v-bytes-1398 v-res-1399))
 (tagbody
    (setf v-begin-1395 arg-v-begin-1395)
    (setf v-end-1396 arg-v-end-1396)
    (setf v-round-1397 (c-u32 (- (c-u32 (ash (c-u32 1) 7)) (c-u32 1))))
    (setf v-bytes-1398 (c-u64 (truncate (- v-end-1396 v-begin-1395) 1)))
    (setf v-res-1399 (c-u64 (ash (c-u64 (c-u64 (+ v-bytes-1398 v-round-1397))) (- 7))))
    (return-from |c/cache_lines| v-res-1399)
  )
  0))

;;; upstream/satch.c:4239:1
(defun |c/propagate_literal| (arg-v-solver-1400 arg-v-lit-1401 arg-v-ignore-1402 arg-v-ticking-1403)
 (declare (optimize (speed 3)) (type c-address arg-v-solver-1400) (type (unsigned-byte 32) arg-v-lit-1401) (type c-address arg-v-ignore-1402) (type c-address arg-v-ticking-1403))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-1400 0) (v-lit-1401 0) (v-ignore-1402 0) (v-ticking-1403 0) (v-not_lit-1407 0) (v-watches-1408 0) (v-values-1409 0) (v-q-1412 0) (v-p-1413 0) (v-conflict-1414 0) (v-end_watches-1415 0) (v-ticks-1416 0) (v-watch-1420 (stack-alloc 8)) (v-header-1425 (stack-alloc 8)) (v-blocking_lit-1426 0) (v-blocking_value-1427 0) (v-clause-1439 0) (v-literals-1453 0) (v-other-1456 0) (v-other_value-1457 0) (v-size-1460 0) (v-end_literals-1461 0) (v-replacement-1462 0) (v-replacement_value-1463 0) (v-end_search-1464 0) (v-start_search-1465 0) (v-r-1466 0) (v-redundant-1492 0))
 (declare (type c-address v-solver-1400) (type (unsigned-byte 32) v-lit-1401) (type c-address v-ignore-1402) (type c-address v-ticking-1403) (type (unsigned-byte 32) v-not_lit-1407) (type c-address v-watches-1408) (type c-address v-values-1409) (type c-address v-q-1412) (type c-address v-p-1413) (type c-address v-conflict-1414) (type c-address v-end_watches-1415) (type (unsigned-byte 64) v-ticks-1416) (type c-address v-watch-1420) (type c-address v-header-1425) (type (unsigned-byte 32) v-blocking_lit-1426) (type (signed-byte 8) v-blocking_value-1427) (type c-address v-clause-1439) (type c-address v-literals-1453) (type (unsigned-byte 32) v-other-1456) (type (signed-byte 8) v-other_value-1457) (type (unsigned-byte 32) v-size-1460) (type c-address v-end_literals-1461) (type (unsigned-byte 32) v-replacement-1462) (type (signed-byte 8) v-replacement_value-1463) (type c-address v-end_search-1464) (type c-address v-start_search-1465) (type c-address v-r-1466) (type (integer 0 1) v-redundant-1492) (ignorable v-solver-1400 v-lit-1401 v-ignore-1402 v-ticking-1403 v-not_lit-1407 v-watches-1408 v-values-1409 v-q-1412 v-p-1413 v-conflict-1414 v-end_watches-1415 v-ticks-1416 v-watch-1420 v-header-1425 v-blocking_lit-1426 v-blocking_value-1427 v-clause-1439 v-literals-1453 v-other-1456 v-other_value-1457 v-size-1460 v-end_literals-1461 v-replacement-1462 v-replacement_value-1463 v-end_search-1464 v-start_search-1465 v-r-1466 v-redundant-1492))
 (tagbody
    (setf v-solver-1400 arg-v-solver-1400)
    (setf v-lit-1401 arg-v-lit-1401)
    (setf v-ignore-1402 arg-v-ignore-1402)
    (setf v-ticking-1403 arg-v-ticking-1403)
    (progn v-solver-1400)
    (setf v-not_lit-1407 (|c/NOT| v-lit-1401))
    (setf v-watches-1408 (+ (m-ptr (+ v-solver-1400 544)) (* 24 v-not_lit-1407)))
    (setf v-values-1409 (m-ptr (+ v-solver-1400 40)))
    (unless (c-true (if (c-true (m-u8 (+ v-solver-1400 1984))) 0 1)) (go ELSE1410))
    (go ENDIF1411)
    ELSE1410
    ENDIF1411
    (setf v-q-1412 (m-ptr (+ v-watches-1408 0)))
    (setf v-p-1413 v-q-1412)
    (setf v-conflict-1414 0)
    (setf v-end_watches-1415 (m-ptr (+ v-watches-1408 8)))
    (locally (declare (optimize (speed 1))) (setf v-ticks-1416 (c-u64 (+ (c-u64 1) (|c/cache_lines| v-q-1412 v-end_watches-1415)))))
    LOOP1417
    (unless (c-true (if (c-true (if (c-true v-conflict-1414) 0 1)) (c-bool (if (/= v-p-1413 v-end_watches-1415) 1 0)) 0)) (go ENDLOOP1418))
    (copy-bytes v-watch-1420 (copy-bytes (let* ( (old1422 v-q-1412)) (setf v-q-1412 (+ old1422 (* 8 1))) old1422) (let* ( (old1424 v-p-1413)) (setf v-p-1413 (+ old1424 (* 8 1))) old1424) 8) 8)
    (copy-bytes v-header-1425 (+ v-watch-1420 0) 8)
    (setf v-blocking_lit-1426 (m-u32 (+ v-header-1425 4)))
    (setf v-blocking_value-1427 (m-s8 (+ v-values-1409 (* 1 v-blocking_lit-1426))))
    (unless (c-true (m-u8 (+ v-header-1425 0))) (go ELSE1428))
    (unless (c-true (if (< v-blocking_value-1427 0) 1 0)) (go ELSE1430))
    (progn (setf v-conflict-1414 (|c/binary_clause| v-solver-1400 (c-u32 0) (c-bool (m-u8 (+ v-header-1425 1))) v-not_lit-1407 v-blocking_lit-1426)))
    (progn v-solver-1400)
    (go ENDIF1431)
    ELSE1430
    (unless (c-true (if (c-true v-blocking_value-1427) 0 1)) (go ELSE1435))
    (progn (|c/assign| v-solver-1400 v-blocking_lit-1426 (|c/tag_binary_clause| (c-bool (m-u8 (+ v-header-1425 1))) v-not_lit-1407) (c-bool 0)))
    (progn (let* ( (old1438 v-ticks-1416)) (setf v-ticks-1416 (c-u64 (c-u64 (+ old1438 (c-u64 1))))) old1438))
    (go ENDIF1436)
    ELSE1435
    ENDIF1436
    ENDIF1431
    (go CONTINUE1419)
    ELSE1428
    (setf v-clause-1439 (m-ptr (+ (copy-bytes (let* ( (old1441 v-q-1412)) (setf v-q-1412 (+ old1441 (* 8 1))) old1441) (let* ( (old1443 v-p-1413)) (setf v-p-1413 (+ old1443 (* 8 1))) old1443) 8) 0)))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-clause-1439 0)))) (go ELSE1444))
    (progn v-solver-1400)
    (go ENDIF1445)
    ELSE1444
    ENDIF1445
    (unless (c-true (if (= v-clause-1439 v-ignore-1402) 1 0)) (go ELSE1449))
    (go CONTINUE1419)
    ELSE1449
    (unless (c-true (if (> v-blocking_value-1427 0) 1 0)) (go ELSE1451))
    (go CONTINUE1419)
    ELSE1451
    (setf v-literals-1453 (+ v-clause-1439 16))
    (progn (let* ( (old1455 v-ticks-1416)) (setf v-ticks-1416 (c-u64 (c-u64 (+ old1455 (c-u64 1))))) old1455))
    (setf v-other-1456 (c-u32 (logxor (c-u32 (logxor (m-u32 (+ v-literals-1453 (* 4 0))) (m-u32 (+ v-literals-1453 (* 4 1))))) v-not_lit-1407)))
    (setf v-other_value-1457 (m-s8 (+ v-values-1409 (* 1 v-other-1456))))
    (unless (c-true (if (> v-other_value-1457 0) 1 0)) (go ELSE1458))
    (progn (setf (m-u32 (+ (+ (+ v-q-1412 (* 8 (c-s32 (- 2)))) 0) 4)) v-other-1456))
    (go CONTINUE1419)
    ELSE1458
    (progn (setf (m-u32 (+ v-literals-1453 (* 4 0))) v-other-1456))
    (progn (setf (m-u32 (+ v-literals-1453 (* 4 1))) v-not_lit-1407))
    (setf v-size-1460 (m-u32 (+ v-clause-1439 12)))
    (setf v-end_literals-1461 (+ v-literals-1453 (* 4 v-size-1460)))
    (setf v-replacement-1462 4294967295)
    (setf v-replacement_value-1463 (c-s8 (c-s32 (- 1))))
    (setf v-end_search-1464 v-end_literals-1461)
    (setf v-start_search-1465 (+ v-literals-1453 (* 4 2)))
    (progn (setf v-start_search-1465 (+ v-start_search-1465 (* 4 (m-u32 (+ v-clause-1439 8))))))
    (progn (setf v-r-1466 v-start_search-1465))
    LOOP1468
    (unless (c-true (if (/= v-r-1466 v-end_search-1464) 1 0)) (go ENDLOOP1469))
    (progn (setf v-replacement-1462 (m-u32 v-r-1466)))
    (progn (setf v-replacement_value-1463 (m-s8 (+ v-values-1409 (* 1 v-replacement-1462)))))
    (unless (c-true (if (>= v-replacement_value-1463 0) 1 0)) (go ELSE1471))
    (go ENDLOOP1469)
    ELSE1471
    (let* ( (old1474 v-r-1466)) (setf v-r-1466 (+ old1474 (* 4 1))) old1474)
    (go LOOP1468)
    ENDLOOP1469
    (unless (c-true (if (< v-replacement_value-1463 0) 1 0)) (go ELSE1475))
    (progn (setf v-end_search-1464 v-start_search-1465))
    (progn (setf v-start_search-1465 (+ v-literals-1453 (* 4 2))))
    (progn (setf v-r-1466 v-start_search-1465))
    LOOP1477
    (unless (c-true (if (/= v-r-1466 v-end_search-1464) 1 0)) (go ENDLOOP1478))
    (progn (setf v-replacement-1462 (m-u32 v-r-1466)))
    (progn (setf v-replacement_value-1463 (m-s8 (+ v-values-1409 (* 1 v-replacement-1462)))))
    (unless (c-true (if (>= v-replacement_value-1463 0) 1 0)) (go ELSE1480))
    (progn (setf (m-u32 (+ v-clause-1439 8)) (c-u32 (truncate (- v-r-1466 v-start_search-1465) 4))))
    (go ENDLOOP1478)
    ELSE1480
    (let* ( (old1483 v-r-1466)) (setf v-r-1466 (+ old1483 (* 4 1))) old1483)
    (go LOOP1477)
    ENDLOOP1478
    (go ENDIF1476)
    ELSE1475
    (progn (setf (m-u32 (+ v-clause-1439 8)) (c-u32 (truncate (- v-r-1466 v-start_search-1465) 4))))
    ENDIF1476
    (unless (c-true (if (> v-replacement_value-1463 0) 1 0)) (go ELSE1484))
    (progn (setf (m-u32 (+ (+ (+ v-q-1412 (* 8 (c-s32 (- 2)))) 0) 4)) v-replacement-1462))
    (go ENDIF1485)
    ELSE1484
    (unless (c-true (if (c-true v-replacement_value-1463) 0 1)) (go ELSE1486))
    (progn v-solver-1400)
    (progn (setf v-q-1412 (- v-q-1412 (* 8 2))))
    (progn (setf (m-u32 (+ v-literals-1453 (* 4 1))) v-replacement-1462))
    (progn (setf (m-u32 v-r-1466) v-not_lit-1407))
    (setf v-redundant-1492 (c-bool (ldb (byte 1 2) (m-u8 (+ v-clause-1439 0)))))
    (progn (|c/watch_literal| v-solver-1400 (c-bool v-redundant-1492) v-replacement-1462 v-other-1456 v-clause-1439))
    (progn (let* ( (old1494 v-ticks-1416)) (setf v-ticks-1416 (c-u64 (c-u64 (+ old1494 (c-u64 1))))) old1494))
    (go ENDIF1487)
    ELSE1486
    (unless (c-true v-other_value-1457) (go ELSE1495))
    (progn v-solver-1400)
    (progn (setf v-conflict-1414 v-clause-1439))
    (go ENDIF1496)
    ELSE1495
    (progn (|c/assign| v-solver-1400 v-other-1456 v-clause-1439 (c-bool 0)))
    (progn (let* ( (old1501 v-ticks-1416)) (setf v-ticks-1416 (c-u64 (c-u64 (+ old1501 (c-u64 1))))) old1501))
    ENDIF1496
    ENDIF1487
    ENDIF1485
    CONTINUE1419
    (go LOOP1417)
    ENDLOOP1418
    (progn (let ((a1502 v-ticking-1403)) (setf (m-u64 a1502) (c-u64 (c-u64 (+ (m-u64 a1502) v-ticks-1416))))))
    LOOP1503
    (unless (c-true (if (/= v-p-1413 v-end_watches-1415) 1 0)) (go ENDLOOP1504))
    (progn (copy-bytes (let* ( (old1507 v-q-1412)) (setf v-q-1412 (+ old1507 (* 8 1))) old1507) (let* ( (old1509 v-p-1413)) (setf v-p-1413 (+ old1509 (* 8 1))) old1509) 8))
    (go LOOP1503)
    ENDLOOP1504
    (progn (setf (m-ptr (+ v-watches-1408 8)) v-q-1412))
    (return-from |c/propagate_literal| v-conflict-1414)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:4597:1
(defun |c/flush_units| (arg-v-solver-1510)
 (declare  (type c-address arg-v-solver-1510))
 (let ((v-solver-1510 0) (v-trail-1511 0) (v-new_start-1512 0) (v-delta-1518 0) (v-lit-1523 0) (v-lvl-1534 0))
 (declare (type c-address v-solver-1510) (type c-address v-trail-1511) (type c-address v-new_start-1512) (type (signed-byte 64) v-delta-1518) (type c-address v-lit-1523) (type c-address v-lvl-1534) (ignorable v-solver-1510 v-trail-1511 v-new_start-1512 v-delta-1518 v-lit-1523 v-lvl-1534))
 (tagbody
    (setf v-solver-1510 arg-v-solver-1510)
    (setf v-trail-1511 (+ v-solver-1510 552))
    (setf v-new_start-1512 (m-ptr (+ v-trail-1511 0)))
    LOOP1513
    (unless (c-true (if (c-true (if (< v-new_start-1512 (m-ptr (+ v-trail-1511 8))) 1 0)) (c-bool (if (c-true (m-u32 (+ (m-ptr (+ v-solver-1510 32)) (* 4 (|c/INDEX| (m-u32 v-new_start-1512)))))) 0 1)) 0)) (go ENDLOOP1514))
    (progn (let* ( (old1517 v-new_start-1512)) (setf v-new_start-1512 (+ old1517 (* 4 1))) v-new_start-1512))
    (go LOOP1513)
    ENDLOOP1514
    (setf v-delta-1518 (truncate (- v-new_start-1512 (m-ptr (+ v-trail-1511 0))) 4))
    (progn (let ((a1519 (+ v-trail-1511 16))) (setf (m-ptr a1519) (- (m-ptr a1519) (* 4 v-delta-1518)))))
    (progn v-solver-1510)
    (setf v-lit-1523 (m-ptr (+ v-trail-1511 0)))
    LOOP1524
    (unless (c-true (if (/= v-new_start-1512 (m-ptr (+ v-trail-1511 8))) 1 0)) (go ENDLOOP1525))
    (progn (setf (m-u32 (let* ( (old1528 v-lit-1523)) (setf v-lit-1523 (+ old1528 (* 4 1))) old1528)) (m-u32 (let* ( (old1530 v-new_start-1512)) (setf v-new_start-1512 (+ old1530 (* 4 1))) old1530))))
    (go LOOP1524)
    ENDLOOP1525
    (setf v-lvl-1534 (m-ptr (+ (+ v-solver-1510 576) 0)))
    LOOP1531
    (unless (c-true (if (/= v-lvl-1534 (m-ptr (+ (+ v-solver-1510 576) 8))) 1 0)) (go ENDLOOP1532))
    (progn (let ((a1535 (+ v-lvl-1534 0))) (setf (m-ptr a1535) (- (m-ptr a1535) (* 4 v-delta-1518)))))
    (let* ( (old1537 v-lvl-1534)) (setf v-lvl-1534 (+ old1537 (* 24 1))) v-lvl-1534)
    (go LOOP1531)
    ENDLOOP1532
    (progn (setf (m-ptr (+ v-trail-1511 8)) v-lit-1523))
  )
  0))

;;; upstream/satch.c:4649:1
(defun |c/boolean_constraint_propagation| (arg-v-solver-1538)
 (declare (optimize (speed 3)) (type c-address arg-v-solver-1538))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-1538 0) (v-trail-1542 0) (v-propagate-1543 0) (v-p-1544 0) (v-conflict-1545 0) (v-ticks-1546 (stack-alloc 8)) (v-propagated-1556 0))
 (declare (type c-address v-solver-1538) (type c-address v-trail-1542) (type c-address v-propagate-1543) (type c-address v-p-1544) (type c-address v-conflict-1545) (type c-address v-ticks-1546) (type (unsigned-byte 32) v-propagated-1556) (ignorable v-solver-1538 v-trail-1542 v-propagate-1543 v-p-1544 v-conflict-1545 v-ticks-1546 v-propagated-1556))
 (tagbody
    (setf v-solver-1538 arg-v-solver-1538)
    (progn v-solver-1538)
    (setf v-trail-1542 (+ v-solver-1538 552))
    (setf v-propagate-1543 (m-ptr (+ v-trail-1542 16)))
    (setf v-conflict-1545 0)
    (setf (m-u64 v-ticks-1546) (c-u64 0))
    (progn (setf v-p-1544 v-propagate-1543))
    LOOP1547
    (unless (c-true (if (c-true (if (c-true v-conflict-1545) 0 1)) (c-bool (if (/= v-p-1544 (m-ptr (+ v-trail-1542 8))) 1 0)) 0)) (go ENDLOOP1548))
    (progn (setf v-conflict-1545 (|c/propagate_literal| v-solver-1538 (m-u32 v-p-1544) 0 v-ticks-1546)))
    (let* ( (old1551 v-p-1544)) (setf v-p-1544 (+ old1551 (* 4 1))) old1551)
    (go LOOP1547)
    ENDLOOP1548
    (progn (let ((a1555 (+ (+ v-solver-1538 1016) 360))) (setf (m-u64 a1555) (c-u64 (c-u64 (+ (m-u64 a1555) (m-u64 v-ticks-1546)))))))
    (progn (setf (m-ptr (+ (+ v-solver-1538 552) 16)) v-p-1544))
    (setf v-propagated-1556 (c-u32 (truncate (- v-p-1544 v-propagate-1543) 4)))
    (progn (let ((a1560 (+ (+ v-solver-1538 1016) 168))) (setf (m-u64 a1560) (c-u64 (c-u64 (+ (m-u64 a1560) v-propagated-1556))))))
    (unless (c-true v-conflict-1545) (go ELSE1561))
    (progn (progn 0 (let* ((a1563 (+ (+ v-solver-1538 1016) 48)) (old1564 (m-u64 a1563))) (setf (m-u64 a1563) (c-u64 (c-u64 (+ old1564 (c-u64 1))))) (m-u64 a1563))))
    (go ENDIF1562)
    ELSE1561
    (unless (c-true (if (c-true (if (c-true (m-u32 (+ v-solver-1538 8))) 0 1)) 1 (c-bool (m-u8 (+ v-solver-1538 5))))) (go ELSE1565))
    (progn (|c/flush_units| v-solver-1538))
    (go ENDIF1566)
    ELSE1565
    ENDIF1566
    ENDIF1562
    (return-from |c/boolean_constraint_propagation| v-conflict-1545)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:4692:1
(defun |c/save_phases| (arg-v-solver-1567 arg-v-phases-1568)
 (declare  (type c-address arg-v-solver-1567) (type c-address arg-v-phases-1568))
 (let ((v-solver-1567 0) (v-phases-1568 0) (v-end-1569 0) (v-q-1570 0) (v-tmp-1571 0) (v-p-1575 0))
 (declare (type c-address v-solver-1567) (type c-address v-phases-1568) (type c-address v-end-1569) (type c-address v-q-1570) (type (signed-byte 8) v-tmp-1571) (type c-address v-p-1575) (ignorable v-solver-1567 v-phases-1568 v-end-1569 v-q-1570 v-tmp-1571 v-p-1575))
 (tagbody
    (setf v-solver-1567 arg-v-solver-1567)
    (setf v-phases-1568 arg-v-phases-1568)
    (setf v-end-1569 (+ (m-ptr (+ v-solver-1567 40)) (* 1 (c-u32 (* 2 (m-u32 (+ v-solver-1567 12)))))))
    (setf v-q-1570 v-phases-1568)
    (setf v-p-1575 (m-ptr (+ v-solver-1567 40)))
    LOOP1572
    (unless (c-true (if (/= v-p-1575 v-end-1569) 1 0)) (go ENDLOOP1573))
    (unless (c-true (setf v-tmp-1571 (m-s8 v-p-1575))) (go ELSE1576))
    (progn (setf (m-s8 v-q-1570) v-tmp-1571))
    (go ENDIF1577)
    ELSE1576
    ENDIF1577
    (progn (setf v-p-1575 (+ v-p-1575 (* 1 2))) (let* ( (old1580 v-q-1570)) (setf v-q-1570 (+ old1580 (* 1 1))) old1580))
    (go LOOP1572)
    ENDLOOP1573
  )
  0))

;;; upstream/satch.c:4703:1
(defun |c/update_target_phases| (arg-v-solver-1581 arg-v-assigned-1582)
 (declare  (type c-address arg-v-solver-1581) (type (unsigned-byte 32) arg-v-assigned-1582))
 (let ((v-solver-1581 0) (v-assigned-1582 0) (v-targets-1583 0))
 (declare (type c-address v-solver-1581) (type (unsigned-byte 32) v-assigned-1582) (type (unsigned-byte 64) v-targets-1583) (ignorable v-solver-1581 v-assigned-1582 v-targets-1583))
 (tagbody
    (setf v-solver-1581 arg-v-solver-1581)
    (setf v-assigned-1582 arg-v-assigned-1582)
    (locally (declare (optimize (speed 1))) (setf v-targets-1583 (progn 0 (let* ((a1584 (+ (+ v-solver-1581 1016) 336)) (old1585 (m-u64 a1584))) (setf (m-u64 a1584) (c-u64 (c-u64 (+ old1585 (c-u64 1))))) (m-u64 a1584)))))
    (progn (|c/save_phases| v-solver-1581 (m-ptr (+ v-solver-1581 64))))
    (progn (setf (m-u32 (+ v-solver-1581 72)) v-assigned-1582))
    (progn (when (>= (m-u32 (+ v-solver-1581 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-1581 (c-u32 3) |c/string/105| v-targets-1583 |c/string/106| v-assigned-1582 (|c/percent| (float v-assigned-1582 1d0) (float (m-u32 (+ v-solver-1581 12)) 1d0)) (m-u64 (+ (+ v-solver-1581 1016) 48))))))
  )
  0))

;;; upstream/satch.c:4716:1
(defun |c/update_best_phases| (arg-v-solver-1586 arg-v-assigned-1587)
 (declare  (type c-address arg-v-solver-1586) (type (unsigned-byte 32) arg-v-assigned-1587))
 (let ((v-solver-1586 0) (v-assigned-1587 0) (v-bests-1588 0))
 (declare (type c-address v-solver-1586) (type (unsigned-byte 32) v-assigned-1587) (type (unsigned-byte 64) v-bests-1588) (ignorable v-solver-1586 v-assigned-1587 v-bests-1588))
 (tagbody
    (setf v-solver-1586 arg-v-solver-1586)
    (setf v-assigned-1587 arg-v-assigned-1587)
    (locally (declare (optimize (speed 1))) (setf v-bests-1588 (progn 0 (let* ((a1589 (+ (+ v-solver-1586 1016) 24)) (old1590 (m-u64 a1589))) (setf (m-u64 a1589) (c-u64 (c-u64 (+ old1590 (c-u64 1))))) (m-u64 a1589)))))
    (progn (|c/save_phases| v-solver-1586 (m-ptr (+ v-solver-1586 80))))
    (progn (setf (m-u32 (+ v-solver-1586 88)) v-assigned-1587))
    (progn (when (>= (m-u32 (+ v-solver-1586 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-1586 (c-u32 3) |c/string/107| v-bests-1588 |c/string/108| v-assigned-1587 (|c/percent| (float v-assigned-1587 1d0) (float (m-u32 (+ v-solver-1586 12)) 1d0)) (m-u64 (+ (+ v-solver-1586 1016) 48))))))
  )
  0))

;;; upstream/satch.c:4734:1
(defun |c/assigned_variables| (arg-v-solver-1591)
 (declare  (type c-address arg-v-solver-1591))
 (let ((v-solver-1591 0))
 (declare (type c-address v-solver-1591) (ignorable v-solver-1591))
 (tagbody
    (setf v-solver-1591 arg-v-solver-1591)
    (return-from |c/assigned_variables| (c-u32 (- (m-u32 (+ v-solver-1591 12)) (m-u32 (+ v-solver-1591 24)))))
  )
  0))

;;; upstream/satch.c:4741:1
(defun |c/update_phases| (arg-v-solver-1592)
 (declare  (type c-address arg-v-solver-1592))
 (let ((v-solver-1592 0) (v-assigned-1593 0))
 (declare (type c-address v-solver-1592) (type (unsigned-byte 32) v-assigned-1593) (ignorable v-solver-1592 v-assigned-1593))
 (tagbody
    (setf v-solver-1592 arg-v-solver-1592)
    (setf v-assigned-1593 (|c/assigned_variables| v-solver-1592))
    (unless (c-true (if (> v-assigned-1593 (m-u32 (+ v-solver-1592 72))) 1 0)) (go ELSE1594))
    (progn (|c/update_target_phases| v-solver-1592 v-assigned-1593))
    (go ENDIF1595)
    ELSE1594
    ENDIF1595
    (unless (c-true (if (> v-assigned-1593 (m-u32 (+ v-solver-1592 88))) 1 0)) (go ELSE1596))
    (progn (|c/update_best_phases| v-solver-1592 v-assigned-1593))
    (go ENDIF1597)
    ELSE1596
    ENDIF1597
  )
  0))

;;; upstream/satch.c:4773:1
(defun |c/backtrack| (arg-v-solver-1598 arg-v-new_level-1599)
 (declare (optimize (speed 3)) (type c-address arg-v-solver-1598) (type (unsigned-byte 32) arg-v-new_level-1599))
 (let ((v-solver-1598 0) (v-new_level-1599 0) (v-levels-1603 0) (v-values-1604 0) (v-queue-1605 0) (v-links-1606 0) (v-search-1607 0) (v-max_stamp-1608 0) (v-scores-1611 0) (v-pos-1612 0) (v-trail-1615 0) (v-target_lit-1616 0) (v-starting-1617 0) (v-position-1618 0) (v-starting_position-1619 0) (v-reassigned-1623 0) (v-lit-1627 0) (v-idx-1630 0) (v-lit_level-1631 0) (v-not_lit-1651 0) (v-stamp-1654 0))
 (declare (type c-address v-solver-1598) (type (unsigned-byte 32) v-new_level-1599) (type c-address v-levels-1603) (type c-address v-values-1604) (type c-address v-queue-1605) (type c-address v-links-1606) (type (unsigned-byte 32) v-search-1607) (type (unsigned-byte 32) v-max_stamp-1608) (type c-address v-scores-1611) (type c-address v-pos-1612) (type c-address v-trail-1615) (type c-address v-target_lit-1616) (type c-address v-starting-1617) (type c-address v-position-1618) (type (signed-byte 32) v-starting_position-1619) (type (signed-byte 32) v-reassigned-1623) (type (unsigned-byte 32) v-lit-1627) (type (unsigned-byte 32) v-idx-1630) (type (unsigned-byte 32) v-lit_level-1631) (type (unsigned-byte 32) v-not_lit-1651) (type (unsigned-byte 32) v-stamp-1654) (ignorable v-solver-1598 v-new_level-1599 v-levels-1603 v-values-1604 v-queue-1605 v-links-1606 v-search-1607 v-max_stamp-1608 v-scores-1611 v-pos-1612 v-trail-1615 v-target_lit-1616 v-starting-1617 v-position-1618 v-starting_position-1619 v-reassigned-1623 v-lit-1627 v-idx-1630 v-lit_level-1631 v-not_lit-1651 v-stamp-1654))
 (tagbody
    (setf v-solver-1598 arg-v-solver-1598)
    (setf v-new_level-1599 arg-v-new_level-1599)
    (progn v-solver-1598)
    (setf v-levels-1603 (m-ptr (+ v-solver-1598 32)))
    (setf v-values-1604 (m-ptr (+ v-solver-1598 40)))
    (setf v-queue-1605 0)
    (setf v-links-1606 0)
    (setf v-search-1607 4294967295)
    (setf v-max_stamp-1608 4294967295)
    (unless (c-true (if (c-true (m-u8 (+ v-solver-1598 6))) 0 1)) (go ELSE1609))
    (progn (setf v-queue-1605 (|c/get_queue| v-solver-1598)))
    (progn (setf v-links-1606 (m-ptr (+ v-queue-1605 0))))
    (progn (setf v-search-1607 (m-u32 (+ v-queue-1605 20))))
    (progn (setf v-max_stamp-1608 (if (c-true (if (= v-search-1607 4294967295) 1 0)) (c-u32 0) (m-u32 (+ (+ v-links-1606 (* 12 v-search-1607)) 8)))))
    (go ENDIF1610)
    ELSE1609
    ENDIF1610
    (setf v-scores-1611 0)
    (setf v-pos-1612 0)
    (unless (c-true (m-u8 (+ v-solver-1598 6))) (go ELSE1613))
    (progn (setf v-scores-1611 (|c/get_scores| v-solver-1598)))
    (progn (setf v-pos-1612 (m-ptr (+ v-scores-1611 16))))
    (go ENDIF1614)
    ELSE1613
    ENDIF1614
    (setf v-trail-1615 (+ v-solver-1598 552))
    (setf v-target_lit-1616 (m-ptr (+ (+ (m-ptr (+ (+ v-solver-1598 576) 0)) (* 24 (progn 0 v-new_level-1599))) 0)))
    (setf v-starting-1617 v-target_lit-1616)
    (setf v-position-1618 (m-ptr (+ v-solver-1598 224)))
    (setf v-starting_position-1619 (c-s32 (truncate (- v-target_lit-1616 (m-ptr (+ (+ v-solver-1598 552) 0))) 4)))
    (progn v-solver-1598)
    (progn (setf (m-ptr (+ v-trail-1615 16)) v-target_lit-1616))
    (setf v-reassigned-1623 0)
    LOOP1624
    (unless (c-true (if (/= v-target_lit-1616 (m-ptr (+ (+ v-solver-1598 552) 8))) 1 0)) (go ENDLOOP1625))
    (setf v-lit-1627 (m-u32 v-target_lit-1616))
    (progn (let* ( (old1629 v-target_lit-1616)) (setf v-target_lit-1616 (+ old1629 (* 4 1))) v-target_lit-1616))
    (setf v-idx-1630 (|c/INDEX| v-lit-1627))
    (setf v-lit_level-1631 (m-u32 (+ v-levels-1603 (* 4 v-idx-1630))))
    (progn v-solver-1598)
    (unless (c-true (if (<= v-lit_level-1631 v-new_level-1599) 1 0)) (go ELSE1635))
    (progn v-solver-1598)
    (progn (setf (m-u32 v-starting-1617) v-lit-1627))
    (progn (setf (m-u32 (+ v-position-1618 (* 4 v-idx-1630))) (c-u32 v-starting_position-1619)))
    (progn (let* ( (old1641 v-reassigned-1623)) (setf v-reassigned-1623 (c-s32 (c-s32 (+ old1641 1)))) v-reassigned-1623))
    (progn (let* ( (old1643 v-starting-1617)) (setf v-starting-1617 (+ old1643 (* 4 1))) v-starting-1617))
    (progn (let* ( (old1645 v-starting_position-1619)) (setf v-starting_position-1619 (c-s32 (c-s32 (+ old1645 1)))) v-starting_position-1619))
    (go CONTINUE1626)
    ELSE1635
    (progn v-solver-1598)
    (progn (let* ((a1649 (+ v-solver-1598 24)) (old1650 (m-u32 a1649))) (setf (m-u32 a1649) (c-u32 (c-u32 (+ old1650 (c-u32 1))))) old1650))
    (setf v-not_lit-1651 (|c/NOT| v-lit-1627))
    (progn (setf (m-s8 (+ v-values-1604 (* 1 v-lit-1627))) (c-s8 0)))
    (progn (setf (m-s8 (+ v-values-1604 (* 1 v-not_lit-1651))) (c-s8 0)))
    (unless (c-true v-links-1606) (go ELSE1652))
    (setf v-stamp-1654 (m-u32 (+ (+ v-links-1606 (* 12 v-idx-1630)) 8)))
    (unless (c-true (if (> v-stamp-1654 v-max_stamp-1608) 1 0)) (go ELSE1655))
    (progn (progn (setf v-search-1607 v-idx-1630) (setf v-max_stamp-1608 v-stamp-1654)))
    (go ENDIF1656)
    ELSE1655
    ENDIF1656
    (go ENDIF1653)
    ELSE1652
    ENDIF1653
    (unless (c-true (if (c-true v-pos-1612) (c-bool (if (= (m-u32 (+ v-pos-1612 (* 4 v-idx-1630))) 4294967295) 1 0)) 0)) (go ELSE1657))
    (progn (|c/push_heap| v-solver-1598 v-scores-1611 v-idx-1630))
    (go ENDIF1658)
    ELSE1657
    ENDIF1658
    CONTINUE1626
    (go LOOP1624)
    ENDLOOP1625
    (progn (setf (m-ptr (+ (+ v-solver-1598 552) 8)) v-starting-1617))
    (unless (c-true v-queue-1605) (go ELSE1659))
    (progn v-solver-1598)
    (progn (setf (m-u32 (+ v-queue-1605 20)) v-search-1607))
    (go ENDIF1660)
    ELSE1659
    ENDIF1660
    (progn (setf (m-ptr (+ (+ v-solver-1598 576) 8)) (+ (m-ptr (+ (+ v-solver-1598 576) 0)) (* 24 v-new_level-1599))))
    (progn (setf (m-u32 (+ v-solver-1598 8)) v-new_level-1599))
  )
  0))

;;; upstream/satch.c:4974:1
(defun |c/update_phases_and_backtrack_to_root_level| (arg-v-solver-1664)
 (declare  (type c-address arg-v-solver-1664))
 (let ((v-solver-1664 0) (v-conflict-1669 0))
 (declare (type c-address v-solver-1664) (type c-address v-conflict-1669) (ignorable v-solver-1664 v-conflict-1669))
 (tagbody
    (setf v-solver-1664 arg-v-solver-1664)
    (unless (c-true (if (c-true (m-u32 (+ v-solver-1664 8))) 0 1)) (go ELSE1665))
    (return-from |c/update_phases_and_backtrack_to_root_level| 0)
    ELSE1665
    (unless (c-true (m-u8 (+ v-solver-1664 6))) (go ELSE1667))
    (progn (|c/update_phases| v-solver-1664))
    (go ENDIF1668)
    ELSE1667
    ENDIF1668
    (progn (|c/backtrack| v-solver-1664 (c-u32 0)))
    (setf v-conflict-1669 (|c/boolean_constraint_propagation| v-solver-1664))
    (unless (c-true v-conflict-1669) (go ELSE1670))
    (progn (setf (m-u8 (+ v-solver-1664 4)) (c-bool 1)))
    (go ENDIF1671)
    ELSE1670
    ENDIF1671
  )
  0))

;;; upstream/satch.c:5013:1
(defun |c/averages| (arg-v-solver-1672)
 (declare  (type c-address arg-v-solver-1672))
 (let ((v-solver-1672 0))
 (declare (type c-address v-solver-1672) (ignorable v-solver-1672))
 (tagbody
    (setf v-solver-1672 arg-v-solver-1672)
    (return-from |c/averages| (+ (+ v-solver-1672 888) (* 64 (m-u8 (+ v-solver-1672 6)))))
  )
  0))

;;; upstream/satch.c:5019:1
(defun |c/update_slow_average| (arg-v-average-1673 arg-v-value-1674)
 (declare  (type c-address arg-v-average-1673) (type (unsigned-byte 32) arg-v-value-1674))
 (let ((v-average-1673 0) (v-value-1674 0))
 (declare (type c-address v-average-1673) (type (unsigned-byte 32) v-value-1674) (ignorable v-average-1673 v-value-1674))
 (tagbody
    (setf v-average-1673 arg-v-average-1673)
    (setf v-value-1674 arg-v-value-1674)
    (progn (let ((a1675 v-average-1673)) (setf (m-f64 a1675) (float (float (+ (m-f64 a1675) (float (* 1d-05 (float (- (float v-value-1674 1d0) (m-f64 v-average-1673)) 1d0)) 1d0)) 1d0) 1d0))))
  )
  0))

;;; upstream/satch.c:5025:1
(defun |c/unbiased_slow_average| (arg-v-a-1676 arg-v-avg-1677)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-a-1676) (type double-float arg-v-avg-1677))
 (let ((v-a-1676 0) (v-avg-1677 0d0) (v-div-1678 0d0))
 (declare (type c-address v-a-1676) (type double-float v-avg-1677) (type double-float v-div-1678) (ignorable v-a-1676 v-avg-1677 v-div-1678))
 (tagbody
    (setf v-a-1676 arg-v-a-1676)
    (setf v-avg-1677 arg-v-avg-1677)
    (setf v-div-1678 (float (- (float 1 1d0) (m-f64 (+ v-a-1676 16))) 1d0))
    (return-from |c/unbiased_slow_average| (if (c-true (if (c-true v-div-1678) 0 1)) (float 0 1d0) (if (c-true (if (= v-div-1678 (float 1 1d0)) 1 0)) v-avg-1677 (float (/ v-avg-1677 v-div-1678) 1d0))))
  )
  0))

;;; upstream/satch.c:5038:1
(defun |c/update_fast_average| (arg-v-average-1679 arg-v-value-1680)
 (declare  (type c-address arg-v-average-1679) (type (unsigned-byte 32) arg-v-value-1680))
 (let ((v-average-1679 0) (v-value-1680 0))
 (declare (type c-address v-average-1679) (type (unsigned-byte 32) v-value-1680) (ignorable v-average-1679 v-value-1680))
 (tagbody
    (setf v-average-1679 arg-v-average-1679)
    (setf v-value-1680 arg-v-value-1680)
    (progn (let ((a1681 v-average-1679)) (setf (m-f64 a1681) (float (float (+ (m-f64 a1681) (float (* 0.03d0 (float (- (float v-value-1680 1d0) (m-f64 v-average-1679)) 1d0)) 1d0)) 1d0) 1d0))))
  )
  0))

;;; upstream/satch.c:5044:1
(defun |c/unbiased_fast_average| (arg-v-a-1682 arg-v-avg-1683)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-a-1682) (type double-float arg-v-avg-1683))
 (let ((v-a-1682 0) (v-avg-1683 0d0) (v-div-1684 0d0))
 (declare (type c-address v-a-1682) (type double-float v-avg-1683) (type double-float v-div-1684) (ignorable v-a-1682 v-avg-1683 v-div-1684))
 (tagbody
    (setf v-a-1682 arg-v-a-1682)
    (setf v-avg-1683 arg-v-avg-1683)
    (setf v-div-1684 (float (- (float 1 1d0) (m-f64 (+ v-a-1682 56))) 1d0))
    (return-from |c/unbiased_fast_average| (if (c-true (if (c-true v-div-1684) 0 1)) (float 0 1d0) (if (c-true (if (= v-div-1684 (float 1 1d0)) 1 0)) v-avg-1683 (float (/ v-avg-1683 v-div-1684) 1d0))))
  )
  0))

;;; upstream/satch.c:5057:1
(defun |c/update_betas| (arg-v-solver-1685)
 (declare  (type c-address arg-v-solver-1685))
 (let ((v-solver-1685 0) (v-a-1686 0))
 (declare (type c-address v-solver-1685) (type c-address v-a-1686) (ignorable v-solver-1685 v-a-1686))
 (tagbody
    (setf v-solver-1685 arg-v-solver-1685)
    (setf v-a-1686 (|c/averages| v-solver-1685))
    (unless (c-true (m-f64 (+ v-a-1686 56))) (go ELSE1687))
    (progn (let ((a1689 (+ v-a-1686 56))) (setf (m-f64 a1689) (float (float (* (m-f64 a1689) |c/global/fast_beta|) 1d0) 1d0))))
    (go ENDIF1688)
    ELSE1687
    ENDIF1688
    (unless (c-true (m-f64 (+ v-a-1686 16))) (go ELSE1690))
    (progn (let ((a1692 (+ v-a-1686 16))) (setf (m-f64 a1692) (float (float (* (m-f64 a1692) |c/global/slow_beta|) 1d0) 1d0))))
    (go ENDIF1691)
    ELSE1690
    ENDIF1691
  )
  0))

;;; upstream/satch.c:5069:1
(defun |c/init_one_set_of_averages| (arg-v-a-1693)
 (declare  (type c-address arg-v-a-1693))
 (let ((v-a-1693 0))
 (declare (type c-address v-a-1693) (ignorable v-a-1693))
 (tagbody
    (setf v-a-1693 arg-v-a-1693)
    (progn (setf (m-f64 (+ v-a-1693 16)) 1.0d0))
    (progn (setf (m-f64 (+ v-a-1693 56)) 1.0d0))
  )
  0))

;;; upstream/satch.c:5078:1
(defun |c/init_averages| (arg-v-solver-1694)
 (declare  (type c-address arg-v-solver-1694))
 (let ((v-solver-1694 0) (v-i-1698 0))
 (declare (type c-address v-solver-1694) (type (signed-byte 32) v-i-1698) (ignorable v-solver-1694 v-i-1698))
 (tagbody
    (setf v-solver-1694 arg-v-solver-1694)
    (setf v-i-1698 0)
    LOOP1695
    (unless (c-true (if (< v-i-1698 2) 1 0)) (go ENDLOOP1696))
    (progn (|c/init_one_set_of_averages| (+ (+ v-solver-1694 888) (* 64 v-i-1698))))
    (let* ( (old1700 v-i-1698)) (setf v-i-1698 (c-s32 (c-s32 (+ old1700 1)))) old1700)
    (go LOOP1695)
    ENDLOOP1696
  )
  0))


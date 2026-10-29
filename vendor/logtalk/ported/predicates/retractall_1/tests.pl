% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/retractall_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('dynamic'('/'('foo',1))).
'foo'(1).
'foo'(2).
'foo'(3).
':-'('elk'(V0),'moose'(V0)).
':-'('dynamic'('/'('insect',1))).
'insect'('ant').
'insect'('bee').
':-'('dynamic'('/'('a',1))).
'a'(1).
'a'(2).
':-'('a'(V0),'b'(V0)).
'b'(3).
':-'('dynamic'('/'('c',2))).
'c'(1,'a').
'c'(1,'A').
'c'(2,'b').
'c'(2,'B').
':-'('throws'('lgt_retractall_1_07','error'('instantiation_error',V0)),'retractall'(V1)).
'three'(3).
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_01:65','true'('current_predicate'('/'('foo',1))),'retractall'('foo'(V0)),[],'true').
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_02:70','true','retractall'('insect'('bee')),[],'true').
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_03:73','true','retractall'('insect'(V0)),[],'true').
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_04:76','true','retractall'('insect'('spider')),[],'true').
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_05:79','error'('type_error'('callable',3)),','('three'(V0),'retractall'(V0)),[],'true').
'conf_case'('predicates/retractall_1/tests.lgt:iso_retractall_1_06:84','error'('permission_error'('modify','static_procedure','/'('retractall',1))),'retractall'('retractall'(V0)),[],'true').

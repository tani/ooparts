% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/assertz_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('dynamic'('/'('legs',2))).
':-'('dynamic'('/'('foo',1))).
'four'(4).
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_01:40','true','assertz'('legs'('spider',8)),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_02:43','true','assertz'(':-'('legs'(V0,2),'bird'(V0))),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_03:46','true','assertz'(':-'('foo'(V0),'->'(V0,'call'(V0)))),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_04:49','error'('instantiation_error'),'assertz'(V0),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_05:52','error'('type_error'('callable',4)),','('four'(V0),'assertz'(V0)),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_06:57','error'('type_error'('callable',4)),','('four'(V0),'assertz'(':-'('foo',V0))),[],'true').
'conf_case'('predicates/assertz_1/tests.lgt:iso_assertz_1_07:62','error'('permission_error'('modify','static_procedure','/'('atom',1))),'assertz'(':-'('atom'(V0),'true')),[],'true').

% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/asserta_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('dynamic'('/'('legs',2))).
':-'('dynamic'('/'('foo',1))).
':-'('discontiguous'('/'('succeeds',1))).
':-'('discontiguous'('/'('throws',2))).
'four'(4).
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_01:44','true','asserta'('legs'('octopus',8)),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_02:47','true','asserta'(':-'('legs'(V0,4),'animal'(V0))),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_03:50','true','asserta'(':-'('foo'(V0),','(V0,'call'(V0)))),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_04:53','error'('instantiation_error'),'asserta'(V0),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_05:56','error'('type_error'('callable',4)),','('four'(V0),'asserta'(V0)),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_06:61','error'('type_error'('callable',4)),','('four'(V0),'asserta'(':-'('foo',V0))),[],'true').
'conf_case'('predicates/asserta_1/tests.lgt:iso_asserta_1_07:66','error'('permission_error'('modify','static_procedure','/'('atom',1))),'asserta'(':-'('atom'(V0),'true')),[],'true').

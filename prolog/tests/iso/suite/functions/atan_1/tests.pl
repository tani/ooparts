% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/atan_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'conf_case'('functions/atan_1/tests.lgt:iso_atan_1_01:41','true'('=='(V0,0.0)),'is'(V0,'atan'(0.0)),[],'true').
'conf_case'('functions/atan_1/tests.lgt:iso_atan_1_02:44','true'('conf_approximately_equal'(V0,3.1415927)),'is'(V0,'*'('atan'(1.0),4)),[],'true').
'conf_case'('functions/atan_1/tests.lgt:iso_atan_1_03:47','error'('instantiation_error'),','('variable'(V0),'is'(V1,'atan'(V0))),[],'true').
'conf_case'('functions/atan_1/tests.lgt:iso_atan_1_04:52','true'('=='(V0,0.0)),'is'(V0,'atan'(0)),[],'true').
'conf_case'('functions/atan_1/tests.lgt:iso_atan_1_05:55','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'atan'(V0))),[],'true').

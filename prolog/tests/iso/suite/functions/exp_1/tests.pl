% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/exp_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'large'(123456789).
'conf_case'('functions/exp_1/tests.lgt:iso_exp_1_01:41','true'('=='(V0,1.0)),'is'(V0,'exp'(0.0)),[],'true').
'conf_case'('functions/exp_1/tests.lgt:iso_exp_1_02:44','true'('conf_approximately_equal'(V0,2.71828)),'is'(V0,'exp'(1.0)),[],'true').
'conf_case'('functions/exp_1/tests.lgt:iso_exp_1_03:47','error'('instantiation_error'),','('variable'(V0),'is'(V1,'exp'(V0))),[],'true').
'conf_case'('functions/exp_1/tests.lgt:iso_exp_1_04:52','true'('=='(V0,1.0)),'is'(V0,'exp'(0)),[],'true').
'conf_case'('functions/exp_1/tests.lgt:iso_exp_1_05:55','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'exp'(V0))),[],'true').

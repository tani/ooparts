% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/abs_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/abs_1/tests.lgt:iso_abs_1_01:37','true'('=='(V0,7)),'is'(V0,'abs'(7)),[],'true').
'conf_case'('functions/abs_1/tests.lgt:iso_abs_1_02:40','true'('=='(V0,8)),'is'(V0,'abs'('-'(3,11))),[],'true').
'conf_case'('functions/abs_1/tests.lgt:iso_abs_1_03:43','true'('=='(V0,7.8)),'is'(V0,'abs'('-'(3.2,11.0))),[],'true').
'conf_case'('functions/abs_1/tests.lgt:iso_abs_1_04:46','error'('instantiation_error'),','('variable'(V0),'is'(V1,'abs'(V0))),[],'true').
'conf_case'('functions/abs_1/tests.lgt:iso_abs_1_05:51','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'abs'(V0))),[],'true').

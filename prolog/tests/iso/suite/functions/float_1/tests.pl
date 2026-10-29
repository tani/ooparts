% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/float_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_01:37','true'('=='(V0,7.0)),'is'(V0,'float'(7)),[],'true').
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_02:40','true'('=='(V0,7.3)),'is'(V0,'float'(7.3)),[],'true').
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_03:43','true'('=='(V0,1.0)),'is'(V0,'float'('//'(5,3))),[],'true').
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_04:47','error'('instantiation_error'),','('variable'(V0),'is'(V1,'float'(V0))),[],'true').
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_05:52','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'float'(V0))),[],'true').
'conf_case'('functions/float_1/tests.lgt:iso_float_1_function_06:59','error'('type_error'('evaluable','/'('foo',1))),','('foo'(1,V0),'is'(V1,'float'(V0))),[],'true').

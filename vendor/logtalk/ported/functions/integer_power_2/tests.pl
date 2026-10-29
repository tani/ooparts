% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/integer_power_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'big_float'(1.0e+300).
'negative'(-42).
'zero'(0).
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_01:41','true'('=='(V0,1)),'is'(V0,'^'(0,0)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_02:44','true'('=='(V0,3.0)),'is'(V0,'^'(3,1.0)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_03:47','true'('=='(V0,27)),'is'(V0,'^'(3,3)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_04:50','true'('=='(V0,134217728)),'is'(V0,'^'(2,27)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_05:53','true'('=='(V0,134217728)),'is'(V0,'^'(2,'^'(3,3))),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_06:56','error'('type_error'('float',2)),'is'(V0,'^'(2,-1)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_07:59','true'('conf_approximately_equal'(V0,0.5)),'is'(V0,'^'(2.0,-1)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_08:62','true'('=='(V0,1)),'is'(V0,'^'(1,-1)),[],'true').
'conf_case'('functions/integer_power_2/tests.lgt:iso_integer_power_2_09:65','true'('conf_approximately_equal'(V0,0.353553)),'is'(V0,'^'(2,-1.5)),[],'true').

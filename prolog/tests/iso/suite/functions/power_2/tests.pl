% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/power_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'foo'(2,'foo'(1,2)).
'negative'(-1).
'big_float'(1.0e+300).
'small_float'(1.0e-300).
'conf_case'('functions/power_2/tests.lgt:iso_power_2_01:41','true'('conf_approximately_equal'(V0,125.0)),'is'(V0,'**'(5,3)),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_02:44','true'('conf_approximately_equal'(V0,-125.0)),'is'(V0,'**'(-5.0,3)),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_03:47','true'('conf_approximately_equal'(V0,0.2)),'is'(V0,'**'(5,-1)),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_04:50','error'('instantiation_error'),','('variable'(V0),'is'(V1,'**'(77,V0))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_05:55','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'**'(V0,3))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_06:60','true'('conf_approximately_equal'(V0,125.0)),'is'(V0,'**'(5,3.0)),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_07:63','true'('conf_approximately_equal'(V0,1.0)),'is'(V0,'**'(0,0.0)),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_09:71','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'**'(5,V0))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_10:76','error'('type_error'('evaluable','/'('foo',1))),','('foo'(1,V0),'is'(V1,'**'(V0,3))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_11:81','error'('type_error'('evaluable','/'('foo',1))),','('foo'(1,V0),'is'(V1,'**'(5,V0))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_12:86','error'('type_error'('evaluable','/'('foo',2))),','('foo'(2,V0),'is'(V1,'**'(V0,3))),[],'true').
'conf_case'('functions/power_2/tests.lgt:iso_power_2_13:91','error'('type_error'('evaluable','/'('foo',2))),','('foo'(2,V0),'is'(V1,'**'(5,V0))),[],'true').

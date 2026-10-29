% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/functions/mod_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'variable'(V0).
'foo'(0,'foo').
'foo'(1,'foo'(1)).
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_01:34','true'('=='(V0,1)),'is'(V0,'mod'(5,2)),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_02:37','true'('=='(V0,0)),'is'(V0,'mod'(0,'+'(3,11))),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_03:40','true'('=='(V0,-1)),'is'(V0,'mod'(5,-2)),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_04:43','error'('instantiation_error'),','('variable'(V0),'is'(V1,'mod'(77,V0))),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_05:48','error'('type_error'('evaluable','/'('foo',0))),','('foo'(0,V0),'is'(V1,'mod'(V0,77))),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_06:53','error'('type_error'('integer',7.5)),','('='(V0,'is'(V1,'mod'(7.5,2))),'call'(V0)),[],'true').
'conf_case'('functions/mod_2/tests.lgt:iso_mod_2_07:57','error'('evaluation_error'('zero_divisor')),','('='(V0,'is'(V1,'mod'(7,0))),'call'(V0)),[],'true').

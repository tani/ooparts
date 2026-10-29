% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/number_chars_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'quick_check'('iso_number_chars_2_14','round_trip'('+'('integer'))).
'quick_check'('iso_number_chars_2_15','round_trip'('+'('float'))).
':-'('round_trip'(V0),','('number_chars'(V0,V1),','('number_chars'(V2,V1),'=='(V0,V2)))).
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_01:37','true'('=='(V0,['3'|['3'|[]]])),'number_chars'(33,V0),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_02:40','true','number_chars'(33,['3'|['3'|[]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_03:43','true'('=='(V0,33.0)),','('number_chars'(33.0,V1),'number_chars'(V0,V1)),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_04:46','true'('=='(V0,3.3)),'number_chars'(V0,['3'|['.'|['3'|['E'|['+'|['0'|[]]]]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_05:49','true','number_chars'(3.3,['3'|V0]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_06:52','true'('=='(V0,-25)),'number_chars'(V0,['-'|['2'|['5'|[]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_07:55','true'('=='(V0,3)),'number_chars'(V0,['\n'|[' '|['3'|[]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_08:58','error'('syntax_error'(V0)),'number_chars'(V1,['3'|[' '|[]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_09:61','true'('=='(V0,15)),'number_chars'(V0,['0'|['x'|['f'|[]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_10:64','true'('=='(V0,97)),'number_chars'(V0,['0'|[''''|['a'|[]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_11:67','true'('=='(V0,4.2)),'number_chars'(V0,['4'|['.'|['2'|[]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_12:70','true'('=='(V0,4.2)),'number_chars'(V0,['4'|['2'|['.'|['0'|['e'|['-'|['1'|[]]]]]]]]),[],'true').
'conf_case'('predicates/number_chars_2/tests.lgt:iso_number_chars_2_13:75','true',','('='(V0,['0'|['.'|['1'|[]]]]),','('number_chars'(V1,V0),'number_chars'(V1,V0))),[],'true').

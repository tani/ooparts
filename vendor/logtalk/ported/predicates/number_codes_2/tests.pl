% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/number_codes_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'quick_check'('iso_number_codes_2_12','round_trip'('+'('integer'))).
'quick_check'('iso_number_codes_2_13','round_trip'('+'('float'))).
':-'('round_trip'(V0),','('number_codes'(V0,V1),','('number_codes'(V2,V1),'=='(V0,V2)))).
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_01:37','true'('=='(V0,[51|[51|[]]])),'number_codes'(33,V0),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_02:40','true','number_codes'(33,[51|[51|[]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_03:43','true'('=='(V0,33.0)),','('number_codes'(33.0,V1),'number_codes'(V0,V1)),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_04:46','true','number_codes'(33.0,[51|V0]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_05:49','true'('=='(V0,-25)),'number_codes'(V0,[45|[50|[53|[]]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_06:52','true'('=='(V0,3)),'number_codes'(V0,[32|[51|[]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_07:55','true'('=='(V0,15)),'number_codes'(V0,[48|[120|[102|[]]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_08:58','true'('=='(V0,97)),'number_codes'(V0,[48|[39|[97|[]]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_09:61','true'('=='(V0,4.2)),'number_codes'(V0,[52|[46|[50|[]]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_10:64','true'('=='(V0,4.2)),'number_codes'(V0,[52|[50|[46|[48|[101|[45|[49|[]]]]]]]]),[],'true').
'conf_case'('predicates/number_codes_2/tests.lgt:iso_number_codes_2_11:69','true',','('='(V0,[48|[46|[49|[]]]]),','('number_codes'(V1,V0),'number_codes'(V1,V0))),[],'true').

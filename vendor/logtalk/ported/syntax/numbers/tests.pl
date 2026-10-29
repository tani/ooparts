% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/numbers/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/numbers/tests.lgt:iso_number_01:37','true'('=='(V0,123)),','('conf_set_text_input'('123. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_02:41','true'('=='(V0,-123)),','('conf_set_text_input'('-123. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_03:45','true'('=='(V0,123.45)),','('conf_set_text_input'('123.45. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_04:49','true'('=='(V0,-123.45)),','('conf_set_text_input'('-123.45. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_05:55','true'('=='(V0,83)),','('conf_set_text_input'('83. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_06:59','true'('char_code'('S',V0)),','('conf_set_text_input'('0''S. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_07:63','true'('=='(V0,83)),','('conf_set_text_input'('0b1010011. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_08:67','true'('=='(V0,83)),','('conf_set_text_input'('0o123. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_09:71','true'('=='(V0,83)),','('conf_set_text_input'('0x53. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_10:77','true'('=='(V0,123.45)),','('conf_set_text_input'('123.45. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_11:81','true'('=='(V0,1234.5)),','('conf_set_text_input'('123.45e+1. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_12:85','true'('=='(V0,1234.5)),','('conf_set_text_input'('123.45E+1. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_13:89','true'('=='(V0,12.345)),','('conf_set_text_input'('123.45e-1. '),'read'(V0)),[],'true').
'conf_case'('syntax/numbers/tests.lgt:iso_number_14:93','true'('=='(V0,12.345)),','('conf_set_text_input'('123.45E-1. '),'read'(V0)),[],'true').

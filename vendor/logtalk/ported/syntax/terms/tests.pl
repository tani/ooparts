% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/terms/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/terms/tests.lgt:iso_term_01:34','true',','('conf_set_text_input'('f(x,y). '),'read'(V0)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_02:38','true',','('conf_set_text_input'('f(:-, ;, [:-, :-|:-]). '),'read'(V0)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_03:42','error'('syntax_error'(V0)),','('conf_set_text_input'('f(,,a). '),'read'(V1)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_04:46','error'('syntax_error'(V0)),','('conf_set_text_input'('[a,,|v]. '),'read'(V1)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_05:50','error'('syntax_error'(V0)),','('conf_set_text_input'('[a,b|,]. '),'read'(V1)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_06:54','true',','('conf_set_text_input'('f('','',a). '),'read'(V0)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_07:58','true',','('conf_set_text_input'('[a,'',''|v]. '),'read'(V0)),[],'true').
'conf_case'('syntax/terms/tests.lgt:iso_term_08:62','true',','('conf_set_text_input'('[a,b|'','']. '),'read'(V0)),[],'true').

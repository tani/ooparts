% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/lists/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/lists/tests.lgt:iso_list_01:34','true'('=='(V0,'.'('a',[]))),','('conf_set_text_input'('[a]. '),'read'(V0)),[],'true').
'conf_case'('syntax/lists/tests.lgt:iso_list_02:38','true'('=='(V0,'.'('a','.'('b',[])))),','('conf_set_text_input'('[a,b]. '),'read'(V0)),[],'true').
'conf_case'('syntax/lists/tests.lgt:iso_list_03:42','true'('=='(V0,'.'('a','b'))),','('conf_set_text_input'('[a|b]. '),'read'(V0)),[],'true').

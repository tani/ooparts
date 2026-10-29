% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/curly_terms/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_text_input','conf_clean_text_output')).
'conf_case'('syntax/curly_terms/tests.lgt:iso_curly_bracketed_term_01:34','true'('=='(V0,'{}'('a'))),','('conf_set_text_input'('{a}. '),'read'(V0)),[],'true').
'conf_case'('syntax/curly_terms/tests.lgt:iso_curly_bracketed_term_02:38','true'('=='(V0,'{}'(','('a','b')))),','('conf_set_text_input'('{a,b}. '),'read'(V0)),[],'true').

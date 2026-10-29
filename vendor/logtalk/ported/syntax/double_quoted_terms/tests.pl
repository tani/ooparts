% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/double_quoted_terms/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'double_quotes_example_1'(['(      current_prolog_flag(double_quotes, chars), atom_chars(''jim'', "jim")'|[';      current_prolog_flag(double_quotes, codes), atom_codes(''jim'', "jim")'|[';      current_prolog_flag(double_quotes, atom), ''jim'' == "jim"'|['). '|[]]]]]).
'double_quotes_example_2'(['(      current_prolog_flag(double_quotes, chars), [] == ""'|[';      current_prolog_flag(double_quotes, codes), [] == ""'|[';      current_prolog_flag(double_quotes, atom), '''' == ""'|['). '|[]]]]]).
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_01:34','true',','('double_quotes_example_1'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','chars'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_02:40','true',','('double_quotes_example_1'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','codes'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_03:46','true',','('double_quotes_example_1'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','atom'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_04:52','true',','('double_quotes_example_2'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','chars'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_05:58','true',','('double_quotes_example_2'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','codes'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_06:64','true',','('double_quotes_example_2'(V0),','('conf_set_text_input'(V0),','('set_prolog_flag'('double_quotes','atom'),','('read'(V1),'call'(V1))))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_07:70','true'('atom_chars'('jim',V0)),','('conf_set_text_input'('"jim". '),','('set_prolog_flag'('double_quotes','chars'),'read'(V0))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_08:75','true'('atom_codes'('jim',V0)),','('conf_set_text_input'('"jim". '),','('set_prolog_flag'('double_quotes','codes'),'read'(V0))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_09:80','true'('=='(V0,'jim')),','('conf_set_text_input'('"jim". '),','('set_prolog_flag'('double_quotes','atom'),'read'(V0))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_10:85','true'('=='(V0,[])),','('conf_set_text_input'('"". '),','('set_prolog_flag'('double_quotes','chars'),'read'(V0))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_11:90','true'('=='(V0,[])),','('conf_set_text_input'('"". '),','('set_prolog_flag'('double_quotes','codes'),'read'(V0))),[],'true').
'conf_case'('syntax/double_quoted_terms/tests.lgt:iso_double_quoted_term_12:95','true'('=='(V0,'')),','('conf_set_text_input'('"". '),','('set_prolog_flag'('double_quotes','atom'),'read'(V0))),[],'true').

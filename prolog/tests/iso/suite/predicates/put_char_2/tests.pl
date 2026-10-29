% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/put_char_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_text_output',','('conf_clean_binary_output','conf_clean_text_input'))).
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_01:34','true'(V0),','('conf_set_text_output'('qwer'),','('put_char'('t'),'conf_text_output_assertion'('qwert',V0))),[],'true').
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_02:39','true'(V0),','('conf_set_text_output'('st_o','qwer'),','('put_char'('st_o','A'),'conf_text_output_assertion'('st_o','qwerA',V0))),[],'true').
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_03:44','true'(V0),','('conf_set_text_output'('qwer'),','(','('nl','put_char'('a')),'conf_text_output_assertion'('qwer\na',V0))),[],'true').
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_04:49','true'(V0),','('conf_set_text_output'('st_o','qwer'),','(','('nl'('st_o'),'put_char'('st_o','a')),'conf_text_output_assertion'('st_o','qwer\na',V0))),[],'true').
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_05:54','error'('instantiation_error'),','('conf_set_text_output'('my_file',''),'put_char'('my_file',V0)),[],'true').
'conf_case'('predicates/put_char_2/tests.lgt:iso_put_char_2_06:58','error'('type_error'('character','ty')),','('conf_set_text_output'('st_o',''),'put_char'('st_o','ty')),[],'true').

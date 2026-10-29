% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/put_code_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_file'('t'),','('conf_clean_text_output',','('conf_clean_text_input','conf_clean_binary_output')))).
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_01:34','true'(V0),','('conf_set_text_output'('qwer'),','('put_code'(116),'conf_text_output_assertion'('qwert',V0))),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_02:39','true'(V0),','('conf_set_text_output'('st_o','qwer'),','('put_code'('st_o',116),'conf_text_output_assertion'('st_o','qwert',V0))),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_03:46','error'('instantiation_error'),','('conf_set_text_output'('my_file',''),','('put_code'('my_file',V0),'conf_check_text_output'('my_file',''))),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_04:51','error'('type_error'('integer','ty')),','('conf_set_text_output'('st_o',''),','('put_code'('st_o','ty'),'conf_check_text_output'('st_o',''))),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_07:62','error'('existence_error'('stream',V0)),','('conf_closed_input_stream'(V0,[]),'put_code'(V0,97)),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_08:66','error'('existence_error'('stream',V0)),','('conf_closed_output_stream'(V0,[]),'put_code'(V0,97)),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_09:70','error'('permission_error'('output','stream',V0)),','('current_input'(V0),'put_code'(V0,97)),[],'true').
'conf_case'('predicates/put_code_2/tests.lgt:iso_put_code_2_10:74','error'('permission_error'('output','binary_stream',V0)),','('conf_file_path'('t',V1),','('open'(V1,'write',V0,['type'('binary')|[]]),'put_code'(V0,97))),[],'true').

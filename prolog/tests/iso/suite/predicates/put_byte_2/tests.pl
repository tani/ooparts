% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/put_byte_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_binary_input',','('conf_clean_binary_output','conf_clean_text_output'))).
'conf_case'('predicates/put_byte_2/tests.lgt:iso_put_byte_2_01:34','true'(V0),','('conf_set_binary_output'([113|[119|[101|[114|[]]]]]),','('put_byte'(116),'conf_binary_output_assertion'([113|[119|[101|[114|[116|[]]]]]],V0))),[],'true').
'conf_case'('predicates/put_byte_2/tests.lgt:iso_put_byte_2_02:39','true'(V0),','('conf_set_binary_output'('st_o',[113|[119|[101|[114|[]]]]]),','('put_byte'('st_o',116),'conf_binary_output_assertion'('st_o',[113|[119|[101|[114|[116|[]]]]]],V0))),[],'true').
'conf_case'('predicates/put_byte_2/tests.lgt:iso_put_byte_2_03:44','error'('instantiation_error'),','('conf_set_binary_output'('my_file_1',[]),'put_byte'('my_file_1',V0)),[],'true').
'conf_case'('predicates/put_byte_2/tests.lgt:iso_put_byte_2_04:48','error'('type_error'('byte','ty')),','('conf_set_binary_output'('my_file_2',[]),'put_byte'('my_file_2','ty')),[],'true').

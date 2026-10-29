% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/write_term_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('multifile'('/'('portray',1))).
':-'('dynamic'('/'('portray',1))).
':-'('portray'(V0),','('atom'(V0),','('write'(V0),'write'(V0)))).
':-'('portray'(V0),','('float'(V0),','('is'(V1,'truncate'(V0)),'write'(V1)))).
':-'('conf_suite_cleanup',','('conf_clean_binary_output',','('conf_clean_text_output','conf_clean_text_input'))).
':-'('max_depth_option_supported',','('conf_profile'('prolog_dialect',V0),','('\\=='(V0,'b'),','('\\=='(V0,'cx'),'\\=='(V0,'ji'))))).
':-'('portrayed_option_supported',','('conf_profile'('prolog_dialect',V0),','('\\=='(V0,'b'),','('\\=='(V0,'cx'),','('\\=='(V0,'ji'),','('\\=='(V0,'tau'),'\\=='(V0,'yap'))))))).
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_001:48','true'(V0),','('conf_set_text_output'('out',''),','('write_term'('out',[1|[2|[3|[]]]],[]),'conf_text_output_assertion'('out','[1,2,3]',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_002:53','true'(V0),','('conf_set_text_output'('out',''),','('write_canonical'('out',[1|[2|[3|[]]]]),'conf_text_output_assertion'('out','''.''(1,''.''(2,''.''(3,[])))',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_003:58','true'(V0),','('conf_set_text_output'('out',''),','('write_term'('out','1<2',[]),'conf_text_output_assertion'('out','1<2',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_004:63','true'(V0),','('conf_set_text_output'('out',''),','('writeq'('out','1<2'),'conf_text_output_assertion'('out','''1<2''',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_005:68','true'(V0),','('conf_set_text_output'('out',''),','('writeq'('out','$VAR'(0)),'conf_text_output_assertion'('out','A',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_006:73','true'(V0),','('conf_set_text_output'('out',''),','('write_term'('out','$VAR'(1),['numbervars'('false')|[]]),'conf_text_output_assertion'('out','$VAR(1)',V0))),[],'true').
'conf_case'('predicates/write_term_3/tests.lgt:iso_write_term_3_007:78','true'(V0),','('conf_set_text_output'('out',''),','('write_term'('out','$VAR'(51),['numbervars'('true')|[]]),'conf_text_output_assertion'('out','Z1',V0))),[],'true').

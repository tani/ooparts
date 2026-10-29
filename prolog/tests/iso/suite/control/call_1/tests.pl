% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/control/call_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('b'(V0),','('='(V1,','('write'(V0),V0)),'call'(V1))).
'a'(1).
'a'(2).
'two'(2).
':-'('dynamic'('/'('unicorn',0))).
':-'('multifile'('/'('fenix',1))).
':-'('discontiguous'('/'('scattered',2))).
'goal'('two'(V0)).
'one'(1).
'conf_case'('control/call_1/tests.lgt:iso_call_1_01:55','true','call'('!'),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_02:58','false','call'('fail'),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_03:61','false','call'(','('fail',V0)),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_04:64','false',','('one'(V0),'call'(','('fail','call'(V0)))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_05:69','error'('instantiation_error'),','('conf_suppress_text_output','b'(V0)),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_06:73','error'('type_error'('callable',','('write'(3),3))),','('conf_suppress_text_output','b'(3)),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_07:78','true'('=='('-'(V0,V1),'-'('!',1))),','('='(V0,'!'),'call'(','('='(V0,'!'),','('a'(V1),V0)))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_08:81','true'('=='(V0,['-'('!',1)|['-'('!',2)|[]]])),'findall'('-'(V1,V2),'call'(','('='(V1,'!'),','('a'(V2),V1))),V0),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_09:84','error'('instantiation_error'),','('conf_suppress_text_output','call'(','('write'(3),V0))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_10:88','error'('type_error'('callable',1)),','('conf_suppress_text_output',','('one'(V0),'call'(','('write'(3),'call'(V0))))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_11:94','error'('instantiation_error'),'call'(V0),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_12:97','error'('type_error'('callable',1)),','('one'(V0),'call'(V0)),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_13:102','error'('type_error'('callable',','('fail',1))),','('one'(V0),'call'(','('fail',V0))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_14:108','error'('type_error'('callable',','('write'(3),1))),','('conf_suppress_text_output',','('one'(V0),'call'(','('write'(3),V0)))),[],'true').
'conf_case'('control/call_1/tests.lgt:iso_call_1_15:115','error'('type_error'('callable',';'(1,'true'))),','('one'(V0),'call'(';'(V0,'true'))),[],'true').

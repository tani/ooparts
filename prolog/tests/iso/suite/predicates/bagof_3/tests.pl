% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/bagof_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'a'(1,'f'(V0)).
'a'(2,'f'(V0)).
'b'(1,1).
'b'(1,1).
'b'(1,2).
'b'(2,1).
'b'(2,2).
'b'(2,2).
'a'(1).
'a'(2).
'a'(3).
'c'(2,'b','B').
'c'(1,'a','A').
'c'(3,'c','C').
'f'(V0,1,'a').
'f'(V0,2,'b').
'v1'(V0).
'v1'(V0).
'v1'(V0).
'v2'(V0,V1).
'v2'(V0,V1).
'v2'(V0,V1).
'v3'(V0,V0).
'v3'(V0,V0).
'v3'(V0,V1).
'v4'(V0,V1,V0).
'v4'(V0,V0,V1).
'v4'(V0,V1,V1).
'v5'(V0,V1,V0).
'v5'(V0,V0,V1).
'v5'(V0,V1,V1).
'v5'(V0,V1,V0).
'v6'(V0,V1,V1,V0).
'v6'(V0,V1,V2,V0).
'v6'(V0,V1,V1,V2).
'v6'(V0,V1,V1,V0).
'bagof_3_member'(V0,[V0|V1]).
':-'('bagof_3_member'(V0,[V1|V2]),'bagof_3_member'(V0,V2)).
'one'(1).
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_01:99','true'('=='(V0,[1|[2|[]]])),'bagof'(V1,';'('='(V1,1),'='(V1,2)),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_02:102','true'('=='(V0,[1|[2|[]]])),'bagof'(V0,';'('='(V0,1),'='(V0,2)),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_03:105','true'('=='(V0,[V1|[V2|[]]])),'bagof'(V3,';'('='(V3,V1),'='(V3,V2)),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_04:108','false','bagof'(V0,'fail',V1),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_05:111','true'(';'('=='(V0,['-'([1|[]],1)|['-'([1|[]],2)|[]]]),'=='(V0,['-'([1|[]],2)|['-'([1|[]],1)|[]]]))),'findall'('-'(V1,V2),'bagof'(1,';'('='(V2,1),'='(V2,2)),V1),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_06:114','variant'(V0,['f'('a',V1)|['f'(V2,'b')|[]]]),'bagof'('f'(V3,V4),';'('='(V3,'a'),'='(V4,'b')),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_07:117','true'('=='(V0,[1|[2|[]]])),'bagof'(V1,'^'(V2,';'(','('='(V1,1),'='(V2,1)),','('='(V1,2),'='(V2,2)))),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_08:120','variant'(V0,[1|[V1|[2|[]]]]),'bagof'(V2,'^'(V3,';'(';'('='(V2,1),'='(V3,1)),','('='(V2,2),'='(V3,2)))),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_09:125','variant'(V0,['-'([1|[3|[]]],V1)|['-'([V2|[]],1)|[]]]),'findall'('-'(V3,V4),'bagof'(V5,';'('^'(V4,';'('='(V5,1),'='(V4,1))),'='(V5,3)),V3),V0),[],','('catch'('^'(1,'true'),V6,'fail'),'true')).
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_09:130','true'('=='(V0,[3|[]])),','('set_prolog_flag'('unknown','fail'),'bagof'(V1,';'('^'(V2,';'('='(V1,1),'='(V2,1))),'='(V1,3)),V0)),[],','('\\+'('catch'('^'(1,'true'),V3,'fail')),'true')).
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_10:137','variant'(V0,['-'([V1|[V2|[]]],V1)|['-'([V3|[]],1)|[]]]),'findall'('-'(V4,V5),'bagof'(V6,';'('='(V6,V5),';'('='(V6,V7),'='(V5,1))),V4),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_11:140','variant'(V0,'f'(V1)),','('bagof'(V2,'a'(V2,V0),V3),'conf_assertion'('=='(V3,[1|[2|[]]]))),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_12:144','true'('=='(V0,['-'([1|[1|[2|[]]]],1)|['-'([1|[2|[2|[]]]],2)|[]]])),'findall'('-'(V1,V2),'bagof'(V3,'b'(V3,V2),V1),V0),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_13:147','error'('instantiation_error'),'bagof'(V0,'^'(V1,V2),V3),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_14:150','error'('type_error'('callable',1)),','('one'(V0),'bagof'(V1,V0,V2)),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_15:158','subsumes'([V0|[]],V1),'findall'(V2,'bagof'(V3,'a'(V3),V2),V1),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_16:161','true'('var'(V0)),'bagof'(V0,'a'(V0),V1),[],'true').
'conf_case'('predicates/bagof_3/tests.lgt:iso_bagof_3_17:164','true','conf_forall'('bagof'(V0,'^'(V1,'c'(V0,V1,V2)),V3),','('var'(V0),'var'(V1))),[],'true').

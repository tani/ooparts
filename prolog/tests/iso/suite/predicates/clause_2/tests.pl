% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/clause_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('dynamic'('/'('cat',0))).
'cat'.
':-'('dynamic'('/'('dog',0))).
':-'('dog','true').
':-'('elk'(V0),'moose'(V0)).
':-'('dynamic'('/'('legs',2))).
':-'('legs'(V0,6),'insect'(V0)).
':-'('legs'(V0,7),','(V0,'call'(V0))).
':-'('dynamic'('/'('insect',1))).
'insect'('ant').
'insect'('bee').
':-'('dynamic'('/'('r',3))).
':-'('r'(V0,V1,V2),','('a'(V0),','('b'(V1),'c'(V2)))).
'a'(V0).
'b'(V0).
'c'(V0).
':-'('dynamic'('/'('p',2))).
'p'('a'(V0),'b'(V0)).
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_01:62','true','clause'('cat','true'),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_02:65','true','clause'('dog','true'),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_03:68','true'('=='(V0,'insect'(V1))),'clause'('legs'(V1,6),V0),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_04:71','true'('=='(V0,','('call'(V1),'call'(V1)))),'clause'('legs'(V1,7),V0),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_05:74','true'('=='(V0,['-'('ant','true')|['-'('bee','true')|[]]])),'findall'('-'(V1,V2),'clause'('insect'(V1),V2),V0),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_06:77','false','clause'('x',V0),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_07:80','error'('instantiation_error'),'clause'(V0,V1),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_08:83','error'('type_error'('callable',4)),'clause'(4,V0),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_09:86','true','catch'('clause'('elk'(V0),V1),V2,';'('='(V2,'error'('permission_error'('access','private_procedure','/'('elk',1)),V3)),'='(V2,'error'('permission_error'('access','private_procedure',':'('user','/'('elk',1))),V4)))),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_10:97','error'('permission_error'('access','private_procedure','/'('atom',1))),'clause'('atom'(V0),V1),[],'true').
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_11:107','true','clause'('legs'(V0,6),'insect'('f'(V0))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/clause_2/tests.lgt:iso_clause_2_11:112','true','clause'('legs'(V0,6),'insect'('f'(V0))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).

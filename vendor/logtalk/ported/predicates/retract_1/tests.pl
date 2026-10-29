% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/retract_1/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('elk'(V0),'moose'(V0)).
':-'('dynamic'('/'('legs',2))).
':-'('legs'(V0,4),'animal'(V0)).
'legs'('octopus',8).
':-'('legs'(V0,6),'insect'(V0)).
'legs'('spider',8).
':-'('legs'(V0,2),'bird'(V0)).
':-'('dynamic'('/'('insect',1))).
'insect'('ant').
'insect'('bee').
':-'('dynamic'('/'('foo',1))).
':-'('foo'(V0),'->'('call'(V0),'call'(V0))).
':-'('foo'(V0),','('call'(V0),'call'(V0))).
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_01:54','true','retract'('legs'('octopus',8)),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_02:57','false','retract'('legs'('spider',6)),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_03:60','true'('=='(V0,'bird'(V1))),'retract'(':-'('legs'(V1,2),V0)),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_04:63','variant'(V0,['-'('-'(V1,4),'animal'(V1))|['-'('-'(V2,6),'insect'(V2))|['-'('-'('spider',8),'true')|[]]]]),'findall'('-'('-'(V3,V4),V5),'retract'(':-'('legs'(V3,V4),V5)),V0),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_05:66','false','retract'(':-'('legs'(V0,V1),V2)),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_06:69','true'('=='(V0,'ant')),','('retract'('insect'(V0)),'retract'('insect'('bee'))),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_07:80','true','retract'(':-'('foo'(V0),','(V0,'call'(V0)))),[],','(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse')))),'true')).
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_07:85','true','retract'(':-'('foo'(V0),','(V0,'call'(V0)))),['note'('STO')|[]],','('\\+'(','('conf_profile'('coinduction','supported'),','('\\+'('conf_profile'('prolog_dialect','cx')),'\\+'('conf_profile'('prolog_dialect','eclipse'))))),'true')).
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_08:91','true'('=='('-'(V0,V1),'-'('call'(V2),'call'(V2)))),'retract'(':-'('foo'(V2),'->'(V0,V1))),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_09:94','error'('instantiation_error'),'retract'(':-'(V0,'in_eec'(V1))),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_10:97','error'('type_error'('callable',4)),'retract'(':-'(4,V0)),[],'true').
'conf_case'('predicates/retract_1/tests.lgt:iso_retract_1_11:100','error'('permission_error'('modify','static_procedure','/'('atom',1))),'retract'(':-'('atom'(V0),'=='(V0,'[]'))),[],'true').

% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/sub_atom_5/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_01:34','true'('=='(V0,'abrac')),'sub_atom'('abracadabra',0,5,V1,V0),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_02:37','true'('=='(V0,'dabra')),'sub_atom'('abracadabra',V1,5,0,V0),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_03:40','true'('=='('-'(V0,V1),'-'(5,'acada'))),'sub_atom'('abracadabra',3,V0,3,V1),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_04:43','true'('=='(V0,['-'(0,9)|['-'(7,2)|[]]])),'findall'('-'(V1,V2),'sub_atom'('abracadabra',V1,2,V2,'ab'),V0),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_05:46','true'('=='(V0,'an')),'sub_atom'('Banana',3,2,V1,V0),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_06:49','true'('=='(V0,['cha'|['har'|['ari'|['rit'|['ity'|[]]]]]])),'findall'(V1,'sub_atom'('charity',V2,3,V3,V1),V0),[],'true').
'conf_case'('predicates/sub_atom_5/tests.lgt:iso_sub_atom_5_07:52','true'('=='(V0,['-'('-'(0,0),'')|['-'('-'(0,1),'a')|['-'('-'(0,2),'ab')|['-'('-'(1,0),'')|['-'('-'(1,1),'b')|['-'('-'(2,0),'')|[]]]]]]])),'findall'('-'('-'(V1,V2),V3),'sub_atom'('ab',V1,V2,V4,V3),V0),[],'true').

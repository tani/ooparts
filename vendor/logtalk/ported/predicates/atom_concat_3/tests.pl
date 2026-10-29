% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/atom_concat_3/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/atom_concat_3/tests.lgt:iso_atom_concat_3_01:34','true'('=='(V0,'hello world')),'atom_concat'('hello',' world',V0),[],'true').
'conf_case'('predicates/atom_concat_3/tests.lgt:iso_atom_concat_3_02:37','true'('=='(V0,'small')),'atom_concat'(V0,' world','small world'),[],'true').
'conf_case'('predicates/atom_concat_3/tests.lgt:iso_atom_concat_3_03:40','false','atom_concat'('hello',' world','small world'),[],'true').
'conf_case'('predicates/atom_concat_3/tests.lgt:iso_atom_concat_3_04:43','true'('=='(V0,['-'('','hello')|['-'('h','ello')|['-'('he','llo')|['-'('hel','lo')|['-'('hell','o')|['-'('hello','')|[]]]]]]])),'findall'('-'(V1,V2),'atom_concat'(V1,V2,'hello'),V0),[],'true').
'conf_case'('predicates/atom_concat_3/tests.lgt:iso_atom_concat_3_05:46','error'('instantiation_error'),'atom_concat'('small',V0,V1),[],'true').

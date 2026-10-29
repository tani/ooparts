% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/atom_codes_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_01:34','true'('=='(V0,[])),'atom_codes'('',V0),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_02:37','true'('=='(V0,[91|[93|[]]])),'atom_codes'([],V0),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_03:40','true'('=='(V0,[39|[]])),'atom_codes'('''',V0),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_04:43','true'('=='(V0,[97|[110|[116|[]]]])),'atom_codes'('ant',V0),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_05:46','true'('=='(V0,'sop')),'atom_codes'(V0,[115|[111|[112|[]]]]),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_06:49','true'('=='(V0,[111|[114|[116|[104|[]]]]])),'atom_codes'('North',[78|V0]),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_07:52','false','atom_codes'('soap',[115|[111|[112|[]]]]),[],'true').
'conf_case'('predicates/atom_codes_2/tests.lgt:iso_atom_codes_2_08:55','error'('instantiation_error'),'atom_codes'(V0,V1),[],'true').

% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/atom_length_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_01:34','true'('=='(V0,17)),'atom_length'('enchanted evening',V0),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_02:37','true'('=='(V0,17)),'atom_length'('enchanted evening',V0),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_03:41','true'('=='(V0,0)),'atom_length'('',V0),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_04:44','false','atom_length'('scarlet',5),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_05:47','error'('instantiation_error'),'atom_length'(V0,4),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_06:50','error'('type_error'('atom',1.23)),'atom_length'(1.23,4),[],'true').
'conf_case'('predicates/atom_length_2/tests.lgt:iso_atom_length_2_07:53','error'('type_error'('integer','4')),'atom_length'('atom','4'),[],'true').

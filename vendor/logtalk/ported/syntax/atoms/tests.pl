% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/syntax/atoms/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup','conf_clean_text_input').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_01:34','true'('atom'(V0)),','('conf_set_text_input'('a. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_02:38','true'('atom'(V0)),','('conf_set_text_input'('''A''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_03:44','true'('atom'(V0)),','('conf_set_text_input'('''a''''b''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_04:48','true'('atom'(V0)),','('conf_set_text_input'('''a\\''b''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_05:52','true'('atom'(V0)),','('conf_set_text_input'('''a\\"b''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_06:56','true'('atom'(V0)),','('conf_set_text_input'('''a\\\\b''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_07:60','true'('=='(V0,'aSb')),','('conf_set_text_input'('''a\\123\\b''. '),'read'(V0)),[],'true').
'conf_case'('syntax/atoms/tests.lgt:iso_atom_08:64','true'('=='(V0,'aSb')),','('conf_set_text_input'('''a\\x53\\b''. '),'read'(V0)),[],'true').

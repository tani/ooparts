% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/stream_property_2/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_file'('foo'),','('conf_clean_file'('bar'),','('conf_clean_file'('output_text_file'),','('conf_clean_file'('input_text_file'),','('conf_clean_file'('output_binary_file'),'conf_clean_file'('input_binary_file'))))))).
':-'('memberchk'(V0,[V1|V2]),','('=='(V0,V1),'!')).
':-'('memberchk'(V0,[V1|V2]),'conf_memberchk'(V0,V2)).
'conf_case'('predicates/stream_property_2/tests.lgt:iso_stream_property_2_01:34','true'(','('conf_memberchk'('-'(V0,V1),V2),'conf_memberchk'('-'(V3,V4),V2))),','('conf_file_path'('foo',V1),','('conf_file_path'('bar',V4),','('conf_create_text_file'(V1,''),','('open'(V1,'read',V0),','('open'(V4,'write',V3),'findall'('-'(V5,V6),'stream_property'(V5,'file_name'(V6)),V2)))))),['cleanup'(','('close'(V0),'close'(V3)))|[]],'true').
'conf_case'('predicates/stream_property_2/tests.lgt:iso_stream_property_2_02:42','true'(','('conf_memberchk'(V0,V1),'conf_memberchk'(V2,V1))),','('conf_file_path'('bar',V3),','('open'(V3,'write',V0),','('current_output'(V2),'findall'(V4,'stream_property'(V4,'output'),V1)))),['cleanup'('close'(V0))|[]],'true').

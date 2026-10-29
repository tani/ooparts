% SPDX-FileCopyrightText: 1998-2026 Paulo Moura <pmoura@logtalk.org>
% SPDX-License-Identifier: Apache-2.0
% Modified for ooparts/prolog: Logtalk wrappers removed; portable fixtures and strict expectations.
% Source: LogtalkDotOrg/logtalk3, tests/prolog/predicates/open_4/tests.lgt
% Regenerate with port-logtalk.pl; see upstream.json for the pinned revision.

':-'('conf_suite_cleanup',','('conf_clean_file'('roger_data'),','('conf_clean_file'('scowen'),','('conf_clean_file'('dave'),','('conf_clean_file'('foo'),','('conf_clean_file'('bar'),','('conf_clean_file'('f'),','('conf_clean_file'('no_read_permission'),','('conf_clean_file'('no_write_permission'),','('conf_clean_file'('no_append_permission'),','('conf_clean_file'('d1'),','('conf_clean_file'('d2'),','('conf_clean_file'('tt'),','('conf_clean_file'('tb'),','('conf_clean_file'('rt'),'conf_clean_file'('rf')))))))))))))))).
':-'('create_no_read_permission_file',','('conf_dispatch'('os','operating_system_type'('unix')),','('not_running_as_root',','('conf_file_path'('no_read_permission',V0),','('conf_create_text_file'(V0,'foo.'),','('atom_concat'('chmod a-r ',V0,V1),'conf_dispatch'('os','shell'(V1)))))))).
':-'('create_no_write_permission_file',','('conf_dispatch'('os','operating_system_type'('unix')),','('not_running_as_root',','('conf_file_path'('no_write_permission',V0),','('conf_create_text_file'(V0,'foo.'),','('atom_concat'('chmod a-w ',V0,V1),'conf_dispatch'('os','shell'(V1)))))))).
':-'('create_no_append_permission_file',','('conf_dispatch'('os','operating_system_type'('unix')),','('not_running_as_root',','('conf_file_path'('no_append_permission',V0),','('conf_create_text_file'(V0,'foo.'),','('atom_concat'('chmod a-w ',V0,V1),'conf_dispatch'('os','shell'(V1)))))))).
':-'('not_running_as_root',','('conf_dispatch'('os','operating_system_type'('unix')),'conf_dispatch'('os','shell'('if [ "$(id -u)" -eq 0 ]; then exit 1; fi')))).
'conf_case'('predicates/open_4/tests.lgt:iso_open_4_01:34','true',','('conf_file_path'('roger_data',V0),','('conf_create_binary_file'(V0,[]),','('open'(V0,'read',V1,['type'('binary')|[]]),'at_end_of_stream'(V1)))),[],'true').
'conf_case'('predicates/open_4/tests.lgt:iso_open_4_02:40','true',','('conf_file_path'('scowen',V0),','('open'(V0,'write',V1,['alias'('editor')|[]]),'stream_property'(V1,'alias'('editor')))),[],'true').
'conf_case'('predicates/open_4/tests.lgt:iso_open_4_03:45','true',','('conf_file_path'('dave',V0),','('conf_create_text_file'(V0,'foo.'),','('open'(V0,'read',V1,[]),','('read'(V1,'foo'),'at_end_of_stream'(V1))))),[],'true').

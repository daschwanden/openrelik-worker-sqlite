#!/usr/bin/env bash

sqlite3 $1 <<!
.headers on
.mode csv
.output execPolicy.csv
SELECT
datetime(timestamp+978307200/3600,'UNIXEPOCH', 'LOCALTIME') as "ts",
volume_uuid,fs_type_name, bundle_id,team_identifier,signing_identifier,policy_match,malware_result,flags,
datetime(mod_time++978307200/3600,'UNIXEPOCH', 'LOCALTIME') as "modTs",
datetime(revocation_check_time++978307200/3600,'UNIXEPOCH', 'LOCALTIME') as "revTs"
from policy_scan_cache WHERE bundle_id NOT like "com.apple.%" AND malware_result is NOT '0'
ORDER by ts ASC;
!

echo "Exported ExecPolicy to execPolicy.csv"
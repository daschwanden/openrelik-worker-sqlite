#!/usr/bin/env bash

sqlite3 $1 <<!
.headers on
.mode csv
.output quarantine.csv
SELECT * FROM `LSQuarantineEvent`
!

echo "Exported Quarantine Events to quarantine.csv"
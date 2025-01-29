#!/usr/bin/env bash

sqlite3 $1 <<!
.headers on
.mode csv
.output tcc_access.csv
select * from access;
!

echo "Exported TCC Access to tcc_access.csv"
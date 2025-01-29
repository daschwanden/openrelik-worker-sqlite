#!/usr/bin/env bash

sqlite3 $1 <<!
.headers on
.mode csv
.output systemPolicy_authority.csv
select * from authority;
!

echo "Exported System Policy Authority to systemPolicy_authority.csv"

sqlite3 $1 <<!
.headers on
.mode csv
.output systemPolicy_object.csv
select * from object;
!

echo "Exported System Policy Object to systemPolicy_object.csv"

sqlite3 $1 <<!
.headers on
.mode csv
.output systemPolicy_object_state.csv
select * from object_state;
!

echo "Exported System Policy Object State to systemPolicy_object_state.csv"


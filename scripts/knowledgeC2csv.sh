#!/usr/bin/env bash

sqlite3 $1 <<!
.headers on
.mode csv
.output knowledgeC_application_usage.csv
SELECT
datetime(ZOBJECT.ZCREATIONDATE+978307200,"UNIXEPOCH") as "ENTRY CREATION",
ZOBJECT.ZVALUESTRING AS "BUNDLE ID",
CASE ZOBJECT.ZSTARTDAYOFWEEK
    WHEN "1" THEN "Sunday"
    WHEN "2" THEN "Monday"
    WHEN "3" THEN "Tuesday"
    WHEN "4" THEN "Wednesday"
    WHEN "5" THEN "Thursday"
    WHEN "6" THEN "Friday"
    WHEN "7" THEN "Saturday"
END "DAY OF WEEK",
ZOBJECT.ZSECONDSFROMGMT/3600 AS "GMT OFFSET",
datetime(ZOBJECT.ZSTARTDATE+978307200,"UNIXEPOCH") as "START",
datetime(ZOBJECT.ZENDDATE+978307200,"UNIXEPOCH") as "END",
(ZOBJECT.ZENDDATE-ZOBJECT.ZSTARTDATE) as "USAGE IN SECONDS"
FROM ZOBJECT
WHERE ZSTREAMNAME IS "/app/inFocus"
ORDER BY "START";
!

echo "Exported KnowledgeC Application Usage to knowledgeC_application_usage.csv"

sqlite3 $1 <<!
.headers on
.mode csv
.output knowledgeC_safary_browsing.csv
SELECT
  DATETIME(ZOBJECT.ZCREATIONDATE + 978307200, 'UNIXEPOCH') AS "ENTRY CREATION",
CASE ZOBJECT.ZSTARTDAYOFWEEK
WHEN "1" THEN "Sunday"
WHEN "2" THEN "Monday"
WHEN "3" THEN "Tuesday"
WHEN "4" THEN "Wednesday"
WHEN "5" THEN "Thursday"
WHEN "6" THEN "Friday"
WHEN "7" THEN "Saturday"
END "DAY OF WEEK",
ZOBJECT.ZVALUESTRING AS "URL",
ZSOURCE.ZBUNDLEID AS "BUNDLE ID",
ZOBJECT.ZSTREAMNAME AS "STREAM NAME",
ZOBJECT.Z_PK AS "ZOBJECT TABLE ID"
FROM
  ZOBJECT
  LEFT JOIN
     ZSTRUCTUREDMETADATA
     ON ZOBJECT.ZSTRUCTUREDMETADATA = ZSTRUCTUREDMETADATA.Z_PK
  LEFT JOIN
     ZSOURCE
     ON ZOBJECT.ZSOURCE = ZSOURCE.Z_PK
WHERE
  ZSTREAMNAME IS "/safari/history"
ORDER BY "ENTRY CREATION";
!

echo "Exported Exported KnowledgeC Safari Browsing to knowledgeC_safary_browsing.csv"

sqlite3 $1 <<!
.headers on
.mode csv
.output knowledgeC_app_activities.csv
SELECT
   DATETIME(ZOBJECT.ZCREATIONDATE + 978307200, 'UNIXEPOCH') AS "ENTRY CREATION",
CASE ZOBJECT.ZSTARTDAYOFWEEK
WHEN "1" THEN "Sunday"
WHEN "2" THEN "Monday"
WHEN "3" THEN "Tuesday"
WHEN "4" THEN "Wednesday"
WHEN "5" THEN "Thursday"
WHEN "6" THEN "Friday"
WHEN "7" THEN "Saturday"
END "DAY OF WEEK",
ZOBJECT.ZVALUESTRING AS "BUNDLE ID",
ZSTRUCTUREDMETADATA.Z_DKAPPLICATIONACTIVITYMETADATAKEY__ACTIVITYTYPE AS "ACTIVITY TYPE",
ZSTRUCTUREDMETADATA.Z_DKAPPLICATIONACTIVITYMETADATAKEY__TITLE AS "TITLE",
DATETIME(ZSTRUCTUREDMETADATA.Z_DKAPPLICATIONACTIVITYMETADATAKEY__EXPIRATIONDATE + 978307200, 'UNIXEPOCH') AS "EXPIRATION DATE",
ZSTRUCTUREDMETADATA.Z_DKAPPLICATIONACTIVITYMETADATAKEY__ITEMRELATEDCONTENTURL AS "CONTENT URL",
ZOBJECT.ZSTREAMNAME AS "STREAM NAME",
ZOBJECT.Z_PK AS "ZOBJECT TABLE ID"
FROM
   ZOBJECT
   LEFT JOIN
      ZSTRUCTUREDMETADATA
      ON ZOBJECT.ZSTRUCTUREDMETADATA = ZSTRUCTUREDMETADATA.Z_PK
   LEFT JOIN
      ZSOURCE
      ON ZOBJECT.ZSOURCE = ZSOURCE.Z_PK
WHERE
   ZSTREAMNAME IS "/app/activity"
ORDER BY "ENTRY CREATION";
!

echo "Exported Exported App Activities Browsing to knowledgeC_app_activities.csv"
INSERT INTO organization (ORGANIZATION_ID, ORGANIZATION_NAME)
SELECT DISTINCT
       "ORGANIZATION_ID"::integer,
       "ORGANIZATION_NAME"
FROM staging_shelter
WHERE "ORGANIZATION_ID" <> '' AND "ORGANIZATION_ID" IS NOT NULL;

SELECT table_schema,
       column_name,
       data_type,
       ordinal_position
FROM information_schema.columns
WHERE table_name = 'location'
ORDER BY table_schema, ordinal_position;

SELECT count(*) FROM public.location WHERE LOCATION_ID = 1125;

SELECT (SELECT COUNT(*) FROM public.location) AS rows_currently_in_location,
       COUNT(*)                               AS distinct_rows_for_1125
FROM (
  SELECT DISTINCT
         "LOCATION_ID",
         "ORGANIZATION_ID",
         "LOCATION_NAME",
         "LOCATION_ADDRESS",
         "LOCATION_POSTAL_CODE",
         "LOCATION_CITY",
         "LOCATION_PROVINCE"
  FROM staging_shelter
  WHERE "LOCATION_ID" = '1125'
) AS d;

SELECT DISTINCT
       "LOCATION_ID",
       "ORGANIZATION_ID",
       "LOCATION_NAME",
       "LOCATION_ADDRESS",
       "LOCATION_POSTAL_CODE",
       "LOCATION_CITY",
       "LOCATION_PROVINCE"
FROM staging_shelter
WHERE "LOCATION_ID" = '1125'
ORDER BY "ORGANIZATION_ID";

SELECT "ORGANIZATION_ID",
       MIN("OCCUPANCY_DATE") AS first_seen,
       MAX("OCCUPANCY_DATE") AS last_seen,
       COUNT(*)              AS days_reported
FROM staging_shelter
WHERE "LOCATION_ID" = '1125'
GROUP BY "ORGANIZATION_ID"
ORDER BY first_seen;

SELECT "ORGANIZATION_ID",
       "PROGRAM_ID",
       COUNT(DISTINCT "OCCUPANCY_DATE") AS calendar_days,
       MIN("OCCUPANCY_DATE")            AS first_seen,
       MAX("OCCUPANCY_DATE")            AS last_seen
FROM staging_shelter
WHERE "LOCATION_ID" = '1125'
GROUP BY "ORGANIZATION_ID", "PROGRAM_ID"
ORDER BY "ORGANIZATION_ID", MIN("OCCUPANCY_DATE");

SELECT "PROGRAM_ID",
       COUNT(DISTINCT "ORGANIZATION_ID") AS orgs
FROM staging_shelter
GROUP BY "PROGRAM_ID"
HAVING COUNT(DISTINCT "ORGANIZATION_ID") > 1
ORDER BY orgs DESC;

SELECT "LOCATION_ID",
       COUNT(*) AS distinct_detail_rows
FROM (
  SELECT DISTINCT
         "LOCATION_ID",
         "LOCATION_NAME",
         "LOCATION_ADDRESS",
         "LOCATION_POSTAL_CODE",
         "LOCATION_CITY",
         "LOCATION_PROVINCE"
  FROM staging_shelter
) AS d
GROUP BY "LOCATION_ID"
HAVING COUNT(*) > 1
ORDER BY distinct_detail_rows DESC;

SELECT "LOCATION_ID",
       "ORGANIZATION_ID",
       "LOCATION_NAME",
       "LOCATION_ADDRESS",
       "LOCATION_CITY",
       COUNT(DISTINCT "OCCUPANCY_DATE") AS calendar_days,
       MIN("OCCUPANCY_DATE")            AS first_seen,
       MAX("OCCUPANCY_DATE")            AS last_seen
FROM staging_shelter
WHERE "PROGRAM_ID" = '18891'
GROUP BY "LOCATION_ID", "ORGANIZATION_ID",
         "LOCATION_NAME", "LOCATION_ADDRESS", "LOCATION_CITY"
ORDER BY MIN("OCCUPANCY_DATE");

SELECT "LOCATION_ID",
       "LOCATION_NAME",
       "ORGANIZATION_ID",
       "PROGRAM_ID",
       "PROGRAM_NAME",
       COUNT(DISTINCT "OCCUPANCY_DATE") AS calendar_days,
       MIN("OCCUPANCY_DATE")            AS first_seen,
       MAX("OCCUPANCY_DATE")            AS last_seen
FROM staging_shelter
WHERE "LOCATION_ID" IN ('1761', '1155')
GROUP BY "LOCATION_ID", "LOCATION_NAME", "ORGANIZATION_ID",
         "PROGRAM_ID", "PROGRAM_NAME"
ORDER BY "LOCATION_ID", MIN("OCCUPANCY_DATE");

DROP TABLE IF EXISTS daily_occupancy;

DROP TABLE IF EXISTS program;

DROP TABLE IF EXISTS location;

CREATE TABLE location (
  location_id           integer PRIMARY KEY,
  location_name         text,
  location_address      text,
  location_postal_code  text,
  location_city         text,
  location_province     text
);

CREATE TABLE program (
  program_id              integer PRIMARY KEY,
  location_id             integer NOT NULL REFERENCES location(location_id),
  organization_id         integer NOT NULL REFERENCES organization(organization_id),
  program_name            text,
  sector                  text,
  program_model           text,
  overnight_service_type  text,
  program_area            text,
  capacity_type           text
);

INSERT INTO location (location_id, location_name, location_address,
                      location_postal_code, location_city, location_province)
SELECT DISTINCT
       "LOCATION_ID"::integer,
       "LOCATION_NAME",
       "LOCATION_ADDRESS",
       "LOCATION_POSTAL_CODE",
       "LOCATION_CITY",
       "LOCATION_PROVINCE"
FROM staging_shelter
WHERE "LOCATION_ID" <> '' AND "LOCATION_ID" IS NOT NULL;

SELECT COUNT(*) FROM location;
SELECT COUNT(DISTINCT "LOCATION_ID") FROM staging_shelter;

SELECT
  (SELECT COUNT(*)
     FROM staging_shelter
    WHERE "PROGRAM_ID" <> '' AND "PROGRAM_ID" IS NOT NULL
      AND (COALESCE("LOCATION_ID", '') = '' OR COALESCE("ORGANIZATION_ID", '') = '')
  ) AS rows_missing_location_or_org,
  (SELECT COUNT(*) FROM (
      SELECT "PROGRAM_ID"
        FROM (
          SELECT DISTINCT "PROGRAM_ID", "LOCATION_ID", "ORGANIZATION_ID", "PROGRAM_NAME",
                 "SECTOR", "PROGRAM_MODEL", "OVERNIGHT_SERVICE_TYPE", "PROGRAM_AREA",
                 "CAPACITY_TYPE"
            FROM staging_shelter
           WHERE "PROGRAM_ID" <> '' AND "PROGRAM_ID" IS NOT NULL
        ) d
       GROUP BY "PROGRAM_ID"
      HAVING COUNT(*) > 1
   ) x) AS programs_with_multiple_versions;

INSERT INTO program (
    program_id, location_id, organization_id, program_name, sector,
    program_model, overnight_service_type, program_area, capacity_type
)
SELECT DISTINCT ON ("PROGRAM_ID")
       "PROGRAM_ID"::integer,
       "LOCATION_ID"::integer,
       "ORGANIZATION_ID"::integer,
       "PROGRAM_NAME",
       "SECTOR",
       "PROGRAM_MODEL",
       "OVERNIGHT_SERVICE_TYPE",
       "PROGRAM_AREA",
       "CAPACITY_TYPE"
  FROM staging_shelter
 WHERE "PROGRAM_ID" <> '' AND "PROGRAM_ID" IS NOT NULL
   AND "LOCATION_ID" <> '' AND "LOCATION_ID" IS NOT NULL
   AND "ORGANIZATION_ID" <> '' AND "ORGANIZATION_ID" IS NOT NULL
 ORDER BY "PROGRAM_ID", "OCCUPANCY_DATE" DESC;

SELECT
  (SELECT COUNT(*) FROM program) AS programs_loaded,
  (SELECT COUNT(DISTINCT "PROGRAM_ID") FROM staging_shelter
    WHERE "PROGRAM_ID" <> '' AND "PROGRAM_ID" IS NOT NULL) AS programs_in_staging,
  (SELECT location_id FROM program WHERE program_id = 18891) AS program_18891_location;

INSERT INTO daily_occupancy (
  program_id, occupancy_date, service_user_count,
  capacity_actual_bed, capacity_funding_bed,
  occupied_beds, unoccupied_beds, unavailable_beds,
  capacity_actual_room, capacity_funding_room,
  occupied_rooms, unoccupied_rooms, unavailable_rooms,
  occupancy_rate_beds, occupancy_rate_rooms)
SELECT
  "PROGRAM_ID"::integer,
  "OCCUPANCY_DATE"::date,
  NULLIF("SERVICE_USER_COUNT", '')::integer,
  NULLIF("CAPACITY_ACTUAL_BED", '')::integer,
  NULLIF("CAPACITY_FUNDING_BED", '')::integer,
  NULLIF("OCCUPIED_BEDS", '')::integer,
  NULLIF("UNOCCUPIED_BEDS", '')::integer,
  NULLIF("UNAVAILABLE_BEDS", '')::integer,
  NULLIF("CAPACITY_ACTUAL_ROOM", '')::integer,
  NULLIF("CAPACITY_FUNDING_ROOM", '')::integer,
  NULLIF("OCCUPIED_ROOMS", '')::integer,
  NULLIF("UNOCCUPIED_ROOMS", '')::integer,
  NULLIF("UNAVAILABLE_ROOMS", '')::integer,
  NULLIF("OCCUPANCY_RATE_BEDS", '')::numeric,
  NULLIF("OCCUPANCY_RATE_ROOMS", '')::numeric
FROM staging_shelter
WHERE "PROGRAM_ID" <> '' AND "PROGRAM_ID" IS NOT NULL;

SELECT COUNT(*) FROM daily_occupancy;

SELECT COUNT(*) FROM staging_shelter;




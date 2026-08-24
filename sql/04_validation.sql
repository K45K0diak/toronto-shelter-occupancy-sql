SELECT
  (SELECT COUNT(*) FROM staging_shelter)                    AS staging_rows,
  (SELECT COUNT(*) FROM daily_occupancy)                    AS daily_rows,
  (SELECT COUNT(DISTINCT "ORGANIZATION_ID") FROM staging_shelter) AS staging_orgs,
  (SELECT COUNT(*) FROM organization)                       AS org_rows,
  (SELECT COUNT(DISTINCT "LOCATION_ID") FROM staging_shelter) AS staging_locs,
  (SELECT COUNT(*) FROM location)                           AS loc_rows,
  (SELECT COUNT(DISTINCT "PROGRAM_ID") FROM staging_shelter)  AS staging_progs,
  (SELECT COUNT(*) FROM program)                            AS prog_rows;

SELECT organization_id FROM organization
GROUP BY organization_id HAVING COUNT(*) > 1;

SELECT location_id FROM location
GROUP BY location_id HAVING COUNT(*) > 1;

SELECT program_id FROM program
GROUP BY program_id HAVING COUNT(*) > 1;

SELECT
  (SELECT COUNT(*) FROM program p
     LEFT JOIN location l ON l.location_id = p.location_id
    WHERE l.location_id IS NULL)         AS orphan_programs_no_location,
  (SELECT COUNT(*) FROM program p
     LEFT JOIN organization o ON o.organization_id = p.organization_id
    WHERE o.organization_id IS NULL)     AS orphan_programs_no_organization,
  (SELECT COUNT(*) FROM daily_occupancy d
     LEFT JOIN program p ON p.program_id = d.program_id
    WHERE p.program_id IS NULL)          AS orphan_daily;

SELECT program_id, occupancy_date, COUNT(*) AS records
FROM daily_occupancy
GROUP BY program_id, occupancy_date
HAVING COUNT(*) > 1
ORDER BY records DESC;

SELECT o.organization_name, l.location_name, l.location_address,
       p.program_name, p.sector, d.occupancy_date, d.occupied_beds
FROM daily_occupancy d
JOIN program      p ON p.program_id      = d.program_id
JOIN location     l ON l.location_id     = p.location_id
JOIN organization o ON o.organization_id = l.organization_id
LIMIT 5;

SELECT o.organization_name, l.location_name, l.location_address,
       p.program_name, p.sector, d.occupancy_date, d.occupied_beds
  FROM daily_occupancy d
  JOIN program      p ON p.program_id      = d.program_id
  JOIN location     l ON l.location_id     = p.location_id
  JOIN organization o ON o.organization_id = p.organization_id
 LIMIT 5;

SELECT
  COUNT(*)                                          AS total,
  COUNT(*) FILTER (WHERE occupied_beds  IS NULL)    AS null_beds,
  COUNT(*) FILTER (WHERE occupied_rooms IS NULL)    AS null_rooms,
  COUNT(*) FILTER (WHERE occupancy_date IS NULL)    AS null_dates
FROM daily_occupancy;

SELECT p.capacity_type,
       COUNT(*) FILTER (WHERE d.occupied_beds  IS NOT NULL) AS has_beds,
       COUNT(*) FILTER (WHERE d.occupied_rooms IS NOT NULL) AS has_rooms
FROM daily_occupancy d
JOIN program p ON p.program_id = d.program_id
GROUP BY p.capacity_type;

SELECT MIN(occupancy_date) AS earliest, MAX(occupancy_date) AS latest,
       MIN(occupied_beds)  AS min_beds,  MAX(occupied_beds)  AS max_beds,
       MIN(occupancy_rate_beds) AS min_rate, MAX(occupancy_rate_beds) AS max_rate
FROM daily_occupancy;
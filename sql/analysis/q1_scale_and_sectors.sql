/* ============================================================
   Q1 — How many organizations, locations and programs are
        active, and how do programs split across sectors?
   Techniques: COUNT, DISTINCT, GROUP BY
   Runs against: organization, location, program
   ============================================================ */
 
-- Q1a — the headline counts, one row.
SELECT (SELECT COUNT(*) FROM organization)            AS organizations,
       (SELECT COUNT(*) FROM location)                AS locations,
       (SELECT COUNT(*) FROM program)                 AS programs,
       (SELECT COUNT(DISTINCT sector) FROM program)   AS sectors;
 
-- Q1b — the split. Percentages use a window total so the
-- column sums to 100 without a second pass over the table.
SELECT p.sector,
       COUNT(*)                          AS programs,
       COUNT(DISTINCT p.location_id)     AS locations,
       COUNT(DISTINCT p.organization_id) AS organizations,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_programs
FROM program p
GROUP BY p.sector
ORDER BY programs DESC;
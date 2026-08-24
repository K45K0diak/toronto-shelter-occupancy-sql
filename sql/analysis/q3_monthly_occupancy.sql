/* ============================================================
   Q3 — How does system-wide bed occupancy move month to month?
   Techniques: date handling (date_trunc), AVG
   Two different averages on purpose:
     avg_program_rate — unweighted mean of program rates
     system_rate      — capacity-weighted (beds / beds)
   A 12-bed program and a 300-bed program count equally in the
   first and not in the second. Report the second; show both.
   ============================================================ */
 
SELECT date_trunc('month', d.occupancy_date)::date AS month,
       COUNT(DISTINCT d.program_id)                AS programs_reporting,
       SUM(d.occupied_beds)                        AS bed_nights_occupied,
       SUM(d.capacity_actual_bed)                  AS bed_nights_available,
       ROUND(AVG(d.occupancy_rate_beds), 2)        AS avg_program_rate,
       ROUND(100.0 * SUM(d.occupied_beds)
             / NULLIF(SUM(d.capacity_actual_bed), 0), 2) AS system_rate
FROM daily_occupancy d
WHERE d.occupancy_rate_beds IS NOT NULL   -- excludes room-based programs
GROUP BY 1
ORDER BY 1;
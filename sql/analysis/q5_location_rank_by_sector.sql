/* ============================================================
   Q5 — Rank locations by average occupancy within each sector.
   Techniques: RANK() OVER (PARTITION BY ...)
   A location can host programs in more than one sector, so the
   grain is location x sector, not location. RANK leaves gaps
   after ties (1,1,3) — that is intended; swap to DENSE_RANK
   only if you want 1,1,2.
   The 30-day floor keeps a program that reported four nights
   at 100% from outranking one that held 99% for a year.
   ============================================================ */
 
SELECT p.sector,
       l.location_name,
       l.location_city,
       COUNT(DISTINCT p.program_id)         AS programs,
       COUNT(*)                             AS reported_days,
       ROUND(AVG(d.occupancy_rate_beds), 2) AS avg_occupancy,
       RANK() OVER (PARTITION BY p.sector
                    ORDER BY AVG(d.occupancy_rate_beds) DESC) AS rank_in_sector
FROM daily_occupancy d
JOIN program  p ON p.program_id  = d.program_id
JOIN location l ON l.location_id = p.location_id
WHERE d.occupancy_rate_beds IS NOT NULL
GROUP BY p.sector, l.location_id, l.location_name, l.location_city
HAVING COUNT(*) >= 30
ORDER BY p.sector, rank_in_sector;
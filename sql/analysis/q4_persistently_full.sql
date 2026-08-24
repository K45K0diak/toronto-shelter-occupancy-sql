/* ============================================================
   Q4 — Which programs sit above 95% occupancy on more than
        half their reported days?
   Techniques: HAVING, conditional aggregation (FILTER)
   The FILTER clause counts a subset of rows inside the same
   aggregation pass; HAVING then tests that count against half
   the group's own row count, so short-reporting programs are
   judged on their own denominator.
   ============================================================ */
 
SELECT p.program_id,
       p.program_name,
       p.sector,
       o.organization_name,
       COUNT(*)                                              AS reported_days,
       COUNT(*) FILTER (WHERE d.occupancy_rate_beds >= 95)    AS days_at_95_plus,
       ROUND(100.0 * COUNT(*) FILTER (WHERE d.occupancy_rate_beds >= 95)
             / COUNT(*), 1)                                   AS pct_days,
       ROUND(AVG(d.occupancy_rate_beds), 1)                   AS avg_rate
FROM daily_occupancy d
JOIN program      p ON p.program_id      = d.program_id
JOIN organization o ON o.organization_id = p.organization_id
WHERE d.occupancy_rate_beds IS NOT NULL
GROUP BY p.program_id, p.program_name, p.sector, o.organization_name
HAVING COUNT(*) FILTER (WHERE d.occupancy_rate_beds >= 95) > COUNT(*) / 2.0
ORDER BY pct_days DESC, reported_days DESC;
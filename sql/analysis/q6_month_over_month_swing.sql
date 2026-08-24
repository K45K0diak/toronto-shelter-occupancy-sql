/* ============================================================
   Q6 — Which programs show the sharpest month-over-month swing?
   Techniques: CTE + LAG()
   monthly  — collapse days to one row per program per month
   stepped  — LAG pulls the previous month onto the same row
   The last WHERE line is the one that matters: LAG returns the
   previous row that EXISTS, which for a program that stopped
   reporting for three months is not the previous month. Without
   that guard, a July-to-November gap gets reported as a
   month-over-month change.
   ============================================================ */
 
WITH monthly AS (
    SELECT d.program_id,
           date_trunc('month', d.occupancy_date)::date AS month,
           AVG(d.occupancy_rate_beds)                  AS avg_rate,
           COUNT(*)                                    AS days_reported
    FROM daily_occupancy d
    WHERE d.occupancy_rate_beds IS NOT NULL
    GROUP BY 1, 2
    HAVING COUNT(*) >= 15          -- half a month of evidence, minimum
),
stepped AS (
    SELECT m.*,
           LAG(m.avg_rate) OVER (PARTITION BY m.program_id ORDER BY m.month) AS prev_rate,
           LAG(m.month)    OVER (PARTITION BY m.program_id ORDER BY m.month) AS prev_month
    FROM monthly m
)
SELECT p.program_name,
       p.sector,
       s.prev_month,
       s.month,
       ROUND(s.prev_rate, 1)              AS prev_rate,
       ROUND(s.avg_rate, 1)               AS this_rate,
       ROUND(s.avg_rate - s.prev_rate, 1) AS change_pts
FROM stepped s
JOIN program p ON p.program_id = s.program_id
WHERE s.prev_rate IS NOT NULL
  AND s.prev_month = s.month - INTERVAL '1 month'   -- consecutive months only
ORDER BY ABS(s.avg_rate - s.prev_rate) DESC
LIMIT 15;
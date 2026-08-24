/* ============================================================
   Q2 — Which ten organizations operate the most programs?
   Techniques: JOIN, GROUP BY, LIMIT
   Two hops only: organization -> program.
   program carries organization_id directly, so location is not
   in the path. This is the corrected model doing its job.
   ============================================================ */
 
SELECT o.organization_name,
       COUNT(p.program_id)           AS programs,
       COUNT(DISTINCT p.location_id) AS locations,
       COUNT(DISTINCT p.sector)      AS sectors
FROM organization o
JOIN program p ON p.organization_id = o.organization_id
GROUP BY o.organization_id, o.organization_name
ORDER BY programs DESC, o.organization_name
LIMIT 10;
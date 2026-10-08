-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Plans
-- ============================================================

DROP TABLE IF EXISTS stg_plans;

CREATE TABLE stg_plans AS
SELECT
    TRIM(plan_id) AS plan_id,
    TRIM(plan_name) AS plan_name,
    CAST(monthly_price AS NUMERIC(10,2)) AS monthly_price,
    CAST(annual_discount AS NUMERIC(5,4)) AS annual_discount
FROM plans;

-- ============================================================
-- Basic staging validation
-- ============================================================

SELECT
    COUNT(*) AS total_plans,
    COUNT(DISTINCT plan_id) AS unique_plans,
    MIN(monthly_price) AS min_monthly_price,
    MAX(monthly_price) AS max_monthly_price
FROM stg_plans;
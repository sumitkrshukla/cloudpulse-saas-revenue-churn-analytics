
-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Feature Usage by Segment
-- Grain: 1 row = 1 month per customer segment
-- ============================================================

SELECT
    DATE_TRUNC('month', u.usage_date)::DATE AS month_start,
    c.customer_segment,

    COUNT(DISTINCT u.customer_id) AS customers_with_usage,

    SUM(u.feature_usage) AS total_feature_usage,

    ROUND(
        AVG(u.feature_usage::NUMERIC),
        2
    ) AS avg_feature_usage_per_record,

    ROUND(
        AVG(u.session_minutes::NUMERIC),
        2
    ) AS avg_session_minutes_per_record

FROM stg_usage u

INNER JOIN stg_customers c
    ON u.customer_id = c.customer_id

GROUP BY
    DATE_TRUNC('month', u.usage_date)::DATE,
    c.customer_segment

ORDER BY
    month_start,
    c.customer_segment;

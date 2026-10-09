-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Engagement by Customer Segment
-- Grain: 1 row = 1 month per customer segment
-- ============================================================

SELECT
    DATE_TRUNC('month', u.usage_date)::DATE AS month_start,
    c.customer_segment,

    COUNT(DISTINCT u.customer_id) AS customers_with_usage,

    ROUND(
        AVG(u.active_users),
        2
    ) AS avg_daily_active_users,

    SUM(u.login_count) AS total_logins,

    SUM(u.feature_usage) AS total_feature_usage,

    SUM(u.session_minutes) AS total_session_minutes

FROM stg_usage u

INNER JOIN stg_customers c
    ON u.customer_id = c.customer_id

GROUP BY
    DATE_TRUNC('month', u.usage_date)::DATE,
    c.customer_segment

ORDER BY
    month_start,
    c.customer_segment;
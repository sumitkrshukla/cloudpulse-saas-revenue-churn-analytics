
-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Monthly Customer Engagement
-- Grain: 1 row = 1 customer per month
-- ============================================================

SELECT
    DATE_TRUNC('month', usage_date)::DATE AS month_start,
    customer_id,

    ROUND(
        AVG(active_users),
        2
    ) AS avg_daily_active_users,

    SUM(login_count) AS total_logins,

    SUM(feature_usage) AS total_feature_usage,

    SUM(session_minutes) AS total_session_minutes,

    COUNT(*) AS usage_days

FROM stg_usage

GROUP BY
    DATE_TRUNC('month', usage_date)::DATE,
    customer_id

ORDER BY
    month_start,
    customer_id;

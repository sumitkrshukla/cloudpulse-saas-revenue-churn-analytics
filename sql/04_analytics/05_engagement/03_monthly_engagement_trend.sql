-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Monthly Engagement Trend
-- Grain: 1 row = 1 month
-- ============================================================

SELECT
    DATE_TRUNC('month', usage_date)::DATE AS month_start,

    COUNT(DISTINCT customer_id) AS customers_with_usage,

    SUM(login_count) AS total_logins,

    SUM(feature_usage) AS total_feature_usage,

    SUM(session_minutes) AS total_session_minutes,

    ROUND(
        AVG(active_users),
        2
    ) AS avg_daily_active_users,

    ROUND(
        AVG(login_count::NUMERIC),
        2
    ) AS avg_daily_logins_per_record

FROM stg_usage

GROUP BY
    DATE_TRUNC('month', usage_date)::DATE

ORDER BY
    month_start;
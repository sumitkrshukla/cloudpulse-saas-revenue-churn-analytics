
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Engagement Data Quality
-- Purpose: Validate monthly customer engagement aggregation
-- Grain: 1 row = 1 customer-month with recorded usage
-- ============================================================

WITH customer_monthly_usage AS (
    SELECT
        DATE_TRUNC('month', usage_date)::DATE AS month_start,
        customer_id,
        SUM(login_count) AS total_logins,
        SUM(feature_usage) AS total_feature_usage,
        SUM(session_minutes) AS total_session_minutes,
        COUNT(*) AS usage_days
    FROM stg_usage
    GROUP BY
        DATE_TRUNC('month', usage_date)::DATE,
        customer_id
),

quality_checks AS (
    SELECT
        COUNT(*) AS total_rows,

        COUNT(DISTINCT (customer_id, month_start))
            AS unique_customer_months,

        COUNT(*) FILTER (
            WHERE total_logins < 0
               OR total_feature_usage < 0
               OR total_session_minutes < 0
        ) AS negative_metric_rows,

        COUNT(*) FILTER (
            WHERE usage_days < 1
               OR usage_days > 31
        ) AS invalid_usage_day_rows,

        COUNT(*) FILTER (
            WHERE month_start < DATE '2024-01-01'
               OR month_start > DATE '2025-12-01'
        ) AS out_of_range_rows,

        MIN(month_start) AS first_month,
        MAX(month_start) AS last_month

    FROM customer_monthly_usage
)

SELECT
    total_rows,
    unique_customer_months,
    total_rows - unique_customer_months AS duplicate_rows,
    negative_metric_rows,
    invalid_usage_day_rows,
    out_of_range_rows,
    first_month,
    last_month,

    CASE
        WHEN total_rows = unique_customer_months
         AND negative_metric_rows = 0
         AND invalid_usage_day_rows = 0
         AND out_of_range_rows = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status

FROM quality_checks;

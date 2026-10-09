
-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Engagement vs Churn
-- Grain: 1 row = 1 month per engagement group
-- Outcome: Customer churn in the following month
-- ============================================================

WITH customer_monthly_engagement AS (
    SELECT
        DATE_TRUNC('month', usage_date)::DATE AS month_start,
        customer_id,
        SUM(login_count) AS total_logins,
        SUM(feature_usage) AS total_feature_usage,
        SUM(session_minutes) AS total_session_minutes
    FROM stg_usage
    GROUP BY
        DATE_TRUNC('month', usage_date)::DATE,
        customer_id
),

eligible_customers AS (
    SELECT
        e.month_start,
        e.customer_id,
        e.total_logins,
        e.total_feature_usage,
        e.total_session_minutes
    FROM customer_monthly_engagement e
    INNER JOIN customer_churn current_month
        ON current_month.customer_id = e.customer_id
        AND current_month.month_end =
            (e.month_start + INTERVAL '1 month'
             - INTERVAL '1 day')::DATE
    WHERE current_month.ending_active = 1
),

engagement_groups AS (
    SELECT
        month_start,
        customer_id,
        total_logins,
        total_feature_usage,
        total_session_minutes,

        NTILE(3) OVER (
            PARTITION BY month_start
            ORDER BY total_logins, customer_id
        ) AS engagement_tertile

    FROM eligible_customers
),

next_month_outcomes AS (
    SELECT
        e.month_start,
        e.customer_id,
        e.total_logins,
        e.total_feature_usage,
        e.total_session_minutes,
        e.engagement_tertile,
        next_month.starting_active,
        next_month.churned_customer
    FROM engagement_groups e
    INNER JOIN customer_churn next_month
        ON next_month.customer_id = e.customer_id
        AND next_month.month_end =
            (e.month_start + INTERVAL '2 months'
             - INTERVAL '1 day')::DATE
)

SELECT
    month_start,

    CASE engagement_tertile
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
    END AS engagement_group,

    COUNT(*) AS customers_evaluated,

    ROUND(
        AVG(total_logins::NUMERIC),
        2
    ) AS avg_monthly_logins,

    ROUND(
        AVG(total_feature_usage::NUMERIC),
        2
    ) AS avg_feature_usage,

    COUNT(*) FILTER (
        WHERE starting_active = 1
          AND churned_customer = 1
    ) AS churned_customers,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE starting_active = 1
              AND churned_customer = 1
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE starting_active = 1
            ),
            0
        ),
        2
    ) AS next_month_churn_rate_pct

FROM next_month_outcomes

GROUP BY
    month_start,
    engagement_tertile

ORDER BY
    month_start,
    engagement_tertile;

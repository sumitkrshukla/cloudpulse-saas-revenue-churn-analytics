
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Engagement vs Churn
-- Purpose: Validate engagement cohort and next-month outcomes
-- ============================================================

WITH customer_monthly_engagement AS (
    SELECT
        DATE_TRUNC('month', usage_date)::DATE AS month_start,
        customer_id,
        SUM(login_count) AS total_logins
    FROM stg_usage
    GROUP BY
        DATE_TRUNC('month', usage_date)::DATE,
        customer_id
),

eligible_customers AS (
    SELECT
        e.month_start,
        e.customer_id,
        e.total_logins
    FROM customer_monthly_engagement e
    INNER JOIN customer_churn c
        ON c.customer_id = e.customer_id
       AND c.month_end = (
            e.month_start
            + INTERVAL '1 month'
            - INTERVAL '1 day'
       )::DATE
    WHERE c.ending_active = 1
),

engagement_groups AS (
    SELECT
        month_start,
        customer_id,
        total_logins,
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
        e.engagement_tertile,
        n.month_end AS outcome_month,
        n.starting_active,
        n.ending_active,
        n.churned_customer
    FROM engagement_groups e
    INNER JOIN customer_churn n
        ON n.customer_id = e.customer_id
       AND n.month_end = (
            e.month_start
            + INTERVAL '2 months'
            - INTERVAL '1 day'
       )::DATE
)

SELECT
    COUNT(*) AS total_observations,

    COUNT(DISTINCT (month_start, customer_id))
        AS unique_customer_months,

    COUNT(*) - COUNT(
        DISTINCT (month_start, customer_id)
    ) AS duplicate_observations,

    COUNT(*) FILTER (
        WHERE outcome_month <> (
            month_start
            + INTERVAL '2 months'
            - INTERVAL '1 day'
        )::DATE
    ) AS misaligned_outcome_months,

    COUNT(*) FILTER (
        WHERE engagement_tertile NOT IN (1, 2, 3)
    ) AS invalid_engagement_groups,

    COUNT(*) FILTER (
        WHERE starting_active NOT IN (0, 1)
           OR ending_active NOT IN (0, 1)
           OR churned_customer NOT IN (0, 1)
    ) AS invalid_outcome_flags

FROM next_month_outcomes;

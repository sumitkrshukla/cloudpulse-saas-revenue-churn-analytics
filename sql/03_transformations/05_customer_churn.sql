-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Customer Churn
-- Grain: 1 row = 1 customer x 1 month
-- ============================================================

DROP TABLE IF EXISTS customer_churn;

CREATE TABLE customer_churn AS

WITH month_ends AS (

    SELECT
        (DATE_TRUNC('month', month_date)
         + INTERVAL '1 month - 1 day')::DATE AS month_end

    FROM GENERATE_SERIES(
        DATE '2024-01-01',
        DATE '2025-12-01',
        INTERVAL '1 month'
    ) AS month_date
),

customer_months AS (

    SELECT
        c.customer_id,
        m.month_end

    FROM stg_customers c

    CROSS JOIN month_ends m

    WHERE c.signup_date <= m.month_end
),

monthly_status AS (

    SELECT
        cm.customer_id,
        cm.month_end,

        mr.mrr,

        mr.is_active_customer,

        LAG(mr.is_active_customer) OVER (
            PARTITION BY cm.customer_id
            ORDER BY cm.month_end
        ) AS previous_month_active

    FROM customer_months cm

    LEFT JOIN monthly_revenue mr
        ON cm.customer_id = mr.customer_id
        AND cm.month_end = mr.month_end
)

SELECT
    customer_id,
    month_end,

    COALESCE(previous_month_active, 0) AS starting_active,

    COALESCE(is_active_customer, 0) AS ending_active,

    CASE
        WHEN COALESCE(previous_month_active, 0) = 0
             AND COALESCE(is_active_customer, 0) = 1
            THEN 1
        ELSE 0
    END AS new_customer,

    CASE
        WHEN COALESCE(previous_month_active, 0) = 1
             AND COALESCE(is_active_customer, 0) = 0
            THEN 1
        ELSE 0
    END AS churned_customer

FROM monthly_status;
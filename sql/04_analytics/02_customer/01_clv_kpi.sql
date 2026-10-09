-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Customer Lifetime Value (CLV)
-- Grain: 1 row = 1 customer
-- ============================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(mrr) AS total_mrr
    FROM monthly_revenue
    GROUP BY customer_id
),

customer_retention AS (
    SELECT
        customer_id,
        AVG(
            CASE
                WHEN starting_active = 1
                THEN 1.0 - (
                    churned_customer::NUMERIC
                    / NULLIF(starting_active, 0)
                )
            END
        ) AS avg_retention_rate
    FROM customer_churn
    GROUP BY customer_id
)

SELECT
    cr.customer_id,

    ROUND(
        cr.total_mrr,
        2
    ) AS total_observed_mrr,

    ROUND(
        COALESCE(crt.avg_retention_rate, 0),
        4
    ) AS avg_retention_rate,

    ROUND(
        cr.total_mrr
        * COALESCE(crt.avg_retention_rate, 0),
        2
    ) AS clv

FROM customer_revenue cr

LEFT JOIN customer_retention crt
    ON cr.customer_id = crt.customer_id

ORDER BY clv DESC;
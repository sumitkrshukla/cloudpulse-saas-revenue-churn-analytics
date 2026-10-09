-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Monthly Revenue Retention
-- Grain: 1 row = 1 customer x 1 month
-- ============================================================

DROP TABLE IF EXISTS monthly_retention;

CREATE TABLE monthly_retention AS

WITH monthly_mrr AS (

    SELECT
        customer_id,
        month_end,
        mrr AS ending_mrr,

        LAG(mrr) OVER (
            PARTITION BY customer_id
            ORDER BY month_end
        ) AS beginning_mrr

    FROM monthly_revenue
),

retention_metrics AS (

    SELECT
        customer_id,
        month_end,

        COALESCE(beginning_mrr, 0) AS beginning_mrr,
        COALESCE(ending_mrr, 0) AS ending_mrr,

        CASE
            WHEN COALESCE(beginning_mrr, 0) = 0
                 AND COALESCE(ending_mrr, 0) > 0
                THEN ending_mrr
            ELSE 0
        END AS new_mrr,

        CASE
            WHEN COALESCE(beginning_mrr, 0) > 0
                 AND COALESCE(ending_mrr, 0) > beginning_mrr
                THEN ending_mrr - beginning_mrr
            ELSE 0
        END AS expansion_mrr,

        CASE
            WHEN COALESCE(beginning_mrr, 0) > 0
                 AND COALESCE(ending_mrr, 0) > 0
                 AND ending_mrr < beginning_mrr
                THEN beginning_mrr - ending_mrr
            ELSE 0
        END AS contraction_mrr,

        CASE
            WHEN COALESCE(beginning_mrr, 0) > 0
                 AND COALESCE(ending_mrr, 0) = 0
                THEN beginning_mrr
            ELSE 0
        END AS churned_mrr

    FROM monthly_mrr
)

SELECT
    customer_id,
    month_end,
    beginning_mrr,
    new_mrr,
    expansion_mrr,
    contraction_mrr,
    churned_mrr,
    ending_mrr

FROM retention_metrics;
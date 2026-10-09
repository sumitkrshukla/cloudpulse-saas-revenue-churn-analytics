-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Acquisition Channel Performance
-- Grain: 1 row = 1 acquisition channel per month
-- ============================================================

SELECT
    mr.month_end,
    c.acquisition_channel,

    COUNT(DISTINCT mr.customer_id)
        FILTER (
            WHERE mr.is_active_customer = 1
        ) AS active_customers,

    ROUND(
        SUM(
            CASE
                WHEN mr.is_active_customer = 1
                THEN mr.mrr
                ELSE 0
            END
        ),
        2
    ) AS mrr,

    ROUND(
        SUM(
            CASE
                WHEN mr.is_active_customer = 1
                THEN mr.mrr
                ELSE 0
            END
        ) * 12,
        2
    ) AS arr

FROM monthly_revenue mr

INNER JOIN stg_customers c
    ON mr.customer_id = c.customer_id

GROUP BY
    mr.month_end,
    c.acquisition_channel

ORDER BY
    mr.month_end,
    c.acquisition_channel;
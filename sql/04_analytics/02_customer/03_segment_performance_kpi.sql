-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Customer Segment Performance
-- Grain: 1 row = 1 segment per month
-- ============================================================

SELECT
    mr.month_end,
    c.customer_segment,

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
    ) AS arr,

    ROUND(
        SUM(
            CASE
                WHEN mr.is_active_customer = 1
                THEN mr.mrr
                ELSE 0
            END
        )
        / NULLIF(
            COUNT(DISTINCT mr.customer_id)
                FILTER (
                    WHERE mr.is_active_customer = 1
                ),
            0
        ),
        2
    ) AS arpa

FROM monthly_revenue mr

INNER JOIN stg_customers c
    ON mr.customer_id = c.customer_id

GROUP BY
    mr.month_end,
    c.customer_segment

ORDER BY
    mr.month_end,
    c.customer_segment;
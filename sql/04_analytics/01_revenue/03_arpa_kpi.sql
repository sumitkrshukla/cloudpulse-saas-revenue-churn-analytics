-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: ARPA
-- Grain: 1 row = 1 month
-- ============================================================

SELECT
    month_end,

    COUNT(*) FILTER (
        WHERE is_active_customer = 1
    ) AS active_customers,

    ROUND(
        SUM(mrr),
        2
    ) AS mrr,

    ROUND(
        SUM(mrr)
        / NULLIF(
            COUNT(*) FILTER (
                WHERE is_active_customer = 1
            ),
            0
        ),
        2
    ) AS arpa

FROM monthly_revenue

GROUP BY month_end

ORDER BY month_end;
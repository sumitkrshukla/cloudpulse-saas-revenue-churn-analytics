-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Monthly Revenue KPI
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
        SUM(mrr) * 12,
        2
    ) AS arr

FROM monthly_revenue

GROUP BY month_end

ORDER BY month_end;
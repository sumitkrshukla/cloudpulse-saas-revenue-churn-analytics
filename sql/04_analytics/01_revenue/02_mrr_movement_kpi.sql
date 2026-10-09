-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: MRR Movement KPI
-- Grain: 1 row = 1 month
-- ============================================================

SELECT
    DATE_TRUNC('month', event_date)::DATE AS month_start,

    ROUND(
        SUM(new_mrr_amount),
        2
    ) AS new_mrr,

    ROUND(
        SUM(expansion_mrr),
        2
    ) AS expansion_mrr,

    ROUND(
        SUM(contraction_mrr),
        2
    ) AS contraction_mrr,

    ROUND(
        SUM(churned_mrr),
        2
    ) AS churned_mrr,

    ROUND(
        SUM(new_mrr_amount)
        + SUM(expansion_mrr)
        - SUM(contraction_mrr)
        - SUM(churned_mrr),
        2
    ) AS net_new_mrr

FROM revenue_movement

GROUP BY DATE_TRUNC('month', event_date)::DATE

ORDER BY month_start;
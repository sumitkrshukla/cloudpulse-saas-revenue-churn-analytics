-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Revenue Churn Rate
-- Grain: 1 row = 1 month
-- ============================================================

SELECT
    month_end,

    ROUND(
        SUM(beginning_mrr),
        2
    ) AS beginning_mrr,

    ROUND(
        SUM(contraction_mrr),
        2
    ) AS contraction_mrr,

    ROUND(
        SUM(churned_mrr),
        2
    ) AS churned_mrr,

    ROUND(
        (
            SUM(contraction_mrr)
            + SUM(churned_mrr)
        ),
        2
    ) AS lost_mrr,

    ROUND(
        (
            SUM(contraction_mrr)
            + SUM(churned_mrr)
        )
        / NULLIF(SUM(beginning_mrr), 0)
        * 100,
        2
    ) AS revenue_churn_rate_pct

FROM monthly_retention

GROUP BY month_end

ORDER BY month_end;

-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: GRR vs Revenue Churn Rate
-- Purpose: Validate retention KPI mathematical consistency
-- Grain: 1 row = 1 month with positive beginning MRR
-- Expected: All eligible months PASS
-- ============================================================

WITH monthly_retention_kpis AS (
    SELECT
        month_end,
        SUM(beginning_mrr) AS beginning_mrr,
        SUM(contraction_mrr) AS contraction_mrr,
        SUM(churned_mrr) AS churned_mrr
    FROM monthly_retention
    GROUP BY month_end
),

calculated AS (
    SELECT
        month_end,
        beginning_mrr,

        ROUND(
            (
                beginning_mrr
                - contraction_mrr
                - churned_mrr
            ) / NULLIF(beginning_mrr, 0) * 100,
            2
        ) AS grr_pct,

        ROUND(
            (
                contraction_mrr
                + churned_mrr
            ) / NULLIF(beginning_mrr, 0) * 100,
            2
        ) AS revenue_churn_rate_pct

    FROM monthly_retention_kpis
)

SELECT
    month_end,
    ROUND(beginning_mrr, 2) AS beginning_mrr,
    grr_pct,
    revenue_churn_rate_pct,

    ROUND(
        grr_pct + revenue_churn_rate_pct,
        2
    ) AS combined_pct,

    CASE
        WHEN ABS(
            grr_pct + revenue_churn_rate_pct - 100
        ) < 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status

FROM calculated

WHERE beginning_mrr > 0

ORDER BY month_end;

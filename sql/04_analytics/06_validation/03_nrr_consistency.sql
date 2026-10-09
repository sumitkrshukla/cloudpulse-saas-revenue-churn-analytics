
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Net Revenue Retention (NRR)
-- Purpose: Validate NRR calculation and revenue reconciliation
-- Grain: 1 row = 1 month with positive beginning MRR
-- Expected: All eligible months PASS
-- ============================================================

WITH monthly_retention_kpis AS (
    SELECT
        month_end,
        SUM(beginning_mrr) AS beginning_mrr,
        SUM(new_mrr) AS new_mrr,
        SUM(expansion_mrr) AS expansion_mrr,
        SUM(contraction_mrr) AS contraction_mrr,
        SUM(churned_mrr) AS churned_mrr,
        SUM(ending_mrr) AS ending_mrr
    FROM monthly_retention
    GROUP BY month_end
),

calculated AS (
    SELECT
        month_end,
        beginning_mrr,
        new_mrr,
        expansion_mrr,
        contraction_mrr,
        churned_mrr,
        ending_mrr,

        beginning_mrr
            + expansion_mrr
            - contraction_mrr
            - churned_mrr AS retained_mrr_ex_new,

        beginning_mrr
            + new_mrr
            + expansion_mrr
            - contraction_mrr
            - churned_mrr AS reconciled_ending_mrr

    FROM monthly_retention_kpis
)

SELECT
    month_end,
    ROUND(beginning_mrr, 2) AS beginning_mrr,
    ROUND(expansion_mrr, 2) AS expansion_mrr,
    ROUND(contraction_mrr, 2) AS contraction_mrr,
    ROUND(churned_mrr, 2) AS churned_mrr,
    ROUND(ending_mrr, 2) AS ending_mrr,

    ROUND(
        retained_mrr_ex_new
        / NULLIF(beginning_mrr, 0) * 100,
        2
    ) AS calculated_nrr_pct,

    ROUND(
        ending_mrr - reconciled_ending_mrr,
        2
    ) AS reconciliation_difference,

    CASE
        WHEN ABS(
            ending_mrr - reconciled_ending_mrr
        ) < 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status

FROM calculated

WHERE beginning_mrr > 0

ORDER BY month_end;

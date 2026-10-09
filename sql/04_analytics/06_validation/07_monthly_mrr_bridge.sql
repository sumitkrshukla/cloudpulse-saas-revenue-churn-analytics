
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Monthly MRR Bridge
-- Purpose: Verify beginning MRR + movements = ending MRR
-- Expected: Zero mismatches
-- ============================================================

WITH monthly_bridge AS (
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

reconciliation AS (
    SELECT
        month_end,
        beginning_mrr,
        new_mrr,
        expansion_mrr,
        contraction_mrr,
        churned_mrr,
        ending_mrr,

        beginning_mrr
            + new_mrr
            + expansion_mrr
            - contraction_mrr
            - churned_mrr AS calculated_ending_mrr

    FROM monthly_bridge
)

SELECT
    month_end,
    ROUND(beginning_mrr, 2) AS beginning_mrr,
    ROUND(new_mrr, 2) AS new_mrr,
    ROUND(expansion_mrr, 2) AS expansion_mrr,
    ROUND(contraction_mrr, 2) AS contraction_mrr,
    ROUND(churned_mrr, 2) AS churned_mrr,
    ROUND(ending_mrr, 2) AS ending_mrr,

    ROUND(
        ending_mrr - calculated_ending_mrr,
        2
    ) AS difference,

    CASE
        WHEN ABS(
            ending_mrr - calculated_ending_mrr
        ) < 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status

FROM reconciliation
ORDER BY month_end;

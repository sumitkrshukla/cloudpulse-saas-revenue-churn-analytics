
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Monthly Revenue Reconciliation
-- Purpose: Compare plan-level MRR against total monthly MRR
-- Expected: Zero mismatches
-- ============================================================

WITH monthly_plan_mrr AS (
    SELECT
        mr.month_end,
        p.plan_name,
        SUM(mr.mrr) AS plan_mrr
    FROM (
        SELECT
            r.month_end,
            r.customer_id,
            r.mrr,
            e.new_plan_id,
            ROW_NUMBER() OVER (
                PARTITION BY r.customer_id, r.month_end
                ORDER BY e.event_date DESC, e.event_id DESC
            ) AS rn
        FROM monthly_revenue r
        LEFT JOIN stg_subscription_events e
            ON e.customer_id = r.customer_id
           AND e.event_date <= r.month_end
    ) mr
    INNER JOIN stg_plans p
        ON p.plan_id = mr.new_plan_id
    WHERE mr.rn = 1
      AND mr.mrr > 0
    GROUP BY
        mr.month_end,
        p.plan_name
),

plan_totals AS (
    SELECT
        month_end,
        SUM(plan_mrr) AS plan_total_mrr
    FROM monthly_plan_mrr
    GROUP BY month_end
),

overall_totals AS (
    SELECT
        month_end,
        SUM(mrr) AS total_mrr
    FROM monthly_revenue
    GROUP BY month_end
)

SELECT
    o.month_end,
    ROUND(o.total_mrr, 2) AS total_mrr,
    ROUND(COALESCE(p.plan_total_mrr, 0), 2) AS plan_total_mrr,
    ROUND(
        o.total_mrr - COALESCE(p.plan_total_mrr, 0),
        2
    ) AS difference,
    CASE
        WHEN ABS(
            o.total_mrr - COALESCE(p.plan_total_mrr, 0)
        ) < 0.01
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status
FROM overall_totals o
LEFT JOIN plan_totals p
    ON p.month_end = o.month_end
ORDER BY o.month_end;
-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Plan Performance
-- Grain: 1 row = 1 plan per month
-- ============================================================

WITH monthly_plan AS (
    SELECT
        mr.month_end,
        mr.customer_id,
        mr.mrr,
        e.new_plan_id,

        ROW_NUMBER() OVER (
            PARTITION BY
                mr.customer_id,
                mr.month_end
            ORDER BY
                e.event_date DESC,
                e.event_id DESC
        ) AS rn

    FROM monthly_revenue mr

    LEFT JOIN stg_subscription_events e
        ON mr.customer_id = e.customer_id
        AND e.event_date <= mr.month_end
)

SELECT
    mp.month_end,
    p.plan_name,

    COUNT(DISTINCT mp.customer_id) AS active_customers,

    ROUND(
        SUM(mp.mrr),
        2
    ) AS mrr,

    ROUND(
        SUM(mp.mrr) * 12,
        2
    ) AS arr

FROM monthly_plan mp

INNER JOIN stg_plans p
    ON mp.new_plan_id = p.plan_id

WHERE mp.rn = 1
  AND mp.mrr > 0

GROUP BY
    mp.month_end,
    p.plan_name

ORDER BY
    mp.month_end,
    p.plan_name;
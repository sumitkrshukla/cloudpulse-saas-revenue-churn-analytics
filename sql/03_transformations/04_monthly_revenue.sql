-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Monthly Revenue
-- Grain: 1 row = 1 customer x 1 month
-- ============================================================

DROP TABLE IF EXISTS monthly_revenue;

CREATE TABLE monthly_revenue AS

WITH month_ends AS (

    SELECT
        (DATE_TRUNC('month', month_date)
         + INTERVAL '1 month - 1 day')::DATE AS month_end

    FROM GENERATE_SERIES(
        DATE '2024-01-01',
        DATE '2025-12-01',
        INTERVAL '1 month'
    ) AS month_date
),

customer_months AS (

    SELECT
        c.customer_id,
        m.month_end

    FROM stg_customers c

    CROSS JOIN month_ends m

    WHERE c.signup_date <= m.month_end
),

latest_event AS (

    SELECT
        cm.customer_id,
        cm.month_end,
        e.event_type,
        e.new_mrr,
        e.event_date,

        ROW_NUMBER() OVER (
            PARTITION BY
                cm.customer_id,
                cm.month_end

            ORDER BY
                e.event_date DESC,
                e.event_id DESC
        ) AS rn

    FROM customer_months cm

    LEFT JOIN stg_subscription_events e
        ON e.customer_id = cm.customer_id
        AND e.event_date <= cm.month_end
)

SELECT
    customer_id,
    month_end,

    CASE
        WHEN rn = 1
             AND event_type <> 'CANCELLATION'
            THEN COALESCE(new_mrr, 0)

        ELSE 0
    END AS mrr,

    CASE
        WHEN rn = 1
             AND event_type <> 'CANCELLATION'
             AND COALESCE(new_mrr, 0) > 0
            THEN 1

        ELSE 0
    END AS is_active_customer

FROM latest_event
WHERE rn = 1;
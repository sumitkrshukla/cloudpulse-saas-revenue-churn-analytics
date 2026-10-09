-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Customer 360
-- Grain: 1 row = 1 customer
-- ============================================================

DROP TABLE IF EXISTS customer_360;

CREATE TABLE customer_360 AS

WITH subscription_summary AS (

    SELECT
        s.customer_id,

        COUNT(*) AS total_subscriptions,

        MIN(s.start_date) AS first_subscription_date,

        MAX(s.start_date) AS latest_subscription_date,

        COUNT(*) FILTER (
            WHERE s.subscription_status = 'Active'
        ) AS active_subscription_count,

        COUNT(*) FILTER (
            WHERE s.subscription_status = 'Cancelled'
        ) AS cancelled_subscription_count

    FROM stg_subscriptions s

    GROUP BY s.customer_id
),

current_subscription AS (

    SELECT
        s.customer_id,
        p.plan_name AS current_plan

    FROM stg_subscriptions s

    INNER JOIN stg_plans p
        ON s.plan_id = p.plan_id

    WHERE s.subscription_status = 'Active'
)

SELECT
    c.customer_id,
    c.company_name,
    c.industry,
    c.customer_segment,
    c.country,
    c.region,
    c.signup_date,
    c.acquisition_channel,

    COALESCE(ss.total_subscriptions, 0) AS total_subscriptions,

    ss.first_subscription_date,

    ss.latest_subscription_date,

    COALESCE(
        ss.active_subscription_count,
        0
    ) AS active_subscription_count,

    COALESCE(
        ss.cancelled_subscription_count,
        0
    ) AS cancelled_subscription_count,

    cs.current_plan

FROM stg_customers c

LEFT JOIN subscription_summary ss
    ON c.customer_id = ss.customer_id

LEFT JOIN current_subscription cs
    ON c.customer_id = cs.customer_id;
-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Subscription Analytics
-- Grain: 1 row = 1 subscription
-- ============================================================

DROP TABLE IF EXISTS subscription_analytics;

CREATE TABLE subscription_analytics AS

SELECT
    s.subscription_id,
    s.customer_id,

    c.company_name,
    c.industry,
    c.customer_segment,
    c.country,
    c.region,
    c.acquisition_channel,

    s.plan_id,
    p.plan_name,
    p.monthly_price,
    p.annual_discount,

    s.start_date,
    s.end_date,
    s.billing_cycle,
    s.subscription_status,

    CASE
        WHEN s.end_date IS NOT NULL
            THEN s.end_date - s.start_date
        ELSE CURRENT_DATE - s.start_date
    END AS subscription_duration_days,

    CASE
        WHEN s.subscription_status = 'Active'
            THEN 1
        ELSE 0
    END AS is_active,

    CASE
        WHEN s.subscription_status = 'Cancelled'
            THEN 1
        ELSE 0
    END AS is_cancelled

FROM stg_subscriptions s

INNER JOIN stg_customers c
    ON s.customer_id = c.customer_id

INNER JOIN stg_plans p
    ON s.plan_id = p.plan_id;
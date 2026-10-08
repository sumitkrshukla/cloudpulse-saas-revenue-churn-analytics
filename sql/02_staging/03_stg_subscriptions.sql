-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Subscriptions
-- ============================================================

DROP TABLE IF EXISTS stg_subscriptions;

CREATE TABLE stg_subscriptions AS
SELECT
    TRIM(subscription_id) AS subscription_id,
    TRIM(customer_id) AS customer_id,
    TRIM(plan_id) AS plan_id,
    start_date,
    end_date,
    TRIM(billing_cycle) AS billing_cycle,
    TRIM(subscription_status) AS subscription_status
FROM subscriptions;

-- ============================================================
-- Basic staging validation
-- ============================================================

SELECT
    COUNT(*) AS total_subscriptions,
    COUNT(DISTINCT subscription_id) AS unique_subscriptions,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids,
    COUNT(*) - COUNT(plan_id) AS null_plan_ids,
    COUNT(*) FILTER (WHERE end_date IS NOT NULL) AS subscriptions_with_end_date
FROM stg_subscriptions;
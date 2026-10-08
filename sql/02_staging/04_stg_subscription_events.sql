-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Subscription Events
-- ============================================================

DROP TABLE IF EXISTS stg_subscription_events;

CREATE TABLE stg_subscription_events AS
SELECT
    TRIM(event_id) AS event_id,
    TRIM(subscription_id) AS subscription_id,
    TRIM(customer_id) AS customer_id,
    event_date,
    TRIM(event_type) AS event_type,
    TRIM(old_plan_id) AS old_plan_id,
    TRIM(new_plan_id) AS new_plan_id,
    CAST(old_mrr AS NUMERIC(10,2)) AS old_mrr,
    CAST(new_mrr AS NUMERIC(10,2)) AS new_mrr
FROM subscription_events;

-- ============================================================
-- Validation
-- ============================================================

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) - COUNT(subscription_id) AS null_subscription_ids,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids,
    COUNT(*) FILTER (WHERE event_type = 'NEW') AS new_events,
    COUNT(*) FILTER (WHERE event_type = 'UPGRADE') AS upgrade_events,
    COUNT(*) FILTER (WHERE event_type = 'DOWNGRADE') AS downgrade_events,
    COUNT(*) FILTER (WHERE event_type = 'CANCELLATION') AS cancellation_events
FROM stg_subscription_events;
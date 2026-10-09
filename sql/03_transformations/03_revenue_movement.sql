-- ============================================================
-- CloudPulse CRM
-- Transformation Layer: Revenue Movement
-- Grain: 1 row = 1 subscription event
-- ============================================================

DROP TABLE IF EXISTS revenue_movement;

CREATE TABLE revenue_movement AS

SELECT
    event_id,
    subscription_id,
    customer_id,
    event_date,
    event_type,

    old_plan_id,
    new_plan_id,

    old_mrr,
    new_mrr,

    CASE
        WHEN event_type = 'NEW'
            THEN COALESCE(new_mrr, 0)
        ELSE 0
    END AS new_mrr_amount,

    CASE
        WHEN event_type = 'UPGRADE'
            THEN COALESCE(new_mrr, 0) - COALESCE(old_mrr, 0)
        ELSE 0
    END AS expansion_mrr,

    CASE
        WHEN event_type = 'DOWNGRADE'
            THEN COALESCE(old_mrr, 0) - COALESCE(new_mrr, 0)
        ELSE 0
    END AS contraction_mrr,

    CASE
        WHEN event_type = 'CANCELLATION'
            THEN COALESCE(old_mrr, 0)
        ELSE 0
    END AS churned_mrr

FROM stg_subscription_events;
-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Usage
-- ============================================================

DROP TABLE IF EXISTS stg_usage;

CREATE TABLE stg_usage AS
SELECT
    TRIM(usage_id) AS usage_id,
    TRIM(customer_id) AS customer_id,
    usage_date,
    CAST(active_users AS INTEGER) AS active_users,
    CAST(login_count AS INTEGER) AS login_count,
    CAST(feature_usage AS INTEGER) AS feature_usage,
    CAST(session_minutes AS INTEGER) AS session_minutes
FROM usage;

-- ============================================================
-- Validation
-- ============================================================

SELECT
    COUNT(*) AS total_usage_records,
    COUNT(DISTINCT usage_id) AS unique_usage_records,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids,
    COUNT(*) FILTER (WHERE active_users < 0) AS negative_active_users,
    COUNT(*) FILTER (WHERE login_count < 0) AS negative_logins,
    COUNT(*) FILTER (WHERE feature_usage < 0) AS negative_feature_usage,
    COUNT(*) FILTER (WHERE session_minutes < 0) AS negative_session_minutes
FROM stg_usage;
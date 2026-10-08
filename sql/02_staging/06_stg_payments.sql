-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Payments
-- ============================================================

DROP TABLE IF EXISTS stg_payments;

CREATE TABLE stg_payments AS
SELECT
    TRIM(payment_id) AS payment_id,
    TRIM(invoice_id) AS invoice_id,
    TRIM(customer_id) AS customer_id,
    payment_date,
    CAST(amount AS NUMERIC(12,2)) AS amount,
    TRIM(payment_status) AS payment_status,
    TRIM(payment_method) AS payment_method
FROM payments;

-- ============================================================
-- Validation
-- ============================================================

SELECT
    COUNT(*) AS total_payments,
    COUNT(DISTINCT payment_id) AS unique_payments,
    COUNT(*) - COUNT(invoice_id) AS null_invoice_ids,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids,
    MIN(amount) AS minimum_payment_amount,
    MAX(amount) AS maximum_payment_amount,
    COUNT(*) FILTER (WHERE payment_status = 'Successful') AS successful_payments,
    COUNT(*) FILTER (WHERE payment_status = 'Failed') AS failed_payments,
    COUNT(*) FILTER (WHERE payment_status = 'Refunded') AS refunded_payments
FROM stg_payments;
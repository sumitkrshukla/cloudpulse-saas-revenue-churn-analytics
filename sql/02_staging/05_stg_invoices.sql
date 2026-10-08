-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Invoices
-- ============================================================

DROP TABLE IF EXISTS stg_invoices;

CREATE TABLE stg_invoices AS
SELECT
    TRIM(invoice_id) AS invoice_id,
    TRIM(customer_id) AS customer_id,
    TRIM(subscription_id) AS subscription_id,
    invoice_date,
    due_date,
    CAST(amount AS NUMERIC(12,2)) AS amount,
    TRIM(invoice_status) AS invoice_status
FROM invoices;

-- ============================================================
-- Validation
-- ============================================================

SELECT
    COUNT(*) AS total_invoices,
    COUNT(DISTINCT invoice_id) AS unique_invoices,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids,
    COUNT(*) - COUNT(subscription_id) AS null_subscription_ids,
    MIN(amount) AS minimum_invoice_amount,
    MAX(amount) AS maximum_invoice_amount,
    COUNT(*) FILTER (WHERE invoice_status = 'Paid') AS paid_invoices,
    COUNT(*) FILTER (WHERE invoice_status = 'Pending') AS pending_invoices,
    COUNT(*) FILTER (WHERE invoice_status = 'Overdue') AS overdue_invoices,
    COUNT(*) FILTER (WHERE invoice_status = 'Cancelled') AS cancelled_invoices
FROM stg_invoices;
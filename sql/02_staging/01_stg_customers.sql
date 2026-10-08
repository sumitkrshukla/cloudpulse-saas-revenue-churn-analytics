-- ============================================================
-- CloudPulse CRM
-- Staging Layer: Customers
-- ============================================================

DROP TABLE IF EXISTS stg_customers;

CREATE TABLE stg_customers AS
SELECT
    TRIM(customer_id) AS customer_id,
    TRIM(company_name) AS company_name,
    TRIM(industry) AS industry,
    TRIM(customer_segment) AS customer_segment,
    TRIM(country) AS country,
    TRIM(region) AS region,
    signup_date,
    TRIM(acquisition_channel) AS acquisition_channel
FROM customers;

-- ============================================================
-- Basic staging validation
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) - COUNT(customer_id) AS null_customer_ids
FROM stg_customers;
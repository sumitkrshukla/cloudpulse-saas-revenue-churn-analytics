-- ============================================================
-- CloudPulse CRM
-- Analytics Layer: Customer Churn KPI
-- Grain: 1 row = 1 month
-- ============================================================

SELECT
    month_end,

    SUM(starting_active) AS starting_customers,

    SUM(new_customer) AS new_customers,

    SUM(churned_customer) AS churned_customers,

    SUM(ending_active) AS ending_customers,

    ROUND(
        SUM(churned_customer)::NUMERIC
        / NULLIF(SUM(starting_active), 0) * 100,
        2
    ) AS customer_churn_rate_pct,

    ROUND(
        (
            SUM(starting_active)
            - SUM(churned_customer)
        )::NUMERIC
        / NULLIF(SUM(starting_active), 0) * 100,
        2
    ) AS customer_retention_rate_pct

FROM customer_churn

GROUP BY month_end

ORDER BY month_end;
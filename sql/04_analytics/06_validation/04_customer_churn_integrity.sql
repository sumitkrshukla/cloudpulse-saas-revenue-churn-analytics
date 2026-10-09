
-- ============================================================
-- CloudPulse CRM
-- SQL Quality Audit: Customer Churn Integrity
-- Purpose: Validate customer status transitions
-- Grain: 1 row = 1 customer-month
-- Expected: Zero invalid flags, duplicate grains or
--           inconsistent churn classifications
-- ============================================================

WITH churn_audit AS (
    SELECT
        customer_id,
        month_end,
        starting_active,
        ending_active,
        new_customer,
        churned_customer
    FROM customer_churn
),

monthly_checks AS (
    SELECT
        COUNT(*) AS total_rows,

        COUNT(DISTINCT (customer_id, month_end))
            AS unique_customer_months,

        COUNT(*) FILTER (
            WHERE starting_active NOT IN (0, 1)
               OR ending_active NOT IN (0, 1)
               OR new_customer NOT IN (0, 1)
               OR churned_customer NOT IN (0, 1)
        ) AS invalid_flag_rows,

        COUNT(*) FILTER (
            WHERE starting_active = 1
              AND ending_active = 0
              AND churned_customer <> 1
        ) AS missed_churns,

        COUNT(*) FILTER (
            WHERE starting_active = 0
              AND ending_active = 1
              AND new_customer <> 1
        ) AS missed_new_transitions,

        COUNT(*) FILTER (
            WHERE churned_customer = 1
              AND NOT (
                  starting_active = 1
                  AND ending_active = 0
              )
        ) AS false_churns

    FROM churn_audit
)

SELECT
    total_rows,
    unique_customer_months,
    total_rows - unique_customer_months AS duplicate_rows,
    invalid_flag_rows,
    missed_churns,
    missed_new_transitions,
    false_churns,

    CASE
        WHEN total_rows = unique_customer_months
         AND invalid_flag_rows = 0
         AND missed_churns = 0
         AND missed_new_transitions = 0
         AND false_churns = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_status

FROM monthly_checks;

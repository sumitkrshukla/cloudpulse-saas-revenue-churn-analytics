-- ============================================================
-- CloudPulse CRM SaaS Analytics
-- Database Constraints
-- ============================================================


-- ============================================================
-- 1. Subscriptions → Customers
-- ============================================================

ALTER TABLE subscriptions
ADD CONSTRAINT fk_subscriptions_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- 2. Subscriptions → Plans
-- ============================================================

ALTER TABLE subscriptions
ADD CONSTRAINT fk_subscriptions_plan
FOREIGN KEY (plan_id)
REFERENCES plans(plan_id);


-- ============================================================
-- 3. Subscription Events → Subscriptions
-- ============================================================

ALTER TABLE subscription_events
ADD CONSTRAINT fk_events_subscription
FOREIGN KEY (subscription_id)
REFERENCES subscriptions(subscription_id);


-- ============================================================
-- 4. Subscription Events → Customers
-- ============================================================

ALTER TABLE subscription_events
ADD CONSTRAINT fk_events_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- 5. Subscription Events → Old Plan
-- ============================================================

ALTER TABLE subscription_events
ADD CONSTRAINT fk_events_old_plan
FOREIGN KEY (old_plan_id)
REFERENCES plans(plan_id);


-- ============================================================
-- 6. Subscription Events → New Plan
-- ============================================================

ALTER TABLE subscription_events
ADD CONSTRAINT fk_events_new_plan
FOREIGN KEY (new_plan_id)
REFERENCES plans(plan_id);


-- ============================================================
-- 7. Invoices → Customers
-- ============================================================

ALTER TABLE invoices
ADD CONSTRAINT fk_invoices_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- 8. Invoices → Subscriptions
-- ============================================================

ALTER TABLE invoices
ADD CONSTRAINT fk_invoices_subscription
FOREIGN KEY (subscription_id)
REFERENCES subscriptions(subscription_id);


-- ============================================================
-- 9. Payments → Invoices
-- ============================================================

ALTER TABLE payments
ADD CONSTRAINT fk_payments_invoice
FOREIGN KEY (invoice_id)
REFERENCES invoices(invoice_id);


-- ============================================================
-- 10. Payments → Customers
-- ============================================================

ALTER TABLE payments
ADD CONSTRAINT fk_payments_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- 11. Usage → Customers
-- ============================================================

ALTER TABLE usage
ADD CONSTRAINT fk_usage_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- ============================================================
-- Business Rule Constraints
-- ============================================================


-- Customer segments
ALTER TABLE customers
ADD CONSTRAINT chk_customer_segment
CHECK (
    customer_segment IN (
        'SMB',
        'Mid-Market',
        'Enterprise'
    )
);


-- Plan pricing cannot be negative
ALTER TABLE plans
ADD CONSTRAINT chk_plan_monthly_price
CHECK (monthly_price >= 0);


-- Annual discount must be between 0% and 100%
ALTER TABLE plans
ADD CONSTRAINT chk_annual_discount
CHECK (
    annual_discount >= 0
    AND annual_discount <= 100
);


-- Subscription billing cycle
ALTER TABLE subscriptions
ADD CONSTRAINT chk_billing_cycle
CHECK (
    billing_cycle IN (
        'Monthly',
        'Annual'
    )
);


-- Subscription status
ALTER TABLE subscriptions
ADD CONSTRAINT chk_subscription_status
CHECK (
    subscription_status IN (
        'Active',
        'Cancelled',
        'Expired'
    )
);


-- Subscription dates
ALTER TABLE subscriptions
ADD CONSTRAINT chk_subscription_dates
CHECK (
    end_date IS NULL
    OR end_date >= start_date
);


-- Subscription event types
ALTER TABLE subscription_events
ADD CONSTRAINT chk_event_type
CHECK (
    event_type IN (
        'NEW',
        'UPGRADE',
        'DOWNGRADE',
        'RENEWAL',
        'CANCELLATION',
        'REACTIVATION'
    )
);


-- MRR cannot be negative
ALTER TABLE subscription_events
ADD CONSTRAINT chk_event_mrr
CHECK (
    (old_mrr IS NULL OR old_mrr >= 0)
    AND
    (new_mrr IS NULL OR new_mrr >= 0)
);


-- Invoice amount
ALTER TABLE invoices
ADD CONSTRAINT chk_invoice_amount
CHECK (amount >= 0);


-- Invoice status
ALTER TABLE invoices
ADD CONSTRAINT chk_invoice_status
CHECK (
    invoice_status IN (
        'Paid',
        'Pending',
        'Overdue',
        'Cancelled'
    )
);


-- Payment amount
ALTER TABLE payments
ADD CONSTRAINT chk_payment_amount
CHECK (amount >= 0);


-- Payment status
ALTER TABLE payments
ADD CONSTRAINT chk_payment_status
CHECK (
    payment_status IN (
        'Successful',
        'Failed',
        'Refunded'
    )
);


-- Usage metrics cannot be negative
ALTER TABLE usage
ADD CONSTRAINT chk_usage_metrics
CHECK (
    active_users >= 0
    AND login_count >= 0
    AND feature_usage >= 0
    AND session_minutes >= 0
);
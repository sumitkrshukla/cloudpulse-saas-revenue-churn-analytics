-- ============================================================
-- CloudPulse CRM SaaS Analytics
-- Database Indexes
-- ============================================================


-- ============================================================
-- Customers
-- ============================================================

CREATE INDEX idx_customers_signup_date
ON customers(signup_date);

CREATE INDEX idx_customers_segment
ON customers(customer_segment);

CREATE INDEX idx_customers_region
ON customers(region);

CREATE INDEX idx_customers_industry
ON customers(industry);


-- ============================================================
-- Subscriptions
-- ============================================================

CREATE INDEX idx_subscriptions_customer
ON subscriptions(customer_id);

CREATE INDEX idx_subscriptions_plan
ON subscriptions(plan_id);

CREATE INDEX idx_subscriptions_start_date
ON subscriptions(start_date);

CREATE INDEX idx_subscriptions_status
ON subscriptions(subscription_status);


-- ============================================================
-- Subscription Events
-- ============================================================

CREATE INDEX idx_events_subscription
ON subscription_events(subscription_id);

CREATE INDEX idx_events_customer
ON subscription_events(customer_id);

CREATE INDEX idx_events_date
ON subscription_events(event_date);

CREATE INDEX idx_events_type
ON subscription_events(event_type);


-- ============================================================
-- Invoices
-- ============================================================

CREATE INDEX idx_invoices_customer
ON invoices(customer_id);

CREATE INDEX idx_invoices_subscription
ON invoices(subscription_id);

CREATE INDEX idx_invoices_date
ON invoices(invoice_date);

CREATE INDEX idx_invoices_status
ON invoices(invoice_status);


-- ============================================================
-- Payments
-- ============================================================

CREATE INDEX idx_payments_invoice
ON payments(invoice_id);

CREATE INDEX idx_payments_customer
ON payments(customer_id);

CREATE INDEX idx_payments_date
ON payments(payment_date);

CREATE INDEX idx_payments_status
ON payments(payment_status);


-- ============================================================
-- Usage
-- ============================================================

CREATE INDEX idx_usage_customer
ON usage(customer_id);

CREATE INDEX idx_usage_date
ON usage(usage_date);

CREATE INDEX idx_usage_customer_date
ON usage(customer_id, usage_date);
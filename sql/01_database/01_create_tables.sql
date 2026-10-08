-- ============================================================
-- CloudPulse CRM SaaS Analytics
-- Database Schema - Table Creation
-- ============================================================

-- 1. Customers
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(30) NOT NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(30) NOT NULL,
    signup_date DATE NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL
);


-- 2. Plans
CREATE TABLE plans (
    plan_id VARCHAR(20) PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    monthly_price DECIMAL(10,2) NOT NULL,
    annual_discount DECIMAL(5,2) NOT NULL
);


-- 3. Subscriptions
CREATE TABLE subscriptions (
    subscription_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    plan_id VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    billing_cycle VARCHAR(20) NOT NULL,
    subscription_status VARCHAR(20) NOT NULL
);


-- 4. Subscription Events
CREATE TABLE subscription_events (
    event_id VARCHAR(20) PRIMARY KEY,
    subscription_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(30) NOT NULL,
    old_plan_id VARCHAR(20),
    new_plan_id VARCHAR(20),
    old_mrr DECIMAL(10,2),
    new_mrr DECIMAL(10,2)
);


-- 5. Invoices
CREATE TABLE invoices (
    invoice_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    subscription_id VARCHAR(20) NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    invoice_status VARCHAR(20) NOT NULL
);


-- 6. Payments
CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    invoice_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(30) NOT NULL
);


-- 7. Usage
CREATE TABLE usage (
    usage_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    usage_date DATE NOT NULL,
    active_users INT NOT NULL,
    login_count INT NOT NULL,
    feature_usage INT NOT NULL,
    session_minutes INT NOT NULL
);
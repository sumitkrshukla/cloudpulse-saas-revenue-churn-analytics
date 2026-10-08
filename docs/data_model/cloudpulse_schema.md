# CloudPulse CRM — Database Schema

## 1. Customers

**Table:** `customers`

**Grain:** 1 row = 1 customer/company

| Column              | Data Type    | Key | Description                                 |
| ------------------- | ------------ | --- | ------------------------------------------- |
| customer_id         | VARCHAR(20)  | PK  | Unique customer identifier                  |
| company_name        | VARCHAR(150) |     | Customer/company name                       |
| industry            | VARCHAR(50)  |     | Customer industry                           |
| customer_segment    | VARCHAR(30)  |     | SMB, Mid-Market, Enterprise                 |
| country             | VARCHAR(100) |     | Customer country                            |
| region              | VARCHAR(30)  |     | North America, Europe, APAC, Latin America  |
| signup_date         | DATE         |     | Date customer joined CloudPulse             |
| acquisition_channel | VARCHAR(50)  |     | Channel through which customer was acquired |

---

## 2. Plans

**Table:** `plans`

**Grain:** 1 row = 1 subscription plan

| Column          | Data Type     | Key | Description                        |
| --------------- | ------------- | --- | ---------------------------------- |
| plan_id         | VARCHAR(20)   | PK  | Unique plan identifier             |
| plan_name       | VARCHAR(50)   |     | Starter, Professional, Enterprise  |
| monthly_price   | DECIMAL(10,2) |     | Monthly subscription price         |
| annual_discount | DECIMAL(5,2)  |     | Discount applied to annual billing |

### Plans

| Plan         | Monthly Price |
| ------------ | ------------: |
| Starter      |           $29 |
| Professional |           $79 |
| Enterprise   |          $199 |

---

## 3. Subscriptions

**Table:** `subscriptions`

**Grain:** 1 row = 1 subscription lifecycle record

| Column              | Data Type   | Key | Description                    |
| ------------------- | ----------- | --- | ------------------------------ |
| subscription_id     | VARCHAR(20) | PK  | Unique subscription identifier |
| customer_id         | VARCHAR(20) | FK  | Customer owning subscription   |
| plan_id             | VARCHAR(20) | FK  | Subscription plan              |
| start_date          | DATE        |     | Subscription start date        |
| end_date            | DATE        |     | Subscription end date          |
| billing_cycle       | VARCHAR(20) |     | Monthly or Annual              |
| subscription_status | VARCHAR(20) |     | Active, Cancelled, etc.        |

**Business Rule:**  
A customer can have multiple subscription records over their lifetime.

Example:

`Starter → Professional → Enterprise`

Historical plan changes must not overwrite previous subscription records.

---

## 4. Subscription Events

**Table:** `subscription_events`

**Grain:** 1 row = 1 subscription event

| Column          | Data Type     | Key | Description                   |
| --------------- | ------------- | --- | ----------------------------- |
| event_id        | VARCHAR(20)   | PK  | Unique event identifier       |
| subscription_id | VARCHAR(20)   | FK  | Related subscription          |
| customer_id     | VARCHAR(20)   | FK  | Related customer              |
| event_date      | DATE          |     | Date of event                 |
| event_type      | VARCHAR(30)   |     | NEW, UPGRADE, DOWNGRADE, etc. |
| old_plan_id     | VARCHAR(20)   | FK  | Previous plan                 |
| new_plan_id     | VARCHAR(20)   | FK  | New plan                      |
| old_mrr         | DECIMAL(10,2) |     | MRR before event              |
| new_mrr         | DECIMAL(10,2) |     | MRR after event               |

### Event Types

- NEW
- UPGRADE
- DOWNGRADE
- RENEWAL
- CANCELLATION
- REACTIVATION

### Revenue Logic

**Expansion MRR**

`new_mrr - old_mrr` for upgrades.

Example:

`$79 - $29 = $50`

**Contraction MRR**

`old_mrr - new_mrr` for downgrades.

Example:

`$79 - $29 = $50`

**Churned MRR**

For cancellation:

`old_mrr - $0`

Example:

`$79 - $0 = $79`

This table provides the historical audit trail required for revenue movement analysis.

---

## 5. Invoices

**Table:** `invoices`

**Grain:** 1 row = 1 invoice

| Column          | Data Type     | Key | Description                       |
| --------------- | ------------- | --- | --------------------------------- |
| invoice_id      | VARCHAR(20)   | PK  | Unique invoice identifier         |
| customer_id     | VARCHAR(20)   | FK  | Customer being billed             |
| subscription_id | VARCHAR(20)   | FK  | Related subscription              |
| invoice_date    | DATE          |     | Invoice generation date           |
| due_date        | DATE          |     | Payment due date                  |
| amount          | DECIMAL(10,2) |     | Invoice amount                    |
| invoice_status  | VARCHAR(20)   |     | Paid, Pending, Overdue, Cancelled |

**Purpose:**  
Invoices represent amounts billed to customers.

---

## 6. Payments

**Table:** `payments`

**Grain:** 1 row = 1 payment transaction

| Column         | Data Type     | Key | Description                           |
| -------------- | ------------- | --- | ------------------------------------- |
| payment_id     | VARCHAR(20)   | PK  | Unique payment identifier             |
| invoice_id     | VARCHAR(20)   | FK  | Related invoice                       |
| customer_id    | VARCHAR(20)   | FK  | Customer making payment               |
| payment_date   | DATE          |     | Payment transaction date              |
| amount         | DECIMAL(10,2) |     | Payment amount                        |
| payment_status | VARCHAR(20)   |     | Successful, Failed, Refunded          |
| payment_method | VARCHAR(30)   |     | Credit Card, ACH, Bank Transfer, etc. |

**Business Rule:**  
One invoice can have multiple payment transactions.

---

## 7. Usage

**Table:** `usage`

**Grain:** 1 row = 1 customer × 1 day

| Column          | Data Type   | Key | Description                    |
| --------------- | ----------- | --- | ------------------------------ |
| usage_id        | VARCHAR(20) | PK  | Unique usage record            |
| customer_id     | VARCHAR(20) | FK  | Customer using the platform    |
| usage_date      | DATE        |     | Date of usage                  |
| active_users    | INT         |     | Number of active users         |
| login_count     | INT         |     | Number of logins               |
| feature_usage   | INT         |     | Number of feature interactions |
| session_minutes | INT         |     | Total session duration         |

**Purpose:**  
Used to analyze customer engagement and investigate potential relationships between product usage and churn.

**Important:**  
Usage and churn should be analyzed for statistical relationship. Usage decline should not automatically be treated as proof of churn causation.

---

# Relationships

```text
customers
   │
   ├──────────────< subscriptions >────────────── plans
   │                       │
   │                       └──────< subscription_events
   │
   ├──────────────< invoices
   │                       │
   │                       └──────< payments
   │
   └──────────────< usage
```

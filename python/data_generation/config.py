# ============================================================
# CloudPulse CRM SaaS Analytics
# Data Generation Configuration
# ============================================================

from datetime import date


# ============================================================
# Project Settings
# ============================================================

RANDOM_SEED = 42

START_DATE = date(2024, 1, 1)
END_DATE = date(2025, 12, 31)


# ============================================================
# Dataset Sizes
# ============================================================

NUM_CUSTOMERS = 2000


# ============================================================
# Customer Attributes
# ============================================================

INDUSTRIES = [
    "Technology",
    "Healthcare",
    "Financial Services",
    "Retail",
    "Manufacturing",
    "Education",
    "Professional Services",
]

CUSTOMER_SEGMENTS = [
    "SMB",
    "Mid-Market",
    "Enterprise",
]

REGIONS = [
    "North America",
    "Europe",
    "Asia-Pacific",
    "Latin America",
]

ACQUISITION_CHANNELS = [
    "Organic Search",
    "Paid Search",
    "Referral",
    "Partner",
    "Sales Outreach",
    "Webinar",
]


# ============================================================
# Plans
# ============================================================

PLANS = {
    "PLAN001": {
        "name": "Starter",
        "monthly_price": 29.00,
        "annual_discount": 0.15,
    },
    "PLAN002": {
        "name": "Professional",
        "monthly_price": 79.00,
        "annual_discount": 0.15,
    },
    "PLAN003": {
        "name": "Enterprise",
        "monthly_price": 199.00,
        "annual_discount": 0.15,
    },
}


# ============================================================
# Subscription Settings
# ============================================================

BILLING_CYCLES = [
    "Monthly",
    "Annual",
]

SUBSCRIPTION_STATUSES = [
    "Active",
    "Cancelled",
    "Expired",
]


# ============================================================
# Subscription Events
# ============================================================

EVENT_TYPES = [
    "NEW",
    "UPGRADE",
    "DOWNGRADE",
    "RENEWAL",
    "CANCELLATION",
    "REACTIVATION",
]


# ============================================================
# Billing
# ============================================================

INVOICE_STATUSES = [
    "Paid",
    "Pending",
    "Overdue",
    "Cancelled",
]

PAYMENT_STATUSES = [
    "Successful",
    "Failed",
    "Refunded",
]

PAYMENT_METHODS = [
    "Credit Card",
    "Debit Card",
    "ACH",
    "Bank Transfer",
]


# ============================================================
# Data Generation Probabilities
# ============================================================

# Approximate distribution of customer segments.
SEGMENT_WEIGHTS = {
    "SMB": 0.55,
    "Mid-Market": 0.30,
    "Enterprise": 0.15,
}


# Approximate distribution of billing cycles.
BILLING_CYCLE_WEIGHTS = {
    "Monthly": 0.75,
    "Annual": 0.25,
}


# Approximate distribution of acquisition channels.
ACQUISITION_CHANNEL_WEIGHTS = {
    "Organic Search": 0.20,
    "Paid Search": 0.15,
    "Referral": 0.15,
    "Partner": 0.10,
    "Sales Outreach": 0.25,
    "Webinar": 0.15,
}


# ============================================================
# Churn Behavior
# ============================================================

# Baseline monthly churn probabilities.
SEGMENT_CHURN_RATES = {
    "SMB": 0.035,
    "Mid-Market": 0.020,
    "Enterprise": 0.010,
}


# ============================================================
# Usage Behavior
# ============================================================

USAGE_ACTIVITY_LEVELS = {
    "Low": {
        "active_users": (1, 5),
        "login_count": (1, 15),
        "feature_usage": (5, 50),
        "session_minutes": (10, 120),
    },
    "Medium": {
        "active_users": (5, 20),
        "login_count": (10, 40),
        "feature_usage": (30, 150),
        "session_minutes": (60, 300),
    },
    "High": {
        "active_users": (15, 50),
        "login_count": (25, 80),
        "feature_usage": (100, 400),
        "session_minutes": (180, 600),
    },
}


# ============================================================
# Data Quality Settings
# ============================================================

# Percentage of invoices that may experience payment issues.
PAYMENT_FAILURE_RATE = 0.04

OVERDUE_RATE = 0.06

REFUND_RATE = 0.01
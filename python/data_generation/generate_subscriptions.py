# ============================================================
# CloudPulse CRM SaaS Analytics
# Subscription Data Generator
# ============================================================

import random
from datetime import timedelta

import pandas as pd

from config import (
    RANDOM_SEED,
    END_DATE,
    PLANS,
    BILLING_CYCLE_WEIGHTS,
    SUBSCRIPTION_STATUSES,
)


# ============================================================
# Configuration
# ============================================================

random.seed(RANDOM_SEED)


# ============================================================
# Helper Functions
# ============================================================

def weighted_choice(options, weights):
    return random.choices(
        options,
        weights=weights,
        k=1,
    )[0]


def calculate_mrr(plan_id):
    """Return monthly recurring revenue for a plan."""
    return PLANS[plan_id]["monthly_price"]


def calculate_end_date(start_date):
    """
    Generate a realistic subscription end date.

    Most subscriptions remain active for a meaningful period,
    while some customers cancel earlier.
    """

    lifetime_months = random.choices(
        [3, 6, 12, 18, 24],
        weights=[0.08, 0.15, 0.30, 0.27, 0.20],
        k=1,
    )[0]

    end_date = start_date + timedelta(
        days=lifetime_months * 30
    )

    if end_date > END_DATE:
        end_date = END_DATE

    return end_date


# ============================================================
# Generate Subscriptions
# ============================================================

def generate_subscriptions():

    customers = pd.read_csv(
        "data/raw/customers.csv"
    )

    subscriptions = []

    subscription_number = 1

    plan_options = list(PLANS.keys())

    plan_weights = [
        0.45,   # Starter
        0.40,   # Professional
        0.15,   # Enterprise
    ]

    billing_options = list(
        BILLING_CYCLE_WEIGHTS.keys()
    )

    billing_weights = list(
        BILLING_CYCLE_WEIGHTS.values()
    )

    for _, customer in customers.iterrows():

        customer_id = customer["customer_id"]

        signup_date = pd.to_datetime(
            customer["signup_date"]
        ).date()

        customer_segment = customer[
            "customer_segment"
        ]

        # ----------------------------------------------------
        # Choose plan based on customer segment
        # ----------------------------------------------------

        if customer_segment == "SMB":

            selected_plan = weighted_choice(
                plan_options,
                [0.65, 0.32, 0.03],
            )

        elif customer_segment == "Mid-Market":

            selected_plan = weighted_choice(
                plan_options,
                [0.25, 0.60, 0.15],
            )

        else:

            selected_plan = weighted_choice(
                plan_options,
                [0.05, 0.30, 0.65],
            )

        billing_cycle = weighted_choice(
            billing_options,
            billing_weights,
        )

        start_date = signup_date

        end_date = calculate_end_date(
            start_date
        )

        # ----------------------------------------------------
        # Determine subscription status
        # ----------------------------------------------------

        if end_date >= END_DATE:

            subscription_status = "Active"

            actual_end_date = None

        else:

            cancellation_probability = 0.75

            if random.random() < cancellation_probability:

                subscription_status = "Cancelled"

            else:

                subscription_status = "Expired"

            actual_end_date = end_date

        subscription_id = (
            f"SUB{subscription_number:05d}"
        )

        subscriptions.append(
            {
                "subscription_id": subscription_id,
                "customer_id": customer_id,
                "plan_id": selected_plan,
                "start_date": start_date,
                "end_date": actual_end_date,
                "billing_cycle": billing_cycle,
                "subscription_status": subscription_status,
            }
        )

        subscription_number += 1

    return pd.DataFrame(subscriptions)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    df_subscriptions = generate_subscriptions()

    output_path = (
        "data/raw/subscriptions.csv"
    )

    df_subscriptions.to_csv(
        output_path,
        index=False,
    )

    print(
        "Subscription dataset generated successfully!"
    )

    print(
        f"Rows generated: {len(df_subscriptions)}"
    )

    print(
        f"Saved to: {output_path}"
    )

    print()

    print("Plan distribution:")

    print(
        df_subscriptions["plan_id"]
        .value_counts()
    )

    print()

    print("Subscription status:")

    print(
        df_subscriptions[
            "subscription_status"
        ].value_counts()
    )
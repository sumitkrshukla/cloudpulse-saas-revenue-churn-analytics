# ============================================================
# CloudPulse CRM SaaS Analytics
# Invoice & Payment Data Generator
# ============================================================

import random
from calendar import monthrange
from datetime import date, timedelta

import pandas as pd

from config import (
    RANDOM_SEED,
    END_DATE,
    PLANS,
    INVOICE_STATUSES,
    PAYMENT_STATUSES,
    PAYMENT_METHODS,
    PAYMENT_FAILURE_RATE,
    OVERDUE_RATE,
    REFUND_RATE,
)


# ============================================================
# Configuration
# ============================================================

random.seed(RANDOM_SEED)


# ============================================================
# Helper Functions
# ============================================================

def get_plan_price(plan_id):
    """Return monthly price for a plan."""
    if plan_id is None:
        return 0.00

    return PLANS[plan_id]["monthly_price"]


def add_months(start_date, months):
    """Safely add months to a date."""
    month = start_date.month - 1 + months
    year = start_date.year + month // 12
    month = month % 12 + 1

    day = min(
        start_date.day,
        monthrange(year, month)[1],
    )

    return date(year, month, day)


def get_invoice_amount(plan_id, billing_cycle):
    """Calculate invoice amount."""
    monthly_price = get_plan_price(plan_id)

    if billing_cycle == "Annual":
        annual_discount = PLANS[plan_id]["annual_discount"]

        return round(
            monthly_price
            * 12
            * (1 - annual_discount),
            2,
        )

    return round(monthly_price, 2)


# ============================================================
# Determine Plan at Billing Date
# ============================================================

def get_plan_at_date(
    subscription_id,
    billing_date,
    subscriptions,
    events,
):
    """
    Determine the plan active on a specific billing date.

    Starts with the original subscription plan and then
    applies upgrade/downgrade events occurring on or before
    the billing date.
    """

    subscription = subscriptions[
        subscriptions["subscription_id"]
        == subscription_id
    ]

    if subscription.empty:
        return None

    subscription = subscription.iloc[0]

    current_plan = subscription["plan_id"]

    customer_events = events[
        events["subscription_id"]
        == subscription_id
    ].copy()

    customer_events["event_date"] = pd.to_datetime(
        customer_events["event_date"]
    ).dt.date

    customer_events = customer_events[
        customer_events["event_date"] <= billing_date
    ].sort_values("event_date")

    for _, event in customer_events.iterrows():

        event_type = event["event_type"]

        if event_type in [
            "UPGRADE",
            "DOWNGRADE",
        ]:

            if pd.notna(event["new_plan_id"]):

                current_plan = event["new_plan_id"]

        elif event_type == "CANCELLATION":

            current_plan = None

    return current_plan


# ============================================================
# Generate Invoices & Payments
# ============================================================

def generate_billing():

    subscriptions = pd.read_csv(
        "data/raw/subscriptions.csv"
    )

    events = pd.read_csv(
        "data/raw/subscription_events.csv"
    )

    subscriptions["start_date"] = pd.to_datetime(
        subscriptions["start_date"]
    ).dt.date

    subscriptions["end_date"] = pd.to_datetime(
        subscriptions["end_date"]
    ).dt.date

    invoices = []
    payments = []

    invoice_number = 1
    payment_number = 1

    for _, subscription in subscriptions.iterrows():

        subscription_id = subscription[
            "subscription_id"
        ]

        customer_id = subscription[
            "customer_id"
        ]

        start_date = subscription[
            "start_date"
        ]

        end_date = subscription[
            "end_date"
        ]

        billing_cycle = subscription[
            "billing_cycle"
        ]

        # ----------------------------------------------------
        # Determine subscription billing range
        # ----------------------------------------------------

        billing_end = (
            end_date
            if pd.notna(end_date)
            else END_DATE
        )

        # ----------------------------------------------------
        # Generate billing dates
        # ----------------------------------------------------

        current_date = start_date

        billing_step = (
            12
            if billing_cycle == "Annual"
            else 1
        )

        while current_date <= billing_end:

            if current_date > END_DATE:
                break

            # ------------------------------------------------
            # Determine active plan at invoice date
            # ------------------------------------------------

            plan_id = get_plan_at_date(
                subscription_id,
                current_date,
                subscriptions,
                events,
            )

            # If customer had already cancelled before this
            # billing date, stop generating invoices.
            if plan_id is None:
                break

            amount = get_invoice_amount(
                plan_id,
                billing_cycle,
            )

            # ------------------------------------------------
            # Determine invoice due date
            # ------------------------------------------------

            due_date = current_date + timedelta(
                days=15
            )

            # ------------------------------------------------
            # Determine invoice status
            # ------------------------------------------------

            random_value = random.random()

            if random_value < OVERDUE_RATE:

                invoice_status = "Overdue"

            elif (
                random_value
                < OVERDUE_RATE + 0.03
            ):

                invoice_status = "Pending"

            else:

                invoice_status = "Paid"

            invoice_id = (
                f"INV{invoice_number:07d}"
            )

            invoices.append(
                {
                    "invoice_id": invoice_id,
                    "customer_id": customer_id,
                    "subscription_id": subscription_id,
                    "invoice_date": current_date,
                    "due_date": due_date,
                    "amount": amount,
                    "invoice_status": invoice_status,
                }
            )

            # ------------------------------------------------
            # Generate payment
            # ------------------------------------------------

            if invoice_status in [
                "Paid",
                "Overdue",
            ]:

                payment_date = (
                    due_date
                    if invoice_status == "Overdue"
                    else current_date
                    + timedelta(
                        days=random.randint(
                            1,
                            15,
                        )
                    )
                )

                payment_status = "Successful"

                payment_random = random.random()

                if (
                    payment_random
                    < PAYMENT_FAILURE_RATE
                ):

                    payment_status = "Failed"

                elif (
                    payment_random
                    < PAYMENT_FAILURE_RATE
                    + REFUND_RATE
                ):

                    payment_status = "Refunded"

                payment_id = (
                    f"PAY{payment_number:07d}"
                )

                payments.append(
                    {
                        "payment_id": payment_id,
                        "invoice_id": invoice_id,
                        "customer_id": customer_id,
                        "payment_date": payment_date,
                        "amount": amount,
                        "payment_status": payment_status,
                        "payment_method": random.choice(
                            PAYMENT_METHODS
                        ),
                    }
                )

                payment_number += 1

            invoice_number += 1

            # ------------------------------------------------
            # Move to next billing period
            # ------------------------------------------------

            current_date = add_months(
                current_date,
                billing_step,
            )

    return (
        pd.DataFrame(invoices),
        pd.DataFrame(payments),
    )


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    df_invoices, df_payments = generate_billing()

    invoice_path = (
        "data/raw/invoices.csv"
    )

    payment_path = (
        "data/raw/payments.csv"
    )

    df_invoices.to_csv(
        invoice_path,
        index=False,
    )

    df_payments.to_csv(
        payment_path,
        index=False,
    )

    print(
        "Billing datasets generated successfully!"
    )

    print(
        f"Invoices generated: {len(df_invoices)}"
    )

    print(
        f"Payments generated: {len(df_payments)}"
    )

    print()

    print("Invoice status distribution:")

    print(
        df_invoices[
            "invoice_status"
        ].value_counts()
    )

    print()

    print("Payment status distribution:")

    print(
        df_payments[
            "payment_status"
        ].value_counts()
    )

    print()

    print(
        f"Invoices saved to: {invoice_path}"
    )

    print(
        f"Payments saved to: {payment_path}"
    )
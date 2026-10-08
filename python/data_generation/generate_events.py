# ============================================================
# CloudPulse CRM SaaS Analytics
# Subscription Events Generator
# ============================================================

import random

import pandas as pd

from config import (
    RANDOM_SEED,
    PLANS,
    EVENT_TYPES,
)


# ============================================================
# Configuration
# ============================================================

random.seed(RANDOM_SEED)


# ============================================================
# Helper Functions
# ============================================================

def get_mrr(plan_id):
    """Return monthly recurring revenue for a plan."""
    if plan_id is None:
        return 0.00

    return PLANS[plan_id]["monthly_price"]


def get_upgrade_plan(current_plan):
    """Return a higher plan when an upgrade is possible."""

    upgrade_map = {
        "PLAN001": "PLAN002",
        "PLAN002": "PLAN003",
    }

    return upgrade_map.get(current_plan)


def get_downgrade_plan(current_plan):
    """Return a lower plan when a downgrade is possible."""

    downgrade_map = {
        "PLAN003": "PLAN002",
        "PLAN002": "PLAN001",
    }

    return downgrade_map.get(current_plan)


# ============================================================
# Generate Events
# ============================================================

def generate_events():

    subscriptions = pd.read_csv(
        "data/raw/subscriptions.csv"
    )

    events = []

    event_number = 1

    for _, subscription in subscriptions.iterrows():

        subscription_id = subscription[
            "subscription_id"
        ]

        customer_id = subscription[
            "customer_id"
        ]

        plan_id = subscription["plan_id"]

        start_date = pd.to_datetime(
            subscription["start_date"]
        ).date()

        end_date = subscription["end_date"]

        subscription_status = subscription[
            "subscription_status"
        ]

        current_mrr = get_mrr(plan_id)

        # ----------------------------------------------------
        # 1. NEW EVENT
        # ----------------------------------------------------

        events.append(
            {
                "event_id": f"EVT{event_number:06d}",
                "subscription_id": subscription_id,
                "customer_id": customer_id,
                "event_date": start_date,
                "event_type": "NEW",
                "old_plan_id": None,
                "new_plan_id": plan_id,
                "old_mrr": 0.00,
                "new_mrr": current_mrr,
            }
        )

        event_number += 1

        # ----------------------------------------------------
        # No lifecycle events for subscriptions that end
        # immediately after starting.
        # ----------------------------------------------------

        if pd.isna(end_date):

            lifecycle_end = None

        else:

            lifecycle_end = pd.to_datetime(
                end_date
            ).date()

        # ----------------------------------------------------
        # 2. UPGRADE / DOWNGRADE
        # ----------------------------------------------------

        if lifecycle_end is not None:

            subscription_days = (
                lifecycle_end - start_date
            ).days

        else:

            subscription_days = 365

        # Longer-lived subscriptions have more opportunity
        # for plan changes.

        if subscription_days >= 180:

            lifecycle_probability = 0.35

            if random.random() < lifecycle_probability:

                change_type = random.choices(
                    ["UPGRADE", "DOWNGRADE"],
                    weights=[0.65, 0.35],
                    k=1,
                )[0]

                if change_type == "UPGRADE":

                    new_plan = get_upgrade_plan(
                        plan_id
                    )

                else:

                    new_plan = get_downgrade_plan(
                        plan_id
                    )

                if new_plan is not None:

                    event_date = start_date

                    if lifecycle_end is not None:

                        available_days = (
                            lifecycle_end - start_date
                        ).days

                        if available_days > 30:

                            random_days = random.randint(
                                30,
                                available_days - 1,
                            )

                            event_date = (
                                start_date
                                + pd.Timedelta(
                                    days=random_days
                                )
                            )

                    old_mrr = current_mrr

                    new_mrr = get_mrr(
                        new_plan
                    )

                    events.append(
                        {
                            "event_id": (
                                f"EVT{event_number:06d}"
                            ),
                            "subscription_id": (
                                subscription_id
                            ),
                            "customer_id": (
                                customer_id
                            ),
                            "event_date": event_date,
                            "event_type": change_type,
                            "old_plan_id": plan_id,
                            "new_plan_id": new_plan,
                            "old_mrr": old_mrr,
                            "new_mrr": new_mrr,
                        }
                    )

                    event_number += 1

        # ----------------------------------------------------
        # 3. CANCELLATION
        # ----------------------------------------------------

        if (
            subscription_status == "Cancelled"
            and lifecycle_end is not None
        ):

            events.append(
                {
                    "event_id": (
                        f"EVT{event_number:06d}"
                    ),
                    "subscription_id": (
                        subscription_id
                    ),
                    "customer_id": (
                        customer_id
                    ),
                    "event_date": lifecycle_end,
                    "event_type": "CANCELLATION",
                    "old_plan_id": plan_id,
                    "new_plan_id": None,
                    "old_mrr": current_mrr,
                    "new_mrr": 0.00,
                }
            )

            event_number += 1

    return pd.DataFrame(events)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    df_events = generate_events()

    output_path = (
        "data/raw/subscription_events.csv"
    )

    df_events.to_csv(
        output_path,
        index=False,
    )

    print(
        "Subscription events generated successfully!"
    )

    print(
        f"Rows generated: {len(df_events)}"
    )

    print(
        f"Saved to: {output_path}"
    )

    print()

    print("Event type distribution:")

    print(
        df_events["event_type"]
        .value_counts()
    )
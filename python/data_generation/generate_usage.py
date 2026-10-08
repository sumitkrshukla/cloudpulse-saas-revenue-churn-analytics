# ============================================================
# CloudPulse CRM SaaS Analytics
# Daily Usage Data Generator
# ============================================================

import random
from datetime import timedelta

import pandas as pd

from config import (
    RANDOM_SEED,
    END_DATE,
    USAGE_ACTIVITY_LEVELS,
)


# ============================================================
# Configuration
# ============================================================

random.seed(RANDOM_SEED)


# ============================================================
# Generate Usage
# ============================================================

def generate_usage():

    customers = pd.read_csv(
        "data/raw/customers.csv"
    )

    subscriptions = pd.read_csv(
        "data/raw/subscriptions.csv"
    )

    events = pd.read_csv(
        "data/raw/subscription_events.csv"
    )

    customers["signup_date"] = pd.to_datetime(
        customers["signup_date"]
    ).dt.date

    subscriptions["start_date"] = pd.to_datetime(
        subscriptions["start_date"]
    ).dt.date

    subscriptions["end_date"] = pd.to_datetime(
        subscriptions["end_date"]
    ).dt.date

    events["event_date"] = pd.to_datetime(
        events["event_date"]
    ).dt.date

    usage_records = []

    usage_number = 1

    # --------------------------------------------------------
    # Create lookup for cancellation dates
    # --------------------------------------------------------

    cancellation_dates = (
        events[
            events["event_type"]
            == "CANCELLATION"
        ]
        .groupby("customer_id")["event_date"]
        .min()
        .to_dict()
    )

    # --------------------------------------------------------
    # Generate customer × day usage
    # --------------------------------------------------------

    for _, customer in customers.iterrows():

        customer_id = customer[
            "customer_id"
        ]

        signup_date = customer[
            "signup_date"
        ]

        cancellation_date = (
            cancellation_dates.get(
                customer_id
            )
        )

        usage_end_date = END_DATE

        if cancellation_date is not None:

            # Generate usage up to cancellation.
            # A small amount of pre-churn decline
            # will be introduced later.
            usage_end_date = cancellation_date

        current_date = signup_date

        while current_date <= usage_end_date:

            # ------------------------------------------------
            # Determine baseline activity
            # ------------------------------------------------

            activity_level = random.choices(
                ["Low", "Medium", "High"],
                weights=[0.25, 0.50, 0.25],
                k=1,
            )[0]

            activity = USAGE_ACTIVITY_LEVELS[
                activity_level
            ]

            active_users = random.randint(
                activity["active_users"][0],
                activity["active_users"][1],
            )

            login_count = random.randint(
                activity["login_count"][0],
                activity["login_count"][1],
            )

            feature_usage = random.randint(
                activity["feature_usage"][0],
                activity["feature_usage"][1],
            )

            session_minutes = random.randint(
                activity["session_minutes"][0],
                activity["session_minutes"][1],
            )

            # ------------------------------------------------
            # Introduce pre-churn engagement decline
            # ------------------------------------------------

            if cancellation_date is not None:

                days_to_cancellation = (
                    cancellation_date
                    - current_date
                ).days

                if 0 <= days_to_cancellation <= 60:

                    decline_factor = (
                        days_to_cancellation / 60
                    )

                    active_users = max(
                        1,
                        int(
                            active_users
                            * decline_factor
                        ),
                    )

                    login_count = max(
                        1,
                        int(
                            login_count
                            * decline_factor
                        ),
                    )

                    feature_usage = max(
                        1,
                        int(
                            feature_usage
                            * decline_factor
                        ),
                    )

                    session_minutes = max(
                        5,
                        int(
                            session_minutes
                            * decline_factor
                        ),
                    )

            usage_records.append(
                {
                    "usage_id": (
                        f"USE{usage_number:08d}"
                    ),
                    "customer_id": customer_id,
                    "usage_date": current_date,
                    "active_users": active_users,
                    "login_count": login_count,
                    "feature_usage": feature_usage,
                    "session_minutes": session_minutes,
                }
            )

            usage_number += 1

            current_date += timedelta(
                days=1
            )

    return pd.DataFrame(
        usage_records
    )


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    df_usage = generate_usage()

    output_path = (
        "data/raw/usage.csv"
    )

    df_usage.to_csv(
        output_path,
        index=False,
    )

    print(
        "Usage dataset generated successfully!"
    )

    print(
        f"Rows generated: {len(df_usage):,}"
    )

    print(
        f"Saved to: {output_path}"
    )

    print()

    print("Date range:")

    print(
        df_usage["usage_date"].min(),
        "to",
        df_usage["usage_date"].max(),
    )

    print()

    print(
        "Unique customers:",
        df_usage["customer_id"].nunique(),
    )
# ============================================================
# CloudPulse CRM SaaS Analytics
# Customer Data Generator
# ============================================================

import random
from datetime import timedelta

import pandas as pd
from faker import Faker

from config import (
    RANDOM_SEED,
    START_DATE,
    END_DATE,
    NUM_CUSTOMERS,
    INDUSTRIES,
    CUSTOMER_SEGMENTS,
    REGIONS,
    ACQUISITION_CHANNELS,
    SEGMENT_WEIGHTS,
    ACQUISITION_CHANNEL_WEIGHTS,
)


# ============================================================
# Configuration
# ============================================================

random.seed(RANDOM_SEED)
fake = Faker()
fake.seed_instance(RANDOM_SEED)


# ============================================================
# Helper Functions
# ============================================================

def weighted_choice(options, weights):
    """Return one item using weighted probability."""
    return random.choices(
        options,
        weights=weights,
        k=1,
    )[0]


def random_date(start_date, end_date):
    """Generate a random date between two dates."""
    days_between = (end_date - start_date).days

    return start_date + timedelta(
        days=random.randint(0, days_between)
    )


# ============================================================
# Generate Customers
# ============================================================

def generate_customers():

    customers = []

    segment_options = list(SEGMENT_WEIGHTS.keys())
    segment_weights = list(SEGMENT_WEIGHTS.values())

    channel_options = list(ACQUISITION_CHANNEL_WEIGHTS.keys())
    channel_weights = list(ACQUISITION_CHANNEL_WEIGHTS.values())

    for i in range(1, NUM_CUSTOMERS + 1):

        customer_id = f"CUST{i:05d}"

        company_name = fake.company()

        industry = random.choice(INDUSTRIES)

        customer_segment = weighted_choice(
            segment_options,
            segment_weights,
        )

        country = fake.country()

        region = random.choice(REGIONS)

        signup_date = random_date(
            START_DATE,
            END_DATE,
        )

        acquisition_channel = weighted_choice(
            channel_options,
            channel_weights,
        )

        customers.append(
            {
                "customer_id": customer_id,
                "company_name": company_name,
                "industry": industry,
                "customer_segment": customer_segment,
                "country": country,
                "region": region,
                "signup_date": signup_date,
                "acquisition_channel": acquisition_channel,
            }
        )

    return pd.DataFrame(customers)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    df_customers = generate_customers()

    output_path = "data/raw/customers.csv"

    df_customers.to_csv(
        output_path,
        index=False,
    )

    print("Customer dataset generated successfully!")
    print(f"Rows generated: {len(df_customers)}")
    print(f"Saved to: {output_path}")
    print()
    print("Customer segment distribution:")
    print(df_customers["customer_segment"].value_counts())
# ============================================================
# CloudPulse CRM SaaS Analytics
# PostgreSQL Data Loader
# ============================================================

import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ============================================================
# Load Environment Variables
# ============================================================

load_dotenv()


DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")


DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}@"
    f"{DB_HOST}:{DB_PORT}/"
    f"{DB_NAME}"
)


engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)


# ============================================================
# Configuration
# ============================================================

DATA_PATH = "data/raw"


TABLE_ORDER = [
    "customers",
    "plans",
    "subscriptions",
    "subscription_events",
    "invoices",
    "payments",
    "usage",
]


# ============================================================
# Load Data
# ============================================================

def load_table(table_name):

    file_path = (
        f"{DATA_PATH}/{table_name}.csv"
    )

    print(
        f"\nLoading {table_name}..."
    )

    df = pd.read_csv(
        file_path
    )

    # Replace pandas NaN with None so PostgreSQL
    # receives proper SQL NULL values.
    df = df.where(
        pd.notnull(df),
        None,
    )

    df.to_sql(
    table_name,
    engine,
    if_exists="append",
    index=False,
    chunksize=1000,
)

    print(
        f"Loaded {len(df):,} rows into {table_name}"
    )


# ============================================================
# Verify Row Counts
# ============================================================

def verify_row_counts():

    print(
        "\n" + "=" * 60
    )

    print(
        "POSTGRESQL ROW COUNT VERIFICATION"
    )

    print(
        "=" * 60
    )

    with engine.connect() as connection:

        for table_name in TABLE_ORDER:

            result = connection.execute(
                text(
                    f"SELECT COUNT(*) "
                    f"FROM {table_name};"
                )
            )

            count = result.scalar()

            print(
                f"{table_name:<25} {count:,}"
            )


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    try:

        print(
            "Connecting to PostgreSQL..."
        )

        with engine.connect() as connection:

            connection.execute(
                text("SELECT 1;")
            )

        print(
            "PostgreSQL connection successful!"
        )

        for table_name in TABLE_ORDER:

            load_table(
                table_name
            )

        verify_row_counts()

        print(
            "\nData loading completed successfully!"
        )

    except Exception as error:

        print("\nData loading failed.")
        print("Error type:", type(error).__name__)

        if hasattr(error, "orig"):
            print("PostgreSQL error:", error.orig)
        else:
            print("Error:", error)
# ============================================================
# CloudPulse CRM SaaS Analytics
# Raw Data Validation
# ============================================================

import pandas as pd


DATA_PATH = "data/raw"


def load_data():

    customers = pd.read_csv(
        f"{DATA_PATH}/customers.csv"
    )

    subscriptions = pd.read_csv(
        f"{DATA_PATH}/subscriptions.csv"
    )

    events = pd.read_csv(
        f"{DATA_PATH}/subscription_events.csv"
    )

    invoices = pd.read_csv(
        f"{DATA_PATH}/invoices.csv"
    )

    payments = pd.read_csv(
        f"{DATA_PATH}/payments.csv"
    )

    usage = pd.read_csv(
        f"{DATA_PATH}/usage.csv"
    )

    return (
        customers,
        subscriptions,
        events,
        invoices,
        payments,
        usage,
    )


def check_duplicates(df, column):

    return df[column].duplicated().sum()


def check_foreign_keys(
    child_df,
    child_column,
    parent_df,
    parent_column,
):

    return (
        ~child_df[child_column].isin(
            parent_df[parent_column]
        )
    ).sum()


def validate():

    (
        customers,
        subscriptions,
        events,
        invoices,
        payments,
        usage,
    ) = load_data()

    print("=" * 60)
    print("CloudPulse Raw Data Validation")
    print("=" * 60)

    validation_failed = False

    # --------------------------------------------------------
    # 1. Row Counts
    # --------------------------------------------------------

    datasets = {
        "customers": customers,
        "subscriptions": subscriptions,
        "subscription_events": events,
        "invoices": invoices,
        "payments": payments,
        "usage": usage,
    }

    print("\nROW COUNTS")

    for name, df in datasets.items():

        print(
            f"{name:<25} {len(df):,}"
        )

        if len(df) == 0:
            validation_failed = True

    # --------------------------------------------------------
    # 2. Missing Values
    # --------------------------------------------------------

    print("\nMISSING VALUES")

    for name, df in datasets.items():

        missing = df.isna().sum().sum()

        print(
            f"{name:<25} {missing}"
        )

        # end_date and old/new plan IDs are allowed
        # to contain nulls.

    # --------------------------------------------------------
    # 3. Primary Key Duplicates
    # --------------------------------------------------------

    print("\nPRIMARY KEY DUPLICATES")

    primary_keys = {
        "customers": (
            customers,
            "customer_id",
        ),
        "subscriptions": (
            subscriptions,
            "subscription_id",
        ),
        "subscription_events": (
            events,
            "event_id",
        ),
        "invoices": (
            invoices,
            "invoice_id",
        ),
        "payments": (
            payments,
            "payment_id",
        ),
        "usage": (
            usage,
            "usage_id",
        ),
    }

    for name, (df, column) in primary_keys.items():

        duplicates = check_duplicates(
            df,
            column,
        )

        print(
            f"{name:<25} {duplicates}"
        )

        if duplicates > 0:
            validation_failed = True

    # --------------------------------------------------------
    # 4. Customer Foreign Keys
    # --------------------------------------------------------

    print("\nFOREIGN KEY VALIDATION")

    checks = [
        (
            "subscriptions → customers",
            subscriptions,
            "customer_id",
            customers,
            "customer_id",
        ),
        (
            "events → subscriptions",
            events,
            "subscription_id",
            subscriptions,
            "subscription_id",
        ),
        (
            "events → customers",
            events,
            "customer_id",
            customers,
            "customer_id",
        ),
        (
            "invoices → customers",
            invoices,
            "customer_id",
            customers,
            "customer_id",
        ),
        (
            "invoices → subscriptions",
            invoices,
            "subscription_id",
            subscriptions,
            "subscription_id",
        ),
        (
            "payments → invoices",
            payments,
            "invoice_id",
            invoices,
            "invoice_id",
        ),
        (
            "payments → customers",
            payments,
            "customer_id",
            customers,
            "customer_id",
        ),
        (
            "usage → customers",
            usage,
            "customer_id",
            customers,
            "customer_id",
        ),
    ]

    for (
        name,
        child_df,
        child_column,
        parent_df,
        parent_column,
    ) in checks:

        invalid = check_foreign_keys(
            child_df,
            child_column,
            parent_df,
            parent_column,
        )

        print(
            f"{name:<35} {invalid}"
        )

        if invalid > 0:
            validation_failed = True

    # --------------------------------------------------------
    # 5. Amount Validation
    # --------------------------------------------------------

    print("\nNEGATIVE AMOUNTS")

    amount_checks = {
        "invoices": invoices["amount"],
        "payments": payments["amount"],
        "events old_mrr": events["old_mrr"],
        "events new_mrr": events["new_mrr"],
    }

    for name, series in amount_checks.items():

        negative_count = (
            series.dropna() < 0
        ).sum()

        print(
            f"{name:<25} {negative_count}"
        )

        if negative_count > 0:
            validation_failed = True

    # --------------------------------------------------------
    # 6. Usage Validation
    # --------------------------------------------------------

    print("\nNEGATIVE USAGE METRICS")

    usage_columns = [
        "active_users",
        "login_count",
        "feature_usage",
        "session_minutes",
    ]

    for column in usage_columns:

        negative_count = (
            usage[column] < 0
        ).sum()

        print(
            f"{column:<25} {negative_count}"
        )

        if negative_count > 0:
            validation_failed = True

    # --------------------------------------------------------
    # 7. Subscription Date Validation
    # --------------------------------------------------------

    print("\nSUBSCRIPTION DATE VALIDATION")

    subscriptions[
        "start_date"
    ] = pd.to_datetime(
        subscriptions["start_date"]
    )

    subscriptions[
        "end_date"
    ] = pd.to_datetime(
        subscriptions["end_date"]
    )

    invalid_dates = (
        subscriptions["end_date"].notna()
        &
        (
            subscriptions["end_date"]
            <
            subscriptions["start_date"]
        )
    ).sum()

    print(
        "End date before start date:",
        invalid_dates,
    )

    if invalid_dates > 0:
        validation_failed = True

    # --------------------------------------------------------
    # 8. Usage Grain Validation
    # --------------------------------------------------------

    print("\nUSAGE GRAIN VALIDATION")

    duplicate_usage = usage.duplicated(
        [
            "customer_id",
            "usage_date",
        ]
    ).sum()

    print(
        "Duplicate customer-date records:",
        duplicate_usage,
    )

    if duplicate_usage > 0:
        validation_failed = True

    # --------------------------------------------------------
    # Final Result
    # --------------------------------------------------------

    print("\n" + "=" * 60)

    if validation_failed:

        print(
            "VALIDATION FAILED"
        )

        print(
            "Review the checks above before loading the data."
        )

    else:

        print(
            "ALL VALIDATION CHECKS PASSED"
        )

        print(
            "Raw data is ready for PostgreSQL loading."
        )

    print("=" * 60)


if __name__ == "__main__":

    validate()
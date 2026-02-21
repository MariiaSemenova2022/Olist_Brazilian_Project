
# E-Commerce Data Analysis Project
# Dataset: Brazilian E-Commerce Public Dataset (Olist)
# Author: Mariia Semenova


# 1. Import Required Libraries

import os
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt



# 2. Load Dataset

DATA_PATH = "olist_data"

tables = {
    file.replace(".csv", ""): pd.read_csv(os.path.join(DATA_PATH, file))
    for file in os.listdir(DATA_PATH)
    if file.endswith(".csv")
}

print("Tables loaded successfully.\n")


# 3. Quick Overview of All Tables

print("========== DATASET OVERVIEW ==========\n")

for table_name, df in tables.items():

    print(f"Table Name: {table_name}")
    print("-" * 50)

    # Shape
    print(f"Shape: {df.shape[0]} rows, {df.shape[1]} columns")

    # Column names
    print("\nColumns:")
    print(list(df.columns))

    # Data types
    print("\nData Types:")
    print(df.dtypes)

    # Missing values
    total_missing = df.isna().sum().sum()
    print(f"\nTotal Missing Values: {total_missing}")

    # Duplicate rows
    duplicates = df.duplicated().sum()
    print(f"Duplicate Rows: {duplicates}")

    print("\n" + "=" * 70 + "\n")



# 4. Customers Table Analysis

customers = tables["olist_customers_dataset"]

print("Customers Info:")
print(customers.info())

print("\nMissing values:")
print(customers.isna().sum())

print("\nDuplicate rows:", customers.duplicated().sum())

print("\nUnique customers:", customers["customer_unique_id"].nunique())


# Top 10 states by number of customers

top_10_states = customers["customer_state"].value_counts().head(10)

plt.figure(figsize=(10, 6))
plt.bar(top_10_states.index, top_10_states.values)
plt.title("Top 10 States by Number of Customers")
plt.xlabel("State")
plt.ylabel("Number of Customers")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()



# 5. Orders Table Processing

orders = tables["olist_orders_dataset"]

# Convert date columns to datetime
date_cols = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date",
]

for col in date_cols:
    orders[col] = pd.to_datetime(orders[col], errors="coerce")

# Business logic flags
orders["is_delivered"] = orders["order_status"] == "delivered"
orders["is_canceled"] = orders["order_status"] == "canceled"
orders["missing_approval"] = orders["order_approved_at"].isna()

# Delivery delay (only for delivered orders)
orders["delivery_delay_days"] = (
    orders["order_delivered_customer_date"]
    - orders["order_estimated_delivery_date"]
).dt.days

print("\nOrders processed.\n")


# 6. Payments Table Analysis

payments = tables["olist_order_payments_dataset"]

print("Duplicate rows in payments:", payments.duplicated().sum())
print("\nMissing values in payments:")
print(payments.isna().sum())

print("\nPayment types distribution:")
print(payments["payment_type"].value_counts())


# 7. Outlier Detection Using IQR

Q1 = payments["payment_value"].quantile(0.25)
Q3 = payments["payment_value"].quantile(0.75)
IQR = Q3 - Q1

lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

print("\nIQR Upper Bound:", upper_bound)

# Flag high-value payments
payments["high_value_order"] = payments["payment_value"] > upper_bound

print("High-value orders:")
print(payments["high_value_order"].value_counts())


# 8. Merge Payments with Orders

payments_orders = payments.merge(
    orders[["order_id", "order_purchase_timestamp"]],
    on="order_id",
    how="left"
)

payments_orders["month"] = (
    payments_orders["order_purchase_timestamp"].dt.to_period("M")
)


# 9. Monthly High-Value Order Summary

high_value_monthly = (
    payments_orders[payments_orders["high_value_order"]]
    .groupby("month")
    .agg(
        high_value_order_count=("order_id", "count"),
        total_high_value_payment=("payment_value", "sum")
    )
    .reset_index()
)

print("\nMonthly High-Value Summary:")
print(high_value_monthly)


plt.figure(figsize=(12, 5))
plt.bar(
    high_value_monthly["month"].astype(str),
    high_value_monthly["total_high_value_payment"]
)
plt.xticks(rotation=45)
plt.title("Total High-Value Payments per Month")
plt.xlabel("Month")
plt.ylabel("Total Payment (R$)")
plt.tight_layout()
plt.show()


# 10 Export Clean Data for PostgreSQL

print("\nExporting PostgreSQL-ready CSV files...")

# -------- Orders --------
orders_pg = orders[[
    "order_id",
    "customer_id",
    "order_status",
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]]

orders_pg.to_csv(
    "orders_pg.csv",
    index=False,
    sep=",",
    na_rep="\\N",
    quoting=csv.QUOTE_MINIMAL,
    date_format="%Y-%m-%d %H:%M:%S"
)

# -------- Payments --------
payments_pg = payments[[
    "order_id",
    "payment_sequential",
    "payment_type",
    "payment_installments",
    "payment_value"
]]

payments_pg.to_csv(
    "order_payments_pg.csv",
    index=False,
    sep=",",
    na_rep="\\N",
    quoting=csv.QUOTE_MINIMAL
)

# -------- Customers --------
customers_pg = customers[[
    "customer_id",
    "customer_unique_id",
    "customer_zip_code_prefix",
    "customer_city",
    "customer_state"
]]

customers_pg.to_csv(
    "customers_pg.csv",
    index=False,
    sep=",",
    na_rep="\\N",
    quoting=csv.QUOTE_MINIMAL
)

print("Export completed successfully.")
print("\nProject finished.")

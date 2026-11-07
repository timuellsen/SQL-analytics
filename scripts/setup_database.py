import os
import sqlite3
import pandas as pd

# path to CSV files and database
data_dir = "./data"
db_path = "ecommerce.db"

# make connection to SQLite-database
conn = sqlite3.connect(db_path)

# relating CSV names to table names in database
files = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_products_dataset.csv": "products",
    "olist_order_payments_dataset.csv": "payments",
}

# read CSVs and create SQL tables
for file_name, table_name in files.items():
    file_path = os.path.join(data_dir, file_name)
    if os.path.exists(file_path):
        df = pd.read_csv(file_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(
            f"Tables '{table_name}' created with {len(df)} lines."
        )
    else:
        print(f"File {file_name} not found!")

conn.close()
print("Database setup complete!")

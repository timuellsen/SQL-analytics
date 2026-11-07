import os
import sqlite3
import pandas as pd

# Pfad zu den entpackten CSV-Dateien und Ziel-Datenbank
data_dir = "./data"
db_path = "ecommerce.db"

# Verbindung zur SQLite-Datenbank herstellen (wird automatisch erstellt)
conn = sqlite3.connect(db_path)

# Zuordnung von CSV-Dateinamen zu Tabellennamen in der Datenbank
files = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_products_dataset.csv": "products",
    "olist_order_payments_dataset.csv": "payments",
}

# CSVs einlesen und als SQL-Tabellen speichern
for file_name, table_name in files.items():
    file_path = os.path.join(data_dir, file_name)
    if os.path.exists(file_path):
        df = pd.read_csv(file_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(
            f"Tabelle '{table_name}' erfolgreich mit {len(df)} Zeilen erstellt."
        )
    else:
        print(f"Datei {file_name} nicht gefunden!")

conn.close()
print("Datenbank-Setup erfolgreich abgeschlossen!")
"""Olist e-commerce ELT: load CSVs into Postgres bronze, then dbt build."""
from __future__ import annotations

import csv
import os
from datetime import datetime
from pathlib import Path

import psycopg2
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

DATA_DIR = Path("/opt/airflow/data")

# Olist CSV → bronze table mapping
CSV_TABLES = {
    "olist_customers_dataset.csv":                    "customers",
    "olist_orders_dataset.csv":                       "orders",
    "olist_order_items_dataset.csv":                  "order_items",
    "olist_order_payments_dataset.csv":               "order_payments",
    "olist_order_reviews_dataset.csv":                "order_reviews",
    "olist_products_dataset.csv":                     "products",
    "olist_sellers_dataset.csv":                      "sellers",
    "product_category_name_translation.csv":          "product_category_translation",
}


def _connection():
    return psycopg2.connect(
        host=os.environ["WAREHOUSE_HOST"],
        port=os.environ["WAREHOUSE_PORT"],
        user=os.environ["WAREHOUSE_USER"],
        password=os.environ["WAREHOUSE_PASSWORD"],
        dbname=os.environ["WAREHOUSE_DB"],
    )


def load_csv_to_bronze(csv_name: str, table: str) -> None:
    """Truncate and reload a bronze table from a CSV. Uses COPY for speed."""
    path = DATA_DIR / csv_name
    if not path.exists():
        raise FileNotFoundError(f"Missing CSV: {path}. Run `make seed` first.")

    # utf-8-sig drops a leading BOM if present (Olist's category translation has one).
    with open(path, "r", encoding="utf-8-sig", newline="") as fh:
        reader = csv.reader(fh)
        header = next(reader)

    cols_ddl = ", ".join(f'"{c}" text' for c in header)
    cols_list = ", ".join(f'"{c}"' for c in header)
    fq_table = f"bronze.{table}"

    with _connection() as conn, conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS bronze")
        cur.execute(f"DROP TABLE IF EXISTS {fq_table}")
        cur.execute(f"CREATE TABLE {fq_table} ({cols_ddl})")
        with open(path, "r") as fh:
            cur.copy_expert(
                f"COPY {fq_table} ({cols_list}) FROM STDIN WITH CSV HEADER",
                fh,
            )
        cur.execute(f"SELECT COUNT(*) FROM {fq_table}")
        count = cur.fetchone()[0]
        print(f"Loaded {count:,} rows into {fq_table}")


with DAG(
    dag_id="olist_pipeline",
    description="Olist e-commerce: CSV → Postgres bronze → dbt silver/gold",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
    tags=["dbt", "postgres", "olist"],
) as dag:

    load_tasks = []
    for csv_name, table in CSV_TABLES.items():
        load_tasks.append(
            PythonOperator(
                task_id=f"load_bronze_{table}",
                python_callable=load_csv_to_bronze,
                op_kwargs={"csv_name": csv_name, "table": table},
            )
        )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command="cd /opt/airflow/dbt && $DBT_BIN build --profiles-dir /opt/airflow/dbt --target dev",
    )

    load_tasks >> dbt_build

FROM apache/airflow:2.9.3-python3.11

# Airflow base packages (psycopg2 driver, providers, pandas).
COPY requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt

# dbt-postgres in its own venv — avoids pip resolver fights with Airflow.
# Pin to classic dbt-core 1.7.x; unpinned latest now resolves to dbt-fusion,
# which has no Postgres adapter yet.
RUN python -m venv /home/airflow/dbt-venv \
 && /home/airflow/dbt-venv/bin/pip install --no-cache-dir --upgrade pip \
 && /home/airflow/dbt-venv/bin/pip install --no-cache-dir \
        "dbt-core==1.7.18" "dbt-postgres==1.7.18"

ENV DBT_BIN=/home/airflow/dbt-venv/bin/dbt

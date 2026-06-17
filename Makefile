SHELL := /bin/bash

# Bring up the full stack (Postgres warehouse + Airflow + Metabase).
up:
	mkdir -p logs data
	docker compose --env-file .env up --build -d

down:
	docker compose --env-file .env down

logs:
	docker compose logs -f airflow-scheduler airflow-webserver

# Download the Olist CSVs from Kaggle into ./data.
# Requires KAGGLE_USERNAME and KAGGLE_KEY in your environment
# (https://www.kaggle.com/settings → API).
seed:
	python3 scripts/download_olist.py

# Drop into the warehouse Postgres.
psql:
	docker exec -ti olist-warehouse psql -U $${WAREHOUSE_USER:-olist} -d $${WAREHOUSE_DB:-olist}

# Run dbt locally (requires dbt-postgres in your venv).
dbt-run:
	cd dbt && dbt run --profiles-dir . --target dev

dbt-test:
	cd dbt && dbt test --profiles-dir . --target dev

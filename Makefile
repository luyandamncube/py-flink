SHELL := /bin/sh

.PHONY: help up down restart seed-topics sql-client logs producer-logs ps clean download-jars run-job list-jobs job

JOB ?=
JOB_ARG := $(word 2,$(MAKECMDGOALS))

help:
	@echo "Available targets:"
	@echo "  make up               - start the demo stack and seed topics"
	@echo "  make down             - stop the demo stack"
	@echo "  make restart          - restart the demo stack"
	@echo "  make seed-topics      - create demo Redpanda topics"
	@echo "  make sql-client       - open the Flink SQL client"
	@echo "  make logs             - tail all docker compose logs"
	@echo "  make producer-logs    - tail producer logs only"
	@echo "  make ps               - show running services"
	@echo "  make clean            - stop stack and remove volumes"
	@echo "  make download-jars    - get jars for flink runtime"
	@echo "  make list-jobs        - list available SQL jobs"
	@echo "  make run-job JOB=00   - run a SQL job by numeric prefix"
	@echo "  make job 00           - run a SQL job by numeric prefix"

up:
	./scripts/up.sh

down:
	./scripts/down.sh

restart: down up

seed-topics:
	./scripts/seed-topics.sh

sql-client:
	docker exec -it flink-demo-sql-client /opt/flink/bin/sql-client.sh

logs:
	docker compose logs -f

producer-logs:
	docker compose logs -f producer

ps:
	docker compose ps

clean:
	REMOVE_VOLUMES=true ./scripts/down.sh

download-jars:
	./scripts/download-flink-jars.sh

list-jobs:
	@echo "Available SQL jobs:"
	@find jobs/sql -maxdepth 1 -type f -name '*.sql' | sort | sed 's#^#  - #'

run-job:
	@if [ -z "$(JOB)" ]; then \
		echo "Usage: make run-job JOB=00"; \
		exit 1; \
	fi
	@sql_file=$$(find jobs/sql -maxdepth 1 -type f -name '$(JOB)_*.sql' | sort | head -n 1); \
	if [ -z "$$sql_file" ]; then \
		echo "No SQL file found for JOB=$(JOB)"; \
		exit 1; \
	fi; \
	sql_name=$$(basename "$$sql_file"); \
	echo "Running $$sql_name ..."; \
	docker exec -it flink-demo-sql-client /opt/flink/bin/sql-client.sh -f "/workspace/jobs/sql/$$sql_name"

job:
	@if [ -z "$(JOB_ARG)" ]; then \
		echo "Usage: make job 00"; \
		exit 1; \
	fi
	@$(MAKE) run-job JOB=$(JOB_ARG)

%:
	@:
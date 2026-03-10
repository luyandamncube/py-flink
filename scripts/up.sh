#!/bin/sh
set -eu

echo "Starting demo stack..."
docker compose up -d

echo
echo "Waiting for Redpanda to become ready..."
until docker exec flink-demo-redpanda rpk cluster info --brokers localhost:9092 >/dev/null 2>&1; do
  sleep 2
done

echo
echo "Seeding Redpanda topics..."
./scripts/seed-topics.sh

echo
echo "Demo stack is up."
echo "Useful URLs:"
echo "  Flink UI:           http://localhost:8082"
echo "  Redpanda Console:   http://localhost:8081"
echo "  MinIO API:          http://localhost:9000"
echo "  MinIO Console:      http://localhost:9001"
echo
echo "Useful commands:"
echo "  Open SQL client:"
echo "    docker exec -it flink-demo-sql-client /opt/flink/bin/sql-client.sh"
echo
echo "  View producer logs:"
echo "    docker compose logs -f producer"
echo
echo "  Run SQL setup:"
echo "    make job 00 # /workspace/jobs/sql/00_setup.sql)"
echo "    make job 01 # /workspace/jobs/sql/01_high_value_orders.sql"
echo "    make job 02 # /workspace/jobs/sql/02_windowed_revenue_by_region.sql"
echo "    make job 03 # /workspace/jobs/sql/03_order_counts_by_region.sql"
echo "    make job 04 # /workspace/jobs/sql/04_print_debug.sql"
echo "    make job 05 # /workspace/jobs/sql/05_cleanup.sql"
echo "    make job 06 # /workspace/jobs/sql/06_filesystem_sink.sql"
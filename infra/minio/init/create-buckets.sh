#!/bin/sh
set -eu

MINIO_ALIAS="${MINIO_ALIAS:-local}"
MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://minio:9000}"
MINIO_ROOT_USER="${MINIO_ROOT_USER:-minio}"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minio123}"

CHECKPOINTS_BUCKET="${CHECKPOINTS_BUCKET:-flink-checkpoints}"
SAVEPOINTS_BUCKET="${SAVEPOINTS_BUCKET:-flink-savepoints}"
WAREHOUSE_BUCKET="${WAREHOUSE_BUCKET:-flink-warehouse}"

echo "Configuring MinIO alias '${MINIO_ALIAS}' at ${MINIO_ENDPOINT} ..."
mc alias set "${MINIO_ALIAS}" "${MINIO_ENDPOINT}" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"

echo "Creating buckets if missing ..."
mc mb -p "${MINIO_ALIAS}/${CHECKPOINTS_BUCKET}" || true
mc mb -p "${MINIO_ALIAS}/${SAVEPOINTS_BUCKET}" || true
mc mb -p "${MINIO_ALIAS}/${WAREHOUSE_BUCKET}" || true

echo "Current buckets:"
mc ls "${MINIO_ALIAS}"
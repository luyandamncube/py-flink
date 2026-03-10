#!/bin/sh
set -eu

LIB_DIR="infra/flink/lib"

KAFKA_JAR="flink-sql-connector-kafka-3.4.0-1.20.jar"
KAFKA_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.4.0-1.20/${KAFKA_JAR}"

S3_JAR="flink-s3-fs-hadoop-1.20.1.jar"
S3_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.20.1/${S3_JAR}"

mkdir -p "${LIB_DIR}"

download_if_missing() {
  jar_name="$1"
  jar_url="$2"
  jar_path="${LIB_DIR}/${jar_name}"

  if [ -s "${jar_path}" ]; then
    echo "Already present: ${jar_path}"
    return
  fi

  echo "Downloading ${jar_name} ..."
  wget -O "${jar_path}" "${jar_url}"
  echo "Saved to ${jar_path}"
}

download_if_missing "${KAFKA_JAR}" "${KAFKA_URL}"
download_if_missing "${S3_JAR}" "${S3_URL}"

echo
echo "Downloaded jars:"
ls -lh "${LIB_DIR}"
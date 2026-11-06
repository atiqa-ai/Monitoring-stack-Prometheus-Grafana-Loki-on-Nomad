#!/usr/bin/env bash
set -euo pipefail

echo "Preparing persistent storage..."

sudo install -d -m 0700 -o 65534 -g 65534 \
  /var/lib/nomad-monitoring/prometheus

sudo install -d -m 0700 -o 10001 -g 10001 \
  /var/lib/nomad-monitoring/loki

sudo install -d -m 0700 -o 472 -g 0 \
  /var/lib/nomad-monitoring/grafana

echo "Storage preparation completed."

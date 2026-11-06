# Nomad Monitoring Stack — Quick Start

## Requirements

- Linux host (tested: Ubuntu 26.04.1 LTS)
- Docker Engine
- HashiCorp Nomad server and client
- At least one Nomad Docker-capable client
- Available ports: 3000, 3100, 9090 and 12345
- Sufficient RAM and disk space

## 1. Clone the repository

git clone https://github.com/atiqa-ai/nomad-monitoring-stack

cd nomad-monitoring-stack

Replace YOUR-USERNAME with the actual repository owner.

## 2. Prepare storage

./scripts/prepare-storage.sh

## 3. Configure Nomad

Edit your existing Nomad agent configuration.

Enable:

telemetry {
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

Add the three host volumes from:

setup/nomad-client-volumes.example.txt

Merge these settings into the existing client block.

Validate:

sudo nomad config validate /etc/nomad.d

Restart Nomad only on the new installation:

sudo systemctl restart nomad

Verify:

nomad server members
nomad node status -self

## 4. Deploy the monitoring stack

Run these commands from the repository root:

nomad job validate jobs/prometheus.nomad.hcl
nomad job run jobs/prometheus.nomad.hcl

nomad job validate jobs/loki.nomad.hcl
nomad job run jobs/loki.nomad.hcl

nomad job validate jobs/alloy.nomad.hcl
nomad job run jobs/alloy.nomad.hcl

nomad job validate jobs/grafana.nomad.hcl
nomad job run jobs/grafana.nomad.hcl

## 5. Verify

nomad job status

curl -fsS http://127.0.0.1:9090/-/ready

curl -fsS http://127.0.0.1:3100/ready

curl -fsS http://127.0.0.1:12345/-/ready

curl -fsS http://127.0.0.1:3000/api/health

## 6. Open Grafana

http://127.0.0.1:3000

Change the default administrator password at first login.

Open the provisioned Nomad Monitoring dashboard.

## Scope and security

This is a single-node local development setup.

The Alloy collector covers the test application, not all
containers automatically.

Localhost-bound services are not directly accessible from
another computer without a secure tunnel.

TLS, ACLs, backup restoration, restart recovery and
production hardening are not part of the verified scope.

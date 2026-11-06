# Final Project Completion Report

## Project information

| Field | Value |
|---|---|
| Title | Monitoring Stack: Prometheus, Grafana & Loki on Nomad |
| Platform | Ubuntu 26.04.1 LTS |
| Scheduler | HashiCorp Nomad 2.1.1, single-node `dc1` |
| Runtime | Docker 29.9.3 |
| Core observability services | Prometheus 3.13.5; Loki 3.7.9; Grafana Alloy 1.21.3; Grafana 13.3.0 |
| Validation | Local, non-disruptive tests, 7 November 2026 |
| Deployment status | Four Nomad jobs successfully deployed and reported healthy in supplied evidence |
| Documentation status | Phase 6 documents prepared; local repository integration requires the user's action |

## Objective

Build a single-node, Nomad-managed monitoring lab that exposes Nomad metrics in Prometheus, collects a test application's stdout with Alloy, stores those logs in Loki, and displays metrics and logs together in Grafana.

## Completed work by phase

1. **Environment verification:** Inspected Ubuntu, Docker, Nomad server/client, networking, storage capacity and local project structure.
2. **Prometheus:** Enabled Nomad telemetry; deployed a Prometheus Docker job through Nomad; created persistent storage; verified both Prometheus and Nomad scrape targets were UP.
3. **Loki and Alloy:** Deployed Loki with filesystem storage; configured Alloy to tail the `nomad-log-demo` task's stdout; queried real logs from Loki.
4. **Grafana:** Deployed Grafana with persistent storage; provisioned Prometheus/Loki data sources; created a four-panel metrics-and-logs dashboard; verified it in Grafana.
5. **Validation:** Confirmed all four Nomad jobs were running/healthy; checked readiness endpoints, five-minute scrape samples, recent Loki log queries, resource consumption, three host-volume mounts and loopback bindings; saved nine evidence files locally.
6. **Documentation:** Prepared README, architecture, deployment/verification, test report, runbook, handover checklist and this summary. No existing service configurations were changed during documentation authoring.

## Technical results

- Four required Nomad jobs running and with successful deployments: `prometheus`, `loki`, `grafana`, `nomad-log-demo`.
- Prometheus returned `up=1` for both `nomad` and `prometheus`, including a five-minute minimum over observed samples.
- Loki returned 10 recent `phase3-log-check` messages in one stream.
- The Grafana dashboard showed Scrape Target Health, Nomad Allocated CPU, Nomad Allocated Memory and Nomad Application Logs.
- Loopback listener checks confirmed monitoring HTTP ports 9090, 3100, 12345 and 3000 bound to `127.0.0.1`.
- Persistent data mounts were confirmed for Prometheus `/prometheus`, Loki `/loki` and Grafana `/var/lib/grafana`.
- Observed available RAM was 2.2 GiB; root disk available 162 GiB; monitoring/demo container memory total approximately 591.8 MiB in one snapshot.

## Artifacts

- **Job specifications:** `jobs/*.nomad.hcl`
- **Service configurations:** `config/prometheus/`, `config/loki/`, `config/alloy/`, `config/grafana/`
- **Dashboard:** `dashboards/nomad-observability.json`
- **Evidence:** `reports/phase5/` (nine files created on local Ubuntu, not included in this package)
- **Screenshots:** `screenshots/grafana-dashboard-verified.png` is the user-provided dashboard screenshot included in this bundle (review bookmarks before public release).
- **Documentation:** `README.md`, `docs/*.md`, `reports/phase6/FINAL-COMPLETION-REPORT.md`

## Delivery status and boundaries

**Lab objective:** Met for the demonstrated monitoring and logging workflow.
**Functional validation:** Completed for agreed non-disruptive scope.
**Documentation artifacts:** Integrated into the local project; GitHub publication and fresh-machine validation are pending.
**No claim of production readiness:** Disaster recovery, host/alloc restart persistence, high availability, complete cluster log collection, alerting, and Nomad security hardening were not tested.

## Next opportunities (not required for this lab)

Add real application log streams, host exporters, alerts, backup/restore tests, retention checks, HTTPS/mTLS and access control. Test failover only in an approved, reversible environment with backups.

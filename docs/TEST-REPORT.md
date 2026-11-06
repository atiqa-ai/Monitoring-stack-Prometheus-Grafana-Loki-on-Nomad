# Phase 5 — Monitoring Stack Test & Validation Report

**Project:** Prometheus, Grafana and Loki on Nomad
**Test date:** 7 November 2026, Asia/Karachi (terminal records and saved evidence)
**Method:** Non-disruptive inspection, API queries, CLI status, Docker stats and Grafana dashboard observation.
**Scope:** Local single-node cluster. No destructive failure/recovery tests.

## 1. Executive findings

The stack's core test objectives **passed** in the observed sessions. Nomad reported all four jobs running with healthy deployments; Prometheus scraped both `nomad` and `prometheus`; Alloy read the test application's stdout and Loki returned recent logs; Grafana previously displayed a four-panel metrics/logs dashboard; Docker resources and host storage showed no immediate exhaustion; all four monitoring HTTP endpoints were bound to loopback.

A successful HTTP/API response is not equivalent to an HA, recovery or production security certification.

## 2. Detailed test matrix

| ID | Test | Evidence observed | Assessment |
|---|---|---|---|
| T01 | Nomad server and client | Server `alive`/leader; node `ready` | PASS |
| T02 | Four Nomad jobs | `prometheus`, `loki`, `grafana`, `nomad-log-demo` all `running`, deployment successful, healthy 1/1 | PASS |
| T03 | Monitoring HTTP APIs | Prometheus ready; Loki `ready`; Alloy `Alloy is ready.`; Grafana API `database: ok`, version 13.3.0 | PASS |
| T04 | Prometheus scrape targets | `prometheus` and `nomad` `health=up`; `up` query returned both `1` | PASS |
| T05 | Five-minute Prometheus scrape check | `min_over_time(up{job=~"prometheus|nomad"}[5m])` returned `1` for both targets | PASS for sampled window |
| T06 | Nomad allocated CPU/memory | Grafana dashboard panels populated; allocation metrics available | PASS for allocated metrics (not actual host utilization) |
| T07 | Test application stdout | Ten time-stamped `phase3-log-check` lines shown ~10s apart | PASS |
| T08 | Alloy log reader | `start tailing file` event for `/alloc/logs/log-demo.stdout.0`; no error in supplied startup lines | PASS for observed event |
| T09 | Loki recent ingestion | `Streams: 1`, `Log entries: 10`, latest events from test app | PASS |
| T10 | Grafana dashboard | User-provided screenshot showed four populated panels after correcting PromQL syntax | PASS at time of screenshot |
| T11 | Docker host resources | 2.2 GiB available RAM; 162 GiB available disk; low load average | PASS for observed snapshot |
| T12 | Persistent host mounts | Three volumes registered, container mappings verified, files present | PASS for mounted storage |
| T13 | Monitoring service bindings | Ports 3000, 3100, 9090, 12345 bound to `127.0.0.1` | PASS for those endpoints |
| T14 | Test evidence creation | Nine files listed under `reports/phase5/` | PASS for file creation |


## 3. Observed deployment data

| Service | Image | Job | Allocation prefix |
|---|---|---|---|
| Prometheus | `prom/prometheus:v3.13.5` | prometheus | `2b5416c8` |
| Loki | `grafana/loki:3.7.9` | loki | `a3f58503` |
| Grafana | `grafana/grafana:13.3.0` | grafana | `fb1cc14f` |
| Alloy + demo | `grafana/alloy:v1.21.3`, `busybox:1.37.0` | nomad-log-demo | `9b519743` |

Allocation IDs are historical observations and may change if Nomad reschedules jobs.

## 4. Resource snapshot

At the user's reported observation time:

| Resource | Measured |
|---|---|
| Host RAM | 6.7 GiB total; 4.4 GiB used; 2.2 GiB available |
| Swap | 234 MiB used out of 4.0 GiB |
| Root disk | 233 GiB total; 60 GiB used; 162 GiB available; 27% used |
| Load averages | 0.48 (1 min), 0.84 (5 min), 0.95 (15 min) |
| Grafana container | 2.59% CPU; 430.5 MiB / 768 MiB |
| Loki container | 1.52% CPU; 74.11 MiB / 1 GiB |
| Prometheus container | 3.31% CPU; 48.37 MiB / 768 MiB |
| Alloy container | 0.66% CPU; 37.99 MiB / 256 MiB |
| Log generator | 0.00% CPU; 852 KiB / 64 MiB |

Approximate total of **the five monitoring/demo containers** was **591.8 MiB** (430.5 + 74.11 + 48.37 + 37.99 + 852/1024). This excludes the unrelated `rollback-demo-fixed` container. Single-snapshot CPU percentages must not be treated as long-run capacity measurements.

## 5. Storage snapshot

| Service | Confirmed host path | Observed `du -sh` |
|---|---|---|
| Prometheus | `/var/lib/nomad-monitoring/prometheus` | 3.2M |
| Loki | `/var/lib/nomad-monitoring/loki` | 216K |
| Grafana | `/var/lib/nomad-monitoring/grafana` | 545M |

Loki's small directory size is a single snapshot; it does not prove retention or flush persistence. Grafana's storage footprint was not root-caused and should be observed over time. Only actual mount/data presence was tested, **not data survival after allocation replacement**.

## 6. Evidence inventory

The following files were created **on the user's Ubuntu machine**, not inside this downloadable package:

```text
reports/phase5/test-timestamp.txt
reports/phase5/nomad-jobs.txt
reports/phase5/nomad-node.txt
reports/phase5/docker-resources.txt
reports/phase5/system-memory.txt
reports/phase5/disk-usage.txt
reports/phase5/prometheus-targets.json
reports/phase5/grafana-health.json
reports/phase5/loki-test-logs.json
```

The shell commands and `ls -lh` confirmed that these files exist on the user's machine; their full saved contents were **not independently opened** during this chat. Terminal outputs and the bundled `screenshots/grafana-dashboard-verified.png` (user-provided) are additional evidence.




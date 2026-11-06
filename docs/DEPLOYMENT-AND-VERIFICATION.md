# Deployment History and Safe Verification Guide

**Purpose:** Record how the working local monitoring stack was assembled and provide **read-only checks** for handover. This guide does not ask operators to redeploy or restart existing jobs.

## 1. Verified prerequisites

- Ubuntu 26.04.1 LTS (x86-64); 12 logical CPUs; 6.7 GiB RAM; 4.0 GiB swap.
- Docker 29.9.3 with active daemon.
- HashiCorp Nomad 2.1.1, server and client co-located in datacenter `dc1`.
- Nomad Docker driver available and healthy; existing Nomad job set: `prometheus`, `loki`, `grafana`, `nomad-log-demo`.
- Local project directory: `/home/mavkaaa_/projects/nomad-monitoring`.

## 2. Deployment sequence (historical record, not commands to rerun)

| Phase | Actions performed | Evidence |
|---|---|---|
| 1 | Verified Nomad, Docker, ports, system resources; created project structure | Phase 1 terminal output |
| 2 | Enabled Nomad telemetry; configured `prometheus-data`; validated and deployed Prometheus; checked scrape targets | Nomad job status, readiness and `up=1` |
| 3 | Configured `loki-data`, Loki 3.7.9 and Alloy 1.21.3 sidecar with BusyBox log generator | Loki query returned 10 real log entries |
| 4 | Configured `grafana-data`, provisioned two data sources and a four-panel dashboard; deployed Grafana 13.3.0 | Grafana screenshot and `/api/health` |
| 5 | Checked service health, resource use, persistent mounts, recent logs, five-minute scrape health, loopback bindings; saved evidence | `reports/phase5/` and chat terminal outputs |
| 6 | Prepared documentation and delivery materials without service changes | This documentation bundle; local integration still required |

### Configuration inventory

```text
jobs/prometheus.nomad.hcl
jobs/loki.nomad.hcl
jobs/alloy.nomad.hcl
jobs/grafana.nomad.hcl
config/prometheus/prometheus.yml
config/loki/loki.yaml
config/alloy/config.alloy
config/grafana/provisioning/datasources/datasources.yml
config/grafana/provisioning/dashboards/providers.yml
dashboards/nomad-observability.json
```

The host agent file `/etc/nomad.d/nomad.hcl` includes Nomad telemetry and static host volume registrations. **Do not copy credentials, tokens, raw host configuration, or secrets to public version control without review.**

## 3. Read-only day-to-day verification

Run on the Ubuntu host:

```bash
cd ~/projects/nomad-monitoring
nomad server members
nomad node status
nomad job status
nomad job status prometheus
nomad job status loki
nomad job status grafana
nomad job status nomad-log-demo
```

Inspect readiness:

```bash
curl -fsS http://127.0.0.1:9090/-/ready; echo
curl -fsS http://127.0.0.1:3100/ready; echo
curl -fsS http://127.0.0.1:12345/-/ready; echo
curl -fsS http://127.0.0.1:3000/api/health; echo
```

Prometheus queries:

```bash
curl -fsS -G http://127.0.0.1:9090/api/v1/query \
  --data-urlencode 'query=up{job=~"nomad|prometheus"}' | python3 -m json.tool

curl -fsS -G http://127.0.0.1:9090/api/v1/query \
  --data-urlencode 'query=min_over_time(up{job=~"nomad|prometheus"}[5m])' \
  | python3 -m json.tool
```

Loki query:

```bash
curl -fsS -G http://127.0.0.1:3100/loki/api/v1/query_range \
  --data-urlencode 'query={job="nomad-log-demo"} |= "phase3-log-check"' \
  --data-urlencode 'since=10m' --data-urlencode 'limit=10' \
  | python3 -m json.tool
```

Inspect application and collector logs (short allocation ID was `9b519743` at verification time; resolve a new allocation ID with `nomad job status nomad-log-demo` if necessary):

```bash
nomad alloc logs -task=log-demo -tail -n 10 9b519743
nomad alloc logs -stderr -task=alloy -tail -n 30 9b519743
```

Use a real allocation ID; `ALLOCATION_ID` is a placeholder, not a literal value. A previous `-job=nomad-log-demo` invocation produced a parsing error on Nomad 2.1.1; the direct ID syntax above was confirmed working.

## 4. Read-only config syntax validation

```bash
cd ~/projects/nomad-monitoring
nomad job validate jobs/prometheus.nomad.hcl
nomad job validate jobs/loki.nomad.hcl
nomad job validate jobs/alloy.nomad.hcl
nomad job validate jobs/grafana.nomad.hcl
python3 -m json.tool dashboards/nomad-observability.json >/dev/null
```

For Prometheus YAML, an official image's `promtool` can check syntax without deploying:

```bash
docker run --rm --entrypoint /bin/promtool \
  --mount type=bind,src="$PWD/config/prometheus/prometheus.yml",dst=/etc/prometheus/prometheus.yml,readonly \
  prom/prometheus:v3.13.5 check config /etc/prometheus/prometheus.yml
```

For Loki YAML, use **project root** as current directory so the bind source is a file:

```bash
docker run --rm \
  --mount type=bind,src="$PWD/config/loki/loki.yaml",dst=/etc/loki/custom.yaml,readonly \
  grafana/loki:3.7.9 -config.file=/etc/loki/custom.yaml -verify-config
```

These commands create short-lived local verification containers only; they do not alter existing Nomad jobs. If user requests no new containers at all, skip image-based validation.

## 5. Validate host volume mounts without disruption

```bash
nomad node status -self | grep 'Host Volumes'
for image in prom/prometheus:v3.13.5 grafana/loki:3.7.9 grafana/grafana:13.3.0; do
  printf 'Checking %s\n' "$image"
  id=$(docker ps -q --filter "ancestor=$image" | head -n 1)
  if [ -n "$id" ]; then
    docker inspect --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}' "$id"
  fi
done
sudo du -sh /var/lib/nomad-monitoring/{prometheus,loki,grafana}
```

## 6. Deployment management boundary

**No command in this handover guide starts, stops, restarts, or modifies the existing monitoring jobs.** Any future change should first be reviewed with `nomad job plan` and backed up, then performed under an approved change window. Single-host storage and no demonstrated restore procedure make uncontrolled replacements risky.


# Operations & Troubleshooting Runbook

**Audience:** Project owner / evaluator of the single-node Nomad monitoring lab.
**Mode:** Diagnostic commands are read-only unless clearly marked otherwise. No restart or redeployment is required for this documentation handover.

## 1. Daily checks

```bash
cd ~/projects/nomad-monitoring
nomad job status
curl -fsS http://127.0.0.1:9090/-/ready; echo
curl -fsS http://127.0.0.1:3100/ready; echo
curl -fsS http://127.0.0.1:12345/-/ready; echo
curl -fsS http://127.0.0.1:3000/api/health; echo
docker stats --no-stream
free -h
df -h /
```

Open `http://127.0.0.1:3000/d/nomad-observability` from the local Ubuntu browser, select Last 15 minutes, refresh, and check all panels. Do not share Grafana passwords or API tokens.

## 2. Prometheus query reports no data

1. Check `curl -fsS http://127.0.0.1:9090/-/ready`.
2. Query `up` from the Prometheus API or UI; confirm `nomad` and `prometheus` both `1`.
3. Verify Grafana's provisioned Prometheus URL is `http://127.0.0.1:9090` and the target dashboard time range has samples.
4. Correct PromQL regex syntax precisely: `up{job=~"prometheus|nomad"}`. A syntax error such as `unexpected identifier "prometheus"` is a query issue, not proof of failed scraping.
5. Inspect `nomad job status prometheus` and current allocation logs only if needed.

## 3. Loki returns an empty log result

1. Verify `nomad job status nomad-log-demo` and check the current allocation ID.
2. Inspect application stdout:

   ```bash
   nomad alloc logs -task=log-demo -tail -n 10 9b519743
   ```

   Replace `9b519743` if that allocation no longer exists.
3. Inspect Alloy stderr:

   ```bash
   nomad alloc logs -stderr -task=alloy -tail -n 30 9b519743
   ```

4. Query the last 10 minutes:

   ```bash
   curl -fsS -G http://127.0.0.1:3100/loki/api/v1/query_range \
     --data-urlencode 'query={job="nomad-log-demo"} |= "phase3-log-check"' \
     --data-urlencode 'since=10m' --data-urlencode 'limit=20' \
     | python3 -m json.tool
   ```

5. An empty result can be caused by time-window mismatch, no new demo events, a stopped allocation, or collector/ingestion failure. Do not assume which without evidence.
6. Alloy's informational `no peer discovery configured` message is not an error in this observed single-instance setup.

## 4. Nomad CLI pitfalls learned during deployment

- `nomad job plan` previews placement; it does **not** deploy a job. Only `nomad job run` would submit it, and it is **not** part of this documentation phase.
- `ALLOCATION_ID` / `YOUR_ACTUAL_ALLOCATION_ID` are placeholders. Use the actual allocation ID from `nomad job status`.
- `nomad alloc logs -task=log-demo -tail -n 10 9b519743` is a confirmed working syntax for this Nomad 2.1.1 installation.
- The user's `nomad alloc logs -job=nomad-log-demo` invocation produced `invalid boolean value` in that environment. Prefer direct allocation syntax.
- Run configuration validation from the project root where the relative paths in the `file()` job expressions resolve.
- For Docker's `-v` bind mounts, a missing source path can create an unexpected directory. Prefer `--mount type=bind,src=...,dst=...,readonly` for validation and confirm source file exists first.

## 5. Permission and storage diagnostics

```bash
nomad node status -self | grep 'Host Volumes'
sudo ls -ld /var/lib/nomad-monitoring/{prometheus,loki,grafana}
sudo du -sh /var/lib/nomad-monitoring/{prometheus,loki,grafana}
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

Previously confirmed ownership: Prometheus UID/GID `65534`, Loki `10001:10001`, Grafana `472:0`. A mismatched owner can cause write failures; review logs before changing permissions. **Do not run `chmod -R 777`, blindly `chown` unrelated directories, or delete TSDB/storage directories**.

## 6. Network checks

```bash
sudo ss -lntp | grep -E ':(9090|3100|12345|3000)\b'
sudo ufw status
```

Four monitoring endpoints were observed bound to `127.0.0.1`. Nomad ports were previously observed listening on wider interfaces. This is a local lab, not a public-facing deployment. Do not open firewall ports for convenience without a justified access design.

## 7. Escalation checklist (without changes)

Collect: failed command and full error, `nomad job status <job>`, current allocation ID, relevant task stdout/stderr, API response/HTTP status, `docker stats --no-stream`, available disk and RAM, and the latest configuration change. Redact passwords, token values and sensitive logs before sharing.

**Recovery is not validated:** No forced restarts, automatic rescheduling or restore drill was conducted. Do not claim that the system was proven to recover after failures. If such testing is required, use a separate approved maintenance window and verified backups.

## 8. Production gaps

- Nomad mTLS/ACL/bootstrap configuration needs security hardening.
- Add TLS/auth gateway where remote access is necessary; maintain Grafana login security.
- Add alerting, exporters, collection for real application/system logs and log retention verification.
- Define backup/restore procedure and run recovery drills.
- Consider multi-node scheduling and highly available storage before treating monitoring as infrastructure-critical.

## References

- [Nomad job status and allocation concepts](https://developer.hashicorp.com/nomad/docs/concepts/job.mdx)
- [Grafana provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Loki retention](https://grafana.com/docs/loki/latest/operations/storage/retention/)

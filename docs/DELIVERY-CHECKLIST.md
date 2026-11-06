# Phase 6 — Delivery & Handover Checklist

**Delivery target:** Existing local repository `~/projects/nomad-monitoring`
**No service changes:** The documentation package contains only Markdown. Do not redeploy, restart or modify any running service as part of this phase.

## A. Documentation files to integrate

- [ ] Root `README.md` reviewed and updated (backup old file first).
- [ ] `docs/ARCHITECTURE.md` saved.
- [ ] `docs/DEPLOYMENT-AND-VERIFICATION.md` saved.
- [ ] `docs/TEST-REPORT.md` saved.
- [ ] `docs/OPERATIONS-RUNBOOK.md` saved.
- [ ] `docs/DELIVERY-CHECKLIST.md` saved.
- [ ] `reports/phase6/FINAL-COMPLETION-REPORT.md` saved.

## B. Existing technical artifacts — preserve as-is

- [ ] `jobs/prometheus.nomad.hcl` exists.
- [ ] `jobs/loki.nomad.hcl` exists.
- [ ] `jobs/alloy.nomad.hcl` exists.
- [ ] `jobs/grafana.nomad.hcl` exists.
- [ ] `config/prometheus/prometheus.yml` exists.
- [ ] `config/loki/loki.yaml` exists.
- [ ] `config/alloy/config.alloy` exists.
- [ ] `config/grafana/provisioning/datasources/datasources.yml` exists.
- [ ] `config/grafana/provisioning/dashboards/providers.yml` exists.
- [ ] `dashboards/nomad-observability.json` exists.

No HCL, YAML, Docker images or service state needs to change in Phase 6.

## C. Evidence and demonstration

- [ ] Nine existing evidence files retained in `reports/phase5/`.
- [ ] User-provided dashboard screenshot from this package copied to `screenshots/grafana-dashboard-verified.png` (review browser bookmarks before public sharing).
- [ ] `nomad job status` reviewed with all four monitoring jobs running.
- [ ] Prometheus: Nomad and Prometheus targets `up=1`.
- [ ] Loki: current demo logs shown from `nomad-log-demo` stream.
- [ ] Grafana: four panels show metrics/logs; note target health and allocation metrics.
- [ ] Review included date/time and current state before presenting earlier snapshots as if live.

## D. Security and publication hygiene

- [ ] No Grafana passwords, Nomad tokens, personal `.env` or credentials in committed files.
- [ ] Review captured JSON/logs/screenshots for internal addresses, usernames and sensitive application content before public upload.
- [ ] Do not publish `/etc/nomad.d/nomad.hcl` unreviewed.
- [ ] Keep local TSDB databases and raw service volumes out of Git.
- [ ] Avoid committing giant or changing binary evidence files without repository size considerations.
- [ ] Add/review `.gitignore` rules before sharing to public GitHub.

## E. Known untested items (record as NOT TESTED)

- [ ] Intentional process/host restart and recovery.
- [ ] Grafana/Prometheus/Loki backup-and-restore validation.
- [ ] Multi-node failover and high availability.
- [ ] Full application/system log coverage.
- [ ] Retention expiry after seven days and storage pressure over time.
- [ ] Production Nomad mTLS, ACLs and security audit.
- [ ] Alert rules and notification delivery.

Unchecked items in this section are **future scope**, not blockers for a local lab documentation handover. They must not be misrepresented as completed tests.

## F. Read-only final validation commands

```bash
cd ~/projects/nomad-monitoring
find docs reports/phase6 -maxdepth 2 -type f | sort
ls -lh README.md docs/*.md reports/phase6/*.md
nomad job status
curl -fsS http://127.0.0.1:3000/api/health
```

## Final sign-off statement (after local integration)

> The local Nomad-based monitoring stack is deployed and was verified for functional Prometheus metrics, demo-application log ingestion via Alloy/Loki, Grafana dashboard display, persistent host-volume mappings, and non-disruptive health/resource checks. Documentation is complete for the lab scope; destructive recovery testing and production hardening remain out of scope.

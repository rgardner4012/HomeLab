# Disaster Recovery

## Backup Checklist (To-Do)

- [ ] etcd snapshots configured (RKE2 built-in)
- [ ] Longhorn backup target configured (NAS NFS share)
- [ ] Longhorn recurring snapshots scheduled
- [X] Age private key backed up offline
- [ ] CNPG backup target configured (NAS NFS share or object storage)
- [ ] CNPG scheduled backups enabled for ff-postgres (production)
- [ ] NAS app config directories backed up
- [ ] Find per app solution for NAS backed apps
  - [ ] Sonarr
  - [ ] Radarr
  - [ ] Profilarr
  - [ ] JellySeer
  - [ ] Prowlarr
  - [ ] NZBGet
  - [ ] Portainer
  - [ ] Plex
  - [ ] Rancher
- [ ] Backup restore tested

## RTO/RPO Targets

| Component | RPO | RTO | Notes |
| ----------- | ----- | ----- | ------- |
| K8s manifests | 0 (in Git) | ~30 min | Flux reconciles from Git |
| MetalLB | 0 (in Git) | ~5 min | Flux deploys Helm chart then config via depends on |
| Docker Compose stacks | 0 (in Git) | ~15 min | SSH deploy from Git |
| Longhorn volumes | Last snapshot | ~1 hr | Restore from Longhorn backup target (NFS Share) |
| OpenBao data | Last Raft snapshot | ~1 hr | Requires restore + unseal |
| Prometheus/Grafana data | Last Longhorn snapshot | ~1 hr | Dashboards are in Git (ConfigMaps) |
| ff-postgres (production) | Last CNPG backup | ~30 min | 3-replica HA; restore from CNPG backup target |
| ff-postgres (dev) | N/A | ~5 min | Single instance, dev data is disposable — recreate from scratch |
| Media library | N/A | N/A | Not backed up (re-downloadable, want to find a way to track what currently exists, will *arr config backups work here?) |
| App configs (Sonarr, Radarr, etc.) | Last NAS backup | ~30 min | Restore config dirs, redeploy |
| SOPS encryption key (age) | Offline backup and external Password Manager | Manual | Required to decrypt all secrets |

## RKE2 Cluster Recovery

### Total cluster loss

1. Re-provision NUCs via Elemental Operator (Rancher).
2. `flux bootstrap github` to reinstall Flux.
3. Flux reconciles all manifests from Git automatically.
4. MetalLB installs via Helm chart, then IP pool config applies once CRDs are ready.
5. Longhorn volumes are recreated empty — restore from backup target if needed.
6. LoadBalancer services get external IPs once MetalLB is healthy.

### Single node failure

RKE2 reschedules pods to remaining nodes automatically. Longhorn rebuilds volume replicas on healthy nodes (default 3 replicas).

### Longhorn volume recovery

1. If a replica is lost, Longhorn automatically rebuilds from the remaining replica(s)
2. For full volume loss, restore from Longhorn backup target (NAS NFS share)
3. Verify PVCs are bound and workloads are healthy

### MetalLB recovery

MetalLB is fully managed by Flux via the chart/config split pattern (see [ADR-006](adr.md)). On a fresh cluster:

1. `infra-metallb` Flux Kustomization installs the namespace, HelmRepository, and HelmRelease
2. Helm installs MetalLB and registers its CRDs — `wait: true` holds until pods are healthy
3. `infra-metallb-config` Flux Kustomization applies IPAddressPool and L2Advertisement
4. LoadBalancer services pick up external IPs from the 192.168.0.240-250 range

No manual intervention required.

### ff-postgres (CloudNativePG) recovery

ff-postgres is managed by the CloudNativePG operator, reconciled by Flux via the `infra-ff-postgres` Kustomization.

**Production** runs 3 replicas (1 primary, 2 standbys). On single-node failure, CNPG promotes a standby automatically — no data loss, no manual intervention.

**On total cluster loss:**

Flux bootstrap command:
  flux bootstrap github \
    --owner=rgardner4012 \
    --repository=HomeLab \
    --branch=main \
    --path=./clusters/hlcl1 \
    --components-extra=image-reflector-controller,image-automation-controller

1. Flux reconciles `infra-shared-namespaces` → creates `ff-dev` and `ff-production` namespaces
2. Flux reconciles `infra-cloudnativepg` → installs CNPG operator (`wait: true`)
3. Flux reconciles `infra-ff-postgres` → creates `Cluster` resources
4. CNPG restores from backup target (once backup is configured — see checklist above)
5. `ff-postgres-app` Secret is recreated by CNPG and available to the ff app

**Dev** instance (single replica) is treated as disposable — recreate from scratch, run migrations.

### PiHole recovery

1. One instance runs on k8s. If it dies, it should migrate to another node. If the entire cluster is down, we still have a second instance running on
the NAS. If both are down, we've lost the network.
2. Configs need to be backed up to NAS and synced

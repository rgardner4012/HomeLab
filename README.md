# 🏠 Homelab GitOps

A hybrid homelab managed entirely through GitOps — Docker Compose stacks on a NAS for media workloads, and a 3-node RKE2 Kubernetes cluster for platform services.

## Hardware

| Device | Role | CPU | RAM | Storage | OS |
| -------- | ------ | ----- | ----- | --------- | ---- |
| UGREEN DXP6800 Pro | NAS + Docker host | Intel i5-1235U | 40Gb | 36TB | UGOS |
| Intel NUC #1 | RKE2 worker | Intel Core i5-8259U | 32Gb | 500Gb | Elemental OS |
| Intel NUC #2 | RKE2 worker | Intel Core i7-8559U | 32Gb | 250Gb | Elemental OS |
| Intel NUC #3 | RKE2 worker | Intel Core i7-8559U | 32Gb | 250Gb | Elemental OS |

## Repository Structure

```text
homelab/
├── .github/workflows/         # CI/CD — linting, Flux diff, NAS deploy
├── docs/                      # Architecture decisions, runbooks
│   ├── adr.md                 # Architecture Decision Records
│   ├── bootstrap.md           # Cluster bootstrap procedure
│   ├── naming-and-ips.md      # Hostnames, VLANs, IP allocations
│   └── disaster-recovery.md   # Backup strategy, restore procedures
│
├── docker/                    # NAS Docker Compose stacks (deployed via nas-deploy workflow)
│   ├── ansible/               # Ansible playbook and inventory for stack bring-up
│   ├── openbao/               # Example stack
│   │   ├── docker-compose.yaml
│   │   ├── .env.sops          # SOPS-encrypted env vars (decrypted at deploy time)
│   │   └── config/            # Optional: stack config files
│   │       └── openbao.hcl    #   synced to /volume3/docker_config/<stack>/
│   └── <stack>/               # Compose + env sync to /volume3/docker_compose/<stack>/
│
└── clusters/
    └── hlcl1/                 # RKE2 cluster (Flux CD managed)
        ├── flux-system/       # Flux bootstrap
        ├── kustomization.yaml # Cluster entrypoint
        ├── vars/              # Cluster-specific values (IPs, domains)
        │   └── cluster-config.yaml
        ├── infra/             # Foundational platform components
        │   ├── network/
        │   │   └── metallb/
        │   │       ├── ks-chart.yaml   # Flux Kustomization: Helm chart
        │   │       ├── ks-config.yaml  # Flux Kustomization: IP pool config (dependsOn chart)
        │   │       ├── chart/          # Namespace, HelmRepository, HelmRelease
        │   │       └── config/         # IPAddressPool, L2Advertisement
        │   ├── storage/
        │   │   ├── longhorn/
        │   │   └── nfs/
        │   ├── traefik/
        │   ├── cert-manager/
        │   └── external-dns/
        └── apps/              # Cluster applications
            ├── pihole/
            └── monitoring/
```

## Why Hybrid?

Media workloads (Plex, Sonarr, Radarr, DL) stay on the NAS as Docker Compose stacks because they need local filesystem access for **hardlinks** (no storage duplication), **QuickSync hardware transcoding**, and direct disk I/O. Kubernetes adds complexity without benefit here.

Platform services (DNS, monitoring, ingress, secrets management) run on the RKE2 cluster where they benefit from orchestration, self-healing, and LoadBalancer IPs.

See [ADR-005](docs/adr.md) for the full rationale.

## Getting Started

See <!-- [docs/setup-guide.md](docs/setup-guide.md) --> setup-guide.md, for the full bootstrap procedure. (TODO: Add setup-guide.md)

## Docs

- [Architecture](docs/adr.md) — service map, data flows, storage topology
- <!-- [Hardware](docs/hardware.md) — specs, network layout --> TODO: Write setupguide.md
- [Networking](docs/naming-and-ips.md) — VLANs, DNS, IP allocations
- [Disaster Recovery](docs/disaster-recovery.md) — backup strategy, restore procedures

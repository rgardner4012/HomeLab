# Naming & IP Allocations

## Network

| Property | Value |
| -------- | ----- |
| Subnet | 192.168.0.0/24 |
| Gateway | 192.168.0.1 |
| Domain | homelab |
| VLANs | None (flat network) |
| DNS | Pi-hole (primary: 192.168.0.245, secondary: 192.168.0.234) |

## Static IPs

### Infrastructure

| Hostname | IP | Role | Notes |
| -------- | -- | ---- | ----- |
| nas.homelab | 192.168.0.233 | UGREEN DXP6800 Pro — TrueNAS SCALE + Docker host | Media stacks, NFS, Pi-hole secondary; 5x20TB RAIDZ2 data pool, 2x SSD mirrored boot pool |
| nasbridge0.homelab | 192.168.0.235 | NAS bridge interface | Docker bridge network |
| nuc1.homelab | 192.168.0.50 | RKE2 worker (i5-8259U, 32GB) | |
| nuc2.homelab | 192.168.0.51 | RKE2 worker (i7-8559U, 32GB) | |
| nuc3.homelab | 192.168.0.52 | RKE2 worker (i7-8559U, 32GB) | |
| rancher.homelab | 192.168.0.48 | Rancher management UI | |
| nagios.homelab | 192.168.0.190 | Nagios monitoring | |

### Lab Compute

Skills-prep tier, not GitOps-managed and expected to be temporary. See [ADR-011](adr.md).

| Hostname | IP | Role | Notes |
| -------- | -- | ---- | ----- |
| idrac.homelab | 192.168.0.120 | R620 out-of-band management | Dell iDRAC |
| r620.homelab | 192.168.0.38 | Nutanix CE AHV host (2x Xeon, 128GB) | Bare metal, keep powered off when idle |
| cvm.homelab | 192.168.0.39 | Nutanix CVM | Controller VM on the R620 |
| pve.homelab | 192.168.0.45 | Proxmox VE host (XPS 15 9510, 32GB, 1TB SSD) | Hosts AAP + TFE agent VMs |
| aap.homelab | 192.168.0.178 | Ansible Automation Platform VM | On `pve.homelab` |
| tfagent.homelab | TBD | Terraform Enterprise agent VM | On `pve.homelab`; IP to assign |

### Services

| Hostname | IP | Platform | Notes |
| -------- | -- | -------- | ----- |
| pihole.homelab | 192.168.0.234 | NAS (Docker) | Primary DNS |
| pihole2.homelab | 192.168.0.245 | K8s (MetalLB) | Secondary DNS, IP from MetalLB pool |

## MetalLB Address Pool

| Pool | Range | Mode |
| ---- | ----- | ---- |
| homelab-pool | 192.168.0.240–192.168.0.250 | L2 |

11 addresses available. Currently assigned: pihole2 (.245).

## IP Range Conventions

### This is dirty currently do to my previously existing homenetwork dhcp range (1-240)

| Range | Purpose |
| ----- | ------- |
| .1 | Gateway |
| .38–.39, .45, .120, .178 | Lab compute (R620/Nutanix, Proxmox, iDRAC, AAP) — scattered, see Lab Compute table |
| .48–.52 | K8s / Rancher infrastructure |
| .190 | Monitoring (Nagios) |
| .233–.235 | NAS + NAS services |
| .240–.250 | MetalLB pool (K8s LoadBalancer IPs) |

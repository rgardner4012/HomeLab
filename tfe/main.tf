# ---------------------------------------------------------------------------
# v3-API resources (works on AOS 6.8.1 / your PC version; v4 / *_v2 resources
# require AOS 7.0 + pc.2024.3 which this cluster doesn't run).
# Provider talks to Prism Central. Credentials come from NUTANIX_* env vars
# set as sensitive workspace variables.
# ---------------------------------------------------------------------------

# Discover the cluster by name. On v3 the data source returns .id (= cluster UUID).
data "nutanix_clusters" "clusters" {}

locals {
  # Build a name->uuid map of clusters registered to PC, then pick ours by name.
  # On single-node CE there's one PE cluster; var.cluster_name must match what
  # PE/PC shows (you named it "cluster1").
  cluster_uuid = one([
    for c in data.nutanix_clusters.clusters.entities : c.metadata.uuid
    if c.name == var.cluster_name
  ])
}

# Look up the subnet by name -> returns .id (subnet UUID).
data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

resource "nutanix_virtual_machine" "lab" {
  name                 = var.vm_name
  description          = "TF lab smoke-test VM (Pattern B, v3 API)"
  cluster_uuid         = local.cluster_uuid
  num_sockets          = 1
  num_vcpus_per_socket = 1
  memory_size_mib      = var.memory_mib # MiB in v3 — no float/whole-number bug

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  # Empty boot disk (no image yet). Goal of this phase: prove HCP -> agent ->
  # Prism Central creates a VM. Image + cloud-init come next iteration.
  disk_list {
    disk_size_mib = var.disk_mib
    device_properties {
      device_type = "DISK"
      disk_address = {
        adapter_type = "SCSI"
        device_index = 0
      }
    }
  }
}

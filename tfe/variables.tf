variable "vm_name" {
  type    = string
  default = "tf-lab-smoke-01"
}

variable "cluster_name" {
  type        = string
  description = "PE cluster name as shown in Prism (you named it cluster1)."
  default     = "cluster1"
}

variable "subnet_name" {
  type        = string
  description = "Name of the AHV subnet/network to attach the NIC to."
  # No default — set in terraform.tfvars or a workspace variable.
}

variable "memory_mib" {
  type        = number
  description = "VM memory in MiB."
  default     = 2048 # 2 GiB
}

variable "disk_mib" {
  type        = number
  description = "Boot disk size in MiB."
  default     = 20480 # 20 GiB
}

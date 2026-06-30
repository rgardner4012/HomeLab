output "vm_uuid" {
  description = "The created VM's UUID."
  value       = nutanix_virtual_machine.lab.id
}

output "vm_name" {
  value = nutanix_virtual_machine.lab.name
}

# v3 surfaces the learned IP under nic_list_status. Empty until the guest boots
# with an OS that gets an address — wired now for the Phase 4 AAP hand-off.
output "vm_ip_address" {
  description = "Assigned IPv4 address, once the guest has booted with an OS."
  value = try(
    nutanix_virtual_machine.lab.nic_list_status[0].ip_endpoint_list[0].ip,
    ""
  )
}

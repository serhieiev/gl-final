# GCP Outputs
output "gcp_ip" {
  description = "The public IP address of the GCP virtual machine"
  value       = module.gcp.ip
}

output "gcp_ssh_connection_string" {
  description = "The SSH command to connect to the GCP virtual machine"
  value       = module.gcp.ssh_connection_string
}
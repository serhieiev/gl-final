# GCP Project Specific Variables
variable "gcp_project" {
  description = "The GCP Project ID to deploy the VM"
}

variable "gcp_region" {
  description = "The GCP Region to deploy the VM"
}

variable "gcp_zone" {
  description = "The GCP Zone to deploy the VM"
}

variable "gcp_key_file" {
  description = "The path to the GCP Service Account"
}

# VM Instance Specific Variables
variable "vm_type" {
  description = "The VM instance type to create"
  type        = string
}

variable "disk_image" {
  description = "The disk image to use for the VM boot disk"
  type        = string
}

variable "disk_size" {
  description = "The size of the VM boot disk in GB"
  type        = number
}

# Common Variables
variable "ssh_user" {
  description = "The local user account to create on the virtual machine"
  type        = string
}

variable "ssh_pub_key_file" {
  description = "The path to the public SSH key associated with the local user account"
  type        = string
}

variable "ssh_priv_key_file" {
  description = "The path to the private SSH key associated with the local user account"
  type        = string
}

# Cloud SQL Instance Specific Variables
variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
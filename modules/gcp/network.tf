resource "google_compute_network" "gl-vpc" {
  name                    = "gl-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "true"
}


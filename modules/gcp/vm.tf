resource "google_compute_instance" "vm_instance" {
  name         = "k8s-gcp"
  machine_type = var.vm_type

  tags = ["ssh-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20230213"
      size  = 50
    }
  }

  network_interface {
    network = google_compute_network.gl-vpc.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}

resource "google_compute_firewall" "ssh-server" {
  name    = "default-allow-ssh-terraform"
  network = google_compute_network.gl-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  // Allow SHH traffic from host machine to instances with an ssh tag
  source_ranges = ["${chomp(data.http.myip.response_body)}/32"]
  target_tags   = ["ssh-server"]
}

resource "google_compute_firewall" "rules" {
  name    = "default-allow-http-terraform"
  network = google_compute_network.gl-vpc.name

  allow {
    protocol  = "tcp"
    ports     = ["80", "443", "3306", "8080", "8443"]
  }

  // Allow traffic to the listed ports from everywhere to instances with a web tag
  source_ranges = ["0.0.0.0/0"]
}

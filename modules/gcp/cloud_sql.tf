resource "google_compute_network" "private_network" {
  name = "db-private-network"
}

resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  description  = "A block of private IP addresses that are accessible only from within the VPC."
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  # We don't specify a address range because Google will automatically assign one for us.
  prefix_length = 24 # 256 IPs
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

# Create a Cloud SQL instance
resource "google_sql_database_instance" "mysqldb" {
  
  name             = "mysql"
  database_version = "MYSQL_5_7"
  region           = var.gcp_region

  depends_on       = [google_service_networking_connection.private_vpc_connection]

  # Configure the database settings
  settings {
    tier = "db-n1-standard-1"

    # Configure the backup settings
    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false        # don't give the db a public IPv4
      private_network = google_compute_network.private_network.id # the VPC where the db will be assigned a private IP
    }

    # Configure the database flags
    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
  }
  deletion_protection = false
}

resource "google_sql_database" "database" {
  name      = "wpdb"
  instance  = google_sql_database_instance.mysqldb.name
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "users" {
  name     = var.db_username
  instance = google_sql_database_instance.mysqldb.name
  host     = "%"
  password = var.db_password
}
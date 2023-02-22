module "gcp" {
  gcp_project       = var.gcp_project
  gcp_region        = var.gcp_region
  gcp_zone          = var.gcp_zone
  vm_type           = var.vm_type
  disk_image        = var.disk_image
  disk_size         = var.disk_size
  gcp_key_file      = var.gcp_key_file
  ssh_user          = var.ssh_user
  ssh_pub_key_file  = var.ssh_pub_key_file
  ssh_priv_key_file = var.ssh_priv_key_file
  db_username       = var.db_username
  db_password       = var.db_password
  source            = "./modules/gcp"
}

resource "null_resource" "vm_instance" {
  depends_on = [module.gcp]
  provisioner "local-exec" {
    command = <<EOT
      exit_test () {
        RED='\033[0;31m' # Red Text
        GREEN='\033[0;32m' # Green Text
        BLUE='\033[0;34m' # Blue Text
        NC='\033[0m' # No Color
        if [ $? -eq 0 ]; then
          printf "\n $GREEN Playbook Succeeded $NC \n"
        else
          printf "\n $RED Failed Playbook $NC \n" >&2
          exit 1
        fi
      }
      ansible-playbook  -i ${module.gcp.ip}, --become --user=serhieiev --become-user=root harden.yaml; exit_test 
    EOT
  }
}
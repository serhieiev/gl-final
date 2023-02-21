# GL: Final Task

## Task

Terraform:	
- create VPC in GCP/Azure						
- create instance with External IP						
- prepare managed DB (MySQL)						
							
Ansible:	
- perform basic hardening (keyless-only ssh, unattended upgrade, firewall)						
- (optional) perform hardening to reach CIS-CAT score at least 80 (please find https://learn.cisecurity.org/cis-cat-lite)						
- deploy k8s (single-node cluster via Kubespray)						
							
Kubernetes:	
- prepare ansible-playbook for deploying Wordpress						
- deploy WordPress with connection to DataBase

## Solution
### Terraform
The assignment is being done on Google Cloud Platform (GCP).

The `gcp` Terraform module describes all the infrustructure needed for the project:
- Networking
- Firewall rules
- VM instance
- Cloud SQL managed MySQL database

And also assumes that you have created a GCP project and Service Account as described in the documentation:
https://cloud.google.com/resource-manager/docs/creating-managing-projects
https://cloud.google.com/iam/docs/creating-managing-service-accounts

The following software has been installed on the host machine:
- Google Cloud SDK >= 412.0.0
- Terraform >= v1.3.6
- Ansible >= core 2.12.5

Ensure that you have an identical list of enabled services on Google Cloud Platform (GCP):
```
gcloud services list --enabled --project gl-tf-server
                                                            1 ↵ 
NAME                                 TITLE
bigquery.googleapis.com              BigQuery API
bigquerymigration.googleapis.com     BigQuery Migration API
bigquerystorage.googleapis.com       BigQuery Storage API
cloudapis.googleapis.com             Google Cloud APIs
cloudbilling.googleapis.com          Cloud Billing API
clouddebugger.googleapis.com         Cloud Debugger API
cloudresourcemanager.googleapis.com  Cloud Resource Manager API
cloudtrace.googleapis.com            Cloud Trace API
compute.googleapis.com               Compute Engine API
datastore.googleapis.com             Cloud Datastore API
iam.googleapis.com                   Identity and Access Management (IAM) API
iamcredentials.googleapis.com        IAM Service Account Credentials API
logging.googleapis.com               Cloud Logging API
monitoring.googleapis.com            Cloud Monitoring API
oslogin.googleapis.com               Cloud OS Login API
secretmanager.googleapis.com         Secret Manager API
servicemanagement.googleapis.com     Service Management API
servicenetworking.googleapis.com     Service Networking API
serviceusage.googleapis.com          Service Usage API
sql-component.googleapis.com         Cloud SQL
sqladmin.googleapis.com              sqladmin API (prod)
storage-api.googleapis.com           Google Cloud Storage JSON API
storage-component.googleapis.com     Cloud Storage
storage.googleapis.com               Cloud Storage API
```

Clone project repo to your host machine:
```
git clone https://github.com/serhieiev/gl-final.git 
cd gl-final
```

To deploy `gcp` module, copy the `terraform.tfvars.example` using the following command:
```
cp terraform.tfvars.example terraform.tfvars
```

Next, adjust the `terraform.tfvars` file to reflect your specific configuration.

To deploy the infrustructure, run the following commands in the repository root directory:

Initialize a working directory containing Terraform configuration files:
```
terraform init
```

Create an execution plan:
```
terraform plan -out gl-final
```

Execute the actions proposed in a Terraform plan
```
terraform apply "gl-final"
```

## Ansible

## deploy k8s (single-node cluster via kubespray)

Clone kubespray release repository to your host machine:
```
git clone https://github.com/kubernetes-sigs/kubespray.git 
cd kubespray
git checkout release-2.20
```
Install kubespray Python dependencies:
```
sudo pip3 install -r requirements.txt
```

Copy and edit `inventory.ini` file 
```
cp -rfp inventory/sample inventory/mycluster
```
```
nano inventory/mycluster/inventory.ini
```
```
[all]
node1 ansible_host=VM_PUBLIC_IP
[kube_control_plane] node1
[etcd] node1
[kube_node] node1
[calico_rr]
[k8s_cluster:children] kube_control_plane kube_node
calico_rr
```
Turn on MetalLB:
```
nano inventory\mycluster\group_vars\k8s_cluster\addons.yml 
```
```
...
metallb_enabled: true
metallb_speaker_enabled: true
metallb_avoid_buggy_ips: true metallb_ip_range:
- "VM_PRIVATE_IP/24"
...
```
Configure strict ARP:
```
nano inventory\mycluster\group_vars\k8s_cluster\k8s-cluster.yml
```
```
...
kube_proxy_strict_arp: true
...

```
Run the kubespray playbook after adjusting `--user` and `--key-file` to reflect your specific configuration:
```
ansible-playbook -i inventory/mycluster/inventory.ini --become --user=serhieiev --become-user=root cluster.yml --key-file "~/.ssh/gcp_key"
```



## Kubernetes

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  storageClassName: do-block-storage
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/var/lib/mysql"
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: do-block-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-pv
spec:
  storageClassName: do-block-storage
  capacity: 
    storage: 15Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/var/www"
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-pv-claim
spec:
  storageClassName: do-block-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 15Gi
EOF
```



## Demo

![WordPress_installation](https://user-images.githubusercontent.com/12089303/220213484-cf8b7018-4f61-4242-8f7a-f23c6b3ad416.png)


![Hello_GL_DevOps_Basecamp](https://user-images.githubusercontent.com/12089303/220213493-e18e9d01-ece2-4623-8428-0bb0fae59e40.png)



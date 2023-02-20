# GL: Final Task

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



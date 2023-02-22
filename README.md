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

Check the complete output of the execution [tf_apply.txt](https://github.com/serhieiev/gl-final/blob/main/outputs/tf_apply.txt)

Example of successful execution visible on screnshot below:
![tf_apply_output](https://user-images.githubusercontent.com/12089303/220590316-655fc87f-2ea9-4759-80a3-148b8e7c084c.png)

## Ansible

### perform basic hardening (keyless-only ssh, unattended upgrade, firewall)	

The hardening of an Ubuntu 20.04 system is described in the `hardening` role and executed during a `terraform apply` operation using the `null_resource` and `local-exec` provisioners.

Check the complete output of the execution [tf_apply.txt](https://github.com/serhieiev/gl-final/blob/main/outputs/tf_apply.txt)

### deploy k8s (single-node cluster via kubespray)

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

Check the complete output of the execution [kubespray.txt](https://github.com/serhieiev/gl-final/blob/main/outputs/kubespray.txt)

## Kubernetes

The routine tasks such as creating a `kube` directory, installing Helm, and adding Helm repositories are described in the `hardening` role.

Check the complete output of the execution [helm_install.txt](https://github.com/serhieiev/gl-final/blob/main/outputs/helm_install.txt)

After that, we can proceed with setting up MYSQL and WordPress in our k8s environment:

Apply a `PersistentVolume` for the MySQL database:
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
Then, apply a `PersistentVolumeClaim`for the MySQL database:
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
Apply a `PersistentVolume` for the WordPress:
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
Then, apply a `PersistentVolumeClaim`for the WordPress:
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
Using any text editor of your choice, create a `kustomization.yaml` file and fill in a password of your preference, ensuring it has high security:
```
secretGenerator:
- name: mysql-password
  literals:
  - password=MYSQL_PASSWORD
- name: mysql-user
  literals:
  - username=MYSQL_USER
- name: mysql-user-password
  literals:
  - passworduser=MYSQL_USER_PASSWORD
- name: mysql-database
  literals:
  - database=MYSQL_DATABASE
```
After that execute:
```
kubectl apply -k .
```
Apply MySQL service with the secret we have created before:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: 
  name: mysql-wp
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-wp
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:latest
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: MYSQL_PASSWORD
              key: password
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: MYSQL_USER
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: USER
              key: passworduser
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: USER_PASSWORD
              key: database
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: web
  type: LoadBalancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: web
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: web
    spec:
      containers:
      - image: wordpress:php8.1-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-wp:3306
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-password-9m7k5b4k2m
              key: passworduser
        - name: WORDPRESS_DB_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-4t5mcf8dkm
              key: username
        - name: WORDPRESS_DB_NAME
          valueFrom:
            secretKeyRef:
              name: mysql-database-4f74mgddt5
              key: database
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: wordpress-pv-claim
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: web
  type: LoadBalancer

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: web
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: web
    spec:
      containers:
      - image: wordpress:php8.1-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-wp:3306
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: MYSQL_USER_PASSWORD
              key: passworduser
        - name: WORDPRESS_DB_USER
          valueFrom:
            secretKeyRef:
              name: MYSQL_USER
              key: username
        - name: WORDPRESS_DB_NAME
          valueFrom:
            secretKeyRef:
              name: MYSQL_DATABASE
              key: database
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: wordpress-pv-claim
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: 
  name: wp-prod-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: youremail@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
EOF
```

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "wp-prod-issuer"
spec:
  rules:
  - host: serhieiev.site
    http:
     paths:
     - path: "/"
       pathType: Prefix
       backend:
         service:
           name: wordpress
           port:
             number: 80
  tls:
  - hosts:
    - serhieiev.site
    secretName: wordpress-tls
EOF
```

Make sure that k8s resources are intact:

![kubectl_verify_deployment](https://user-images.githubusercontent.com/12089303/220590138-fbf46eb8-2156-4699-9c95-421c23da4f66.png)


## Demo

The WordPress site is reachable via a URL and can be set up using a wizard.
![WordPress_installation](https://user-images.githubusercontent.com/12089303/220213484-cf8b7018-4f61-4242-8f7a-f23c6b3ad416.png)

Once setup is complete, enjoy the power of WordPress running in k8s that spinned up on 100:money_with_wings: GCP VM instance :smile:

![Hello_GL_DevOps_Basecamp](https://user-images.githubusercontent.com/12089303/220213493-e18e9d01-ece2-4623-8428-0bb0fae59e40.png)



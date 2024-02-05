# Terraform Disaster Recovery Automation

## Overview

To address potential issues arising from regional outages or database corruption, a disaster recovery solution has been implemented using Terraform. In this setup, a new VM instance is created, and a Bash script is employed to execute essential Terraform commands. This approach ensures the seamless promotion of a read-replica instance to the primary instance within Google Cloud Platform (GCP), resolving any state file conflicts that may occur during the process

### 1. Startup Script

The startup script (`script.sh`) performs the following tasks:

```bash
#!/bin/bash

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform -y
sudo apt-get install git -y
git clone https://oauth2:<personal_access_token>@gitlab.com/gcp2554514/cloudsql.git
cd cloudsql/root-test/root
export GOOGLE_APPLICATION_CREDENTIALS=<vars.service_account>
terraform init -reconfigure
read_replica=$(terraform output replica_instance_name)
export read_replica=$(echo $read_replica | tr -d '"'| tr -d '[]' | tr -d ',' | tr -d ' ')
replica_region=$(terraform output replica_region)
replica_region=$(echo $replica_region | tr -d '"'| tr -d '[]' | tr -d ',')
master_region=$(terraform output master_region)
terraform state rm module.cloudsql_postgres_sync_test.google_sql_database_instance.postgres_db_instance 
terraform state rm module.cloudsql_postgres_rr_test.google_sql_database_instance.replicas
terraform state rm module.cloudsql_postgres_sync_test.google_sql_database.additional_databases
terraform state rm module.cloudsql_postgres_rr_test.random_id.db_name_suffix_replica
terraform state list
terraform import "module.cloudsql_postgres_sync_test.google_sql_database_instance.postgres_db_instance" "projects/endless-fire-408913/instances/$read_replica" 
terraform import "module.cloudsql_postgres_sync_test.google_sql_database.additional_databases[0]" "projects/endless-fire-408913/instances/${read_replica}/databases/additional-database" 
```

### Setup Startup Script

You need to clone the existing GitLab repo, (which the read replica promoted as the primary.). 
However, you are using a private repository, so you will need to create a personal access token in your GitLab account in order to clone the repository without any conflicts. (permission read_repository)
![preview](image.png?raw=true "screen")

```bash
 git clone https://oauth2:${Personal Access Tokens}@gitlab.com/username/myrepo.git
```
A GCP service account key must be available and exported as `GOOGLE_APPLICATION_CREDENTIALS` for authentication.
Additionally, you need to change the resource names based on your module's resource names. `module.cloudsql_postgres_sync_test.google_sql_database_instance.postgres_db_instance` 

### Terraform Backend

This Terraform configuration uses Google Cloud Storage (GCS) as the backend to store the Terraform state file. Update the `backend "gcs"` block in the `main.tf` file with your specific GCS bucket information.


### 1. VM Creation

A preemptible VM is created with the specified machine type, zone, and other configurations. The startup script (`dot.sh`) is executed during VM creation.

```hcl
resource "google_compute_instance" "web" {
  # ... (VM configuration details)
  metadata_startup_script = file("./script.sh")
}
```



### 3. Terraform Backend Configuration

The `backend "gcs"` block in `main.tf` specifies the GCS bucket to store the Terraform state file.

```hcl
backend "gcs" {
  bucket      = "mystatefilehere" # Replace with your GCS bucket name
  prefix      = "tfdefault/"
}
```

### 4. Provider Configuration

The `provider "google"` block in `main.tf` configures the Google Cloud provider with the necessary project, region, and service account details.

```hcl
provider "google" {
  project     = "endless-fire-408913"
  region      = "us-central1"
}
```

### 5. Disaster Recovery Steps

The `startup_script` triggers Terraform commands to address state file conflicts and promote the read-replica instance.

- Reads outputs from Terraform to get replica instance details.
- Removes unwanted resources from Terraform state.
- Imports necessary resources to Terraform state.

## Conclusion

This Terraform setup provides an automated solution for disaster recovery, allowing for the promotion of read-replica instances in the event of a regional outage or database corruption. Adjust configurations as needed for your specific environment.

---

Now, the documentation includes the startup script for clarity. Feel free to modify it further based on your specific details or add more sections as required.

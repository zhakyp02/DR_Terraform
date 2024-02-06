#!/bin/bash

# sudo apt-get update
# sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
# echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# sudo apt-get update && sudo apt-get install google-cloud-cli -y
# RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform -y
sudo apt-get install git -y
git clone https://oauth2:glpat-r7hZQxv4i_L1P4itCccx@gitlab.com/gcp2554514/cloudsql.git
cd cloudsql/root-test/root
sudo apt-get install jq -y
cat <<EOF > cred.json
${google_creds}
EOF
export GOOGLE_APPLICATION_CREDENTIALS=cred.json
terraform init -reconfigure
export read_replica=$(terraform output replica_instance_name)
export read_replica=$(echo $read_replica | tr -d '"'| tr -d '[]' | tr -d ',' | tr -d ' ')
export replica_region=$(terraform output replica_region)
export replica_region=$(echo $replica_region | tr -d '"'| tr -d '[]' | tr -d ',')
export master_region=$(terraform output master_region)
terraform state rm module.cloudsql_postgres_sync_test.google_sql_database_instance.postgres_db_instance 
terraform state rm module.cloudsql_postgres_rr_test.google_sql_database_instance.replicas
terraform state rm module.cloudsql_postgres_sync_test.google_sql_database.additional_databases
terraform state rm module.cloudsql_postgres_rr_test.random_id.db_name_suffix_replica
terraform state list
terraform import "module.cloudsql_postgres_sync_test.google_sql_database_instance.postgres_db_instance" "projects/endless-fire-408913/instances/$read_replica" 
terraform import "module.cloudsql_postgres_sync_test.google_sql_database.additional_databases[0]" "projects/endless-fire-408913/instances/$read_replica/databases/additional-database" 

# REQUIRED ENVIRONMENT VARIABLES
# GCS_BUCKET : The name of the GCS bucket to download the password from and upload the backup to
# KMS_PROJECT : The project containing the KMS keyring to use for decryption
# KMS_KEYRING : The name of the KMS keying to use for decryption
# KMS_KEY : The name of the KMS key to use for decryption
# KMS_LOCATION : The location of the KMS keyring to use for decryption

# Set variables
GCS_BUCKET="jenkins-backup"
KMS_PROJECT="proj-name"
KMS_KEYRING="proj-name-keyring"
KMS_KEY="jenkins-backup-key"
KMS_LOCATION="europe-west2"

# Get the password from GCS
gsutil cp gs://$GCS_BUCKET/password /tmp/jenkins-password

# Decrypt the password using GCS
password=$(gcloud --project=$KMS_PROJECT kms decrypt --ciphertext-file=/tmp/jenkins-password --plaintext-file=- --keyring=$KMS_KEYRING --key=$KMS_KEY --location=$KMS_LOCATION)

# Tar and encrypt the Jenkins directory
tar -zcvf /tmp/jenkins-config.tar.gz.tmp -C /var/lib/jenkins .
openssl enc -aes256 -in /tmp/jenkins-config.tar.gz.tmp -out /tmp/jenkins-config.tar.gz -k "$password"

# Copy the Jenkins directory to GCS
gsutil cp /tmp/jenkins-config.tar.gz gs://$GCS_BUCKET

# Clean up
rm -rf /tmp/jenkins*
# REQUIRED ENVIRONMENT VARIABLES
# GCS_BUCKET : The name of the GCS bucket to download the password and backup from
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

# Copy the Jenkins directory from GCS
gsutil cp gs://$GCS_BUCKET/jenkins-config.tar.gz /tmp

# Decrypt and untar the Jenkins directory
openssl enc -d -aes256 -in /tmp/jenkins-config.tar.gz -out /tmp/jenkins-config.tar.gz.tmp -k "$password"
mkdir -p /var/lib/jenkins
tar -zxvf /tmp/jenkins-config.tar.gz.tmp -C /var/lib/jenkins

# Clean up
rm -rf /tmp/jenkins*
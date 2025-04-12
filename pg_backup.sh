#!/bin/bash

# INSTALL AWS CLI
#
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# AWS CONFIGURATION
#
# aws configure --profile cloudflare
#   AWS Access Key ID [None]: <access_key_id>
#   AWS Secret Access Key [None]: <access_key_secret>
#   Default region name [None]: auto
#   Default output format [None]: json

# LOAD ENVIRONMENT VARIABLES (in case script is run by cron or non-login shell)
source ~/.bashrc

# CONFIGURATION
declare -A DB1=( ["container"]="db_container_1" ["user"]="db_user_1" ["db"]="db_name_1" )

# Add more databases / containers
# declare -A DB2=( ["container"]="db_container_2" ["user"]="db_user_2" ["db"]="db_name_2" )
# declare -A DB3=( ["container"]="db_container_3" ["user"]="db_user_3" ["db"]="db_name_3" )

DATABASES=(DB1) # add more DB2 DB3 etc

# BACKUP SETTINGS
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
BACKUP_DIR="/tmp/pg_backups" # directory to store backups
R2_BUCKET="<bucket_name>"
# this is the cloudflare R2 endpoint, can be .eu.r2.cloudflarestorage.com
R2_ENDPOINT="https://<account_id>.r2.cloudflarestorage.com"

mkdir -p "$BACKUP_DIR"

# AWS CLI PROFILE
AWS_PROFILE="cloudflare" # aws cli profile you have created

# LOOP THROUGH DATABASE CONFIGS
for DB_KEY in "${DATABASES[@]}"; do
  declare -n DB="$DB_KEY"
  CONTAINER="${DB["container"]}"
  USER="${DB["user"]}"
  DB_NAME="${DB["db"]}"

  BACKUP_FILE="${DB_NAME}_${TIMESTAMP}.sql.gz"

  echo "Backing up ${DB_NAME} from container ${CONTAINER}..."
  docker exec "$CONTAINER" pg_dump -U "$USER" "$DB_NAME" | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"

  echo "Uploading to R2..."
  aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}" "s3://${R2_BUCKET}/${CONTAINER}/${BACKUP_FILE}" --endpoint-url "$R2_ENDPOINT" --profile "$AWS_PROFILE" --checksum-algorithm=CRC32

  echo "Cleaning up..."
  rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
done

echo "Done!"

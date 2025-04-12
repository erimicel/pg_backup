# PostgreSQL Backup to Cloudflare R2

This script automates the process of backing up PostgreSQL databases running in Docker containers and uploading the backups to Cloudflare's R2 storage. The backups are compressed, timestamped, and stored in R2 buckets for easy retrieval.

# Prerequisites

Before running the script, ensure that you have the following prerequisites set up:
1. AWS CLI (v2): You need to have the AWS CLI (v2) installed on your machine. You can install it using the following commands:
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# install unzip if not exists in the system
```

2. AWS Configuration: Configure the AWS CLI with your Cloudflare R2 credentials:
```
aws configure --profile cloudflare # or different profile name
```
Enter your Cloudflare R2 Access Key ID, Secret Access Key, default region name (auto), and output format (json).

3. R2 Configuration: Add the R2 credentials and bucket name to your environment variables. Edit your ~/.bashrc and add the following for easy use:
```
export R2_BACKUP_ACCESS_KEY_ID=<access_key_id>
export R2_BACKUP_ACCESS_KEY_SECRET=<access_key_secret>
export R2_BACKUP_BUCKET_NAME=<bucket_name>
export R2_BACKUP_ACCOUNT_ID=<account_id>
```
After adding the configuration, load the environment variables:
```
source ~/.bashrc
```

4. Docker: Ensure that the PostgreSQL containers (db_container_1, db_container_2, etc.) are running and accessible. Update the database container details in the script as needed.

# How to Use

1. Ensure all the prerequisites are configured properly.
2. Make the script executable:
```
chmod +x pg_backup.sh
```

3. Run the script:
```
bash ./backup_script.sh
```

The script will loop through all the configured databases, back them up, compress the backups, and upload them to your Cloudflare R2 bucket.

## Ensure Cloudflare R2 Bucket CORS Settings Are Not Blocking
Make sure that the Cloudflare R2 bucket's CORS settings are configured properly to allow the uploads. If CORS is incorrectly set, the script might fail when uploading to the bucket.

# Automatic Backup with Cron
To set up the script to run automatically at scheduled intervals, you can use cron jobs.
1. Edit your crontab file:
```
crontab -e
```

2. Add a cron job similar to this:
```
0 * * * * /path/to/script/pg_backup.sh >> /var/log/pg_backup.log 2>&1
```
This cron job will run the backup script every hour, on the hour, and log both the output and error messages to /var/log/pg_backup.log.

3. If your cron service is not running, you may need to start it:
```
systemctl start cron
```

Make sure that cron is running by checking the status:
```
systemctl status cron
```

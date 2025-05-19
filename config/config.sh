#!/bin/bash
#
# Proxmox GFS Backup Configuration
#

# Backup Settings
BACKUP_DIR="/var/lib/vz/dump"
BACKUP_MODE="snapshot"
BACKUP_COMPRESS="zstd"
BACKUP_LEVEL="1"

# Retention Settings
DAILY_RETENTION=7      # Keep last 7 days
WEEKLY_RETENTION=4     # Keep last 4 weeks
MONTHLY_RETENTION=6    # Keep last 6 months

# Mail Settings
SMTP_SERVER="mail.gmx.net"
SMTP_PORT="587"
SMTP_USER="Laszczyk@gmx.de"
SMTP_PASS_FILE="/root/.backup_smtp_pass"
NOTIFICATION_EMAIL="Laszczyk@gmx.de"

# Advanced Settings
LOG_LEVEL="INFO"
DRY_RUN="1"           # Start with dry-run enabled
PARALLEL_JOBS="1"     # Start with single job for testing

# Load SMTP password from secure file
if [ -f "$SMTP_PASS_FILE" ]; then
    SMTP_PASS=$(cat "$SMTP_PASS_FILE")
else
    echo "Error: SMTP password file not found"
    exit 1
fi

# Import validation function
source /root/proxmox-gfs-backup/config/validate.sh

# Validate configuration
if ! validate_config; then
    echo "Configuration validation failed"
    exit 1
fi
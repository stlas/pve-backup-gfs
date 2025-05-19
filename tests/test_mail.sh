#!/bin/bash

set -e  # Exit on error

# Source the config
source /root/proxmox-gfs-backup/config/config.sh

# Verify config values
if [[ "$SMTP_SERVER" == *"example.com"* ]]; then
    echo "Error: SMTP server still set to example.com"
    exit 1
fi

# Debug: Show mail configuration (without password)
echo "Testing mail configuration:"
echo "- SMTP Server: ${SMTP_SERVER}"
echo "- SMTP Port: ${SMTP_PORT}"
echo "- From/User: ${SMTP_USER}"
echo "- To: ${NOTIFICATION_EMAIL}"

# Verify password file exists
if [ ! -f "$SMTP_PASS_FILE" ]; then
    echo "Error: Password file $SMTP_PASS_FILE not found"
    exit 1
fi

# Create msmtp config file
CONFIG_FILE="/root/.msmtprc"
cat > "${CONFIG_FILE}" << EOF
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        gmx
host           ${SMTP_SERVER}
port           ${SMTP_PORT}
from           ${SMTP_USER}
user           ${SMTP_USER}
password       ${SMTP_PASS}
tls_certcheck  on

account default : gmx
EOF

# Set secure permissions
chmod 600 "${CONFIG_FILE}"

# Send test mail
echo "Subject: Proxmox GFS Backup Test
From: ${SMTP_USER}
To: ${NOTIFICATION_EMAIL}

GFS Backup test mail from $(hostname)
Test Time: $(date)
Config: DRY_RUN=${DRY_RUN}" | msmtp --debug -a gmx "${NOTIFICATION_EMAIL}"

# Check result and cleanup
RC=$?
rm -f "${CONFIG_FILE}"

if [ $RC -eq 0 ]; then
    echo "Test mail sent successfully"
    exit 0
else
    echo "Failed to send test mail"
    echo "MSMTP log contents:"
    tail -n 20 /var/log/msmtp.log
    exit 1
fi
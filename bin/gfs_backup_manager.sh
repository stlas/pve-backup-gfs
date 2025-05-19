#!/bin/bash
#
# Proxmox GFS Backup Manager
# Copyright (c) 2024 Stefan Laszczyk
#

# Set strict mode
set -euo pipefail
IFS=$'\n\t'

# Load required paths
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PERL5LIB="$BASE_DIR/lib/perl"

# Source modules
source "$BASE_DIR/lib/bash/logging.sh"
source "$BASE_DIR/lib/bash/mail.sh"
source "$BASE_DIR/lib/bash/utils.sh"

# Initialize logging
init_logging "/var/log/proxmox-backup/gfs_backup.log"

# Check dependencies
check_dependencies() {
    local deps=(perl msmtp)
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if ((${#missing[@]} > 0)); then
        echo "Missing dependencies: ${missing[*]}"
        echo "Please install: apt-get install ${missing[*]}"
        exit 1
    fi
}

# Backup function using Perl module
do_backup() {
    local vmid=$1
    local type=$2

    perl -e '
        use lib "'$BASE_DIR'/lib/perl";
        use PVE::GFSBackup;

        my $backup = PVE::GFSBackup->new();
        my $vmid = $ARGV[0];
        my $type = $ARGV[1];

        eval {
            if ($type eq "vm") {
                $backup->backup_vm($vmid);
            } else {
                $backup->backup_ct($vmid);
            }
        };
        if ($@) {
            die "Backup failed: $@\n";
        }
    ' "$vmid" "$type" || return 1
}

# Main function
main() {
    log_message "INFO" "Starting Proxmox GFS Backup" "Starte Proxmox GFS Backup"
    # ... backup logic will be added here ...
    return 0
}

# Add check early in script
check_dependencies

# Run main function
main "$@"
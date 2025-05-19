#!/bin/bash
#
# Logging functionality for GFS Backup Manager
# Copyright (c) 2024 Stefan Laszczyk
#

# Log levels
declare -r LOG_DEBUG=0
declare -r LOG_INFO=1
declare -r LOG_WARN=2
declare -r LOG_ERROR=3

# Initialize logging
init_logging() {
    local log_file="${1:-/var/log/proxmox-backup/gfs_backup.log}"
    local log_dir=$(dirname "$log_file")
    
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir"
    fi
    
    if [[ ! -f "$log_file" ]]; then
        touch "$log_file"
        chmod 640 "$log_file"
    fi
    
    export LOG_FILE="$log_file"
}

# Log message with level and color support
log_message() {
    local level="$1"
    local msg="$2"
    local msg_de="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case "$level" in
        DEBUG) color="\e[1;35m" ;;
        INFO)  color="\e[1;34m" ;;
        WARN)  color="\e[1;33m" ;;
        ERROR) color="\e[1;31m" ;;
    esac
    
    # Write to log file
    if [[ "$LANG" == "de_DE.UTF-8" ]]; then
        echo -e "[$timestamp] ${level}: ${msg_de:-$msg}" >> "$LOG_FILE"
    else
        echo -e "[$timestamp] ${level}: $msg" >> "$LOG_FILE"
    fi
}
#!/bin/bash

validate_config() {
    local errors=0
    
    # Required variables check
    local required=(
        "BACKUP_DIR"
        "SMTP_SERVER"
        "SMTP_USER"
        "SMTP_PASS"
        "NOTIFICATION_EMAIL"
    )
    
    # Value validation
    [[ ! $BACKUP_COMPRESS =~ ^(zstd|gz|lzo)$ ]] && 
        echo "Error: Invalid BACKUP_COMPRESS value" && ((errors++))
    
    [[ ! $BACKUP_LEVEL =~ ^([1-9]|1[0-9])$ ]] && 
        echo "Error: Invalid BACKUP_LEVEL value" && ((errors++))
    
    [[ ! $LOG_LEVEL =~ ^(DEBUG|INFO|WARN|ERROR)$ ]] && 
        echo "Error: Invalid LOG_LEVEL value" && ((errors++))
        
    [[ ! -d $BACKUP_DIR ]] && 
        echo "Error: Backup directory not found" && ((errors++))
        
    return $errors
}
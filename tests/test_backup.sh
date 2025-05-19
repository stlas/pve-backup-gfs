#!/bin/bash## Test Suite for Proxmox GFS Backup# Copyright (c) 2024 Stefan Laszczyk## Import required modulesSCRIPT_DIR="$(dirname "$(readlink -f "$0")")"BASE_DIR="$(dirname "$SCRIPT_DIR")"source "$BASE_DIR/lib/bash/logging.sh"source "$BASE_DIR/lib/bash/utils.sh"# Setup test environmentsetup_test_env() {    export BACKUP_DIR="/tmp/test_backup"    export SMTP_SERVER="test.example.com"    export SMTP_USER="test@example.com"    export SMTP_PASS="testpass"    export NOTIFICATION_EMAIL="admin@example.com"    mkdir -p "$BACKUP_DIR"}# Cleanup test environmentcleanup_test_env() {    rm -rf "$BACKUP_DIR"    unset BACKUP_DIR SMTP_SERVER SMTP_USER SMTP_PASS NOTIFICATION_EMAIL}# Initialize test environmentinit_test() {    init_logging "/tmp/test_backup.log"    log_message "INFO" "Starting test suite" "Starte Test-Suite"}# Test logging functionalitytest_logging() {    log_message "INFO" "Testing logging" "Teste Logging"    if [[ -f "$LOG_FILE" ]]; then        echo "✓ Logging test passed"        return 0    else        echo "✗ Logging test failed"        return 1    fi}# Test config validationtest_config_validation() {    source "../config/config.sh.example"    if validate_config; then
        echo "✓ Config validation test passed"
        return 0
    else
        echo "✗ Config validation test failed"
        return 1
    fi
}

# Test Perl module
test_perl_module() {
    perl -e '
        use strict;
        use warnings;
        use Test::More;
        use lib "../lib/perl";
        use PVE::GFSBackup;
        
        # Test module loading
        require_ok("PVE::GFSBackup");
        
        # Test object creation
        my $backup = PVE::GFSBackup->new({
            compress => "zstd",
            level => 1
        });
        isa_ok($backup, "PVE::GFSBackup");
        
        done_testing();
    ' || return 1
}

# Main test runner
main() {
    init_test
    local failed=0
    
    echo "Setting up test environment..."
    setup_test_env
    
    echo -e "\nRunning tests..."
    test_logging || ((failed++))
    test_config_validation || ((failed++))
    test_perl_module || ((failed++))
    
    echo -e "\nCleaning up..."
    cleanup_test_env
    
    # Show results
    if [[ $failed -eq 0 ]]; then
        log_message "INFO" "All tests passed" "Alle Tests erfolgreich"
        echo -e "\nTest Summary: Alle Tests erfolgreich"
        exit 0
    else
        log_message "ERROR" "$failed tests failed" "$failed Tests fehlgeschlagen"
        echo -e "\nTest Summary: $failed fehlgeschlagen"
        exit 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
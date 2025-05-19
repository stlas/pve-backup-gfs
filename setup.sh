#!/bin/bash
set -e

echo "Erstelle Projektstruktur..."
mkdir -p {bin,lib/PVE/{API2,CLI},www/manager6/js,locale,t,debian}

echo "Erstelle Basis-Dateien..."
# Hauptmodul
cat > lib/PVE/API2/BackupGFS.pm << 'EOF'
package PVE::API2::BackupGFS;
use strict;
use warnings;
use PVE::Tools qw(extract_param);
use base qw(PVE::RESTHandler);
our $VERSION = '1.0.0';
1;
EOF

# Git-Konfiguration wenn nicht bereits vorhanden
if [ ! -d .git ]; then
    git init
    git config user.name "stlas"
    git config user.email "stlas1967@gmail.com"
    git remote add origin git@github.com:stlas/pve-backup-gfs.git
    git branch -M main
fi

echo "Setup abgeschlossen!"

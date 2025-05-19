package PVE::GFSBackup;

use strict;
use warnings;
use PVE::Storage;
use PVE::QemuServer;
use PVE::LXC;
use PVE::Tools;
use Carp qw(croak);

# Add version
our $VERSION = '1.0.0';

# Constructor
sub new {
    my ($class, $config) = @_;
    croak "Config parameter required" unless $config;
    
    my $self = {
        config => $config,
        storage => undef,
        compress => $config->{compress} || 'zstd',
        level => $config->{level} || 1,
    };
    bless $self, $class;
    return $self;
}

# Initialize storage with better error handling
sub init_storage {
    my ($self, $storage_id) = @_;
    croak "Storage ID required" unless $storage_id;
    
    eval {
        $self->{storage} = PVE::Storage::config();
        die "Storage $storage_id not found" unless $self->{storage}->{ids}->{$storage_id};
        # Test storage accessibility
        PVE::Storage::activate_storage($self->{storage}, $storage_id);
    };
    if ($@) {
        croak "Storage initialization failed: $@";
    }
    return $self;
}

# Error handling wrapper
sub _safe_exec {
    my ($self, $func, @args) = @_;
    
    eval {
        $func->(@args);
    };
    if ($@) {
        my $error = $@;
        warn "Operation failed: $error";
        croak $error;
    }
}

# Backup VM
sub backup_vm {
    my ($self, $vmid, $storage_id) = @_;
    
    eval {
        # Check if VM exists
        my $conf = PVE::QemuServer::load_config($vmid)
            or die "VM $vmid not found\n";
            
        # Prepare backup options
        my $opts = {
            storage => $storage_id,
            compress => $self->{compress},
            'compress-level' => $self->{level},
            mode => 'snapshot',
        };
        
        # Perform backup
        PVE::QemuServer::vzdump($vmid, $opts);
    };
    if ($@) {
        die "VM backup failed: $@\n";
    }
    return 1;
}

# Backup Container
sub backup_ct {
    my ($self, $ctid, $storage_id) = @_;
    
    eval {
        # Check if container exists
        my $conf = PVE::LXC::load_config($ctid)
            or die "Container $ctid not found\n";
            
        # Prepare backup options
        my $opts = {
            storage => $storage_id,
            compress => $self->{compress},
            'compress-level' => $self->{level},
            mode => 'snapshot',
        };
        
        # Perform backup
        PVE::LXC::vzdump($ctid, $opts);
    };
    if ($@) {
        die "Container backup failed: $@\n";
    }
    return 1;
}

# Add backup verification
sub verify_backup {
    my ($self, $backup_path) = @_;
    croak "Backup path required" unless $backup_path;
    
    return $self->_safe_exec(sub {
        die "Backup file not found" unless -f $backup_path;
        
        # Verify archive integrity
        my $cmd = ["vzdump", "--verify", $backup_path];
        PVE::Tools::run_command($cmd);
    });
}

# Add cleanup routine
sub cleanup_failed_backup {
    my ($self, $backup_path) = @_;
    return unless $backup_path && -f $backup_path;
    
    $self->_safe_exec(sub {
        unlink $backup_path or die "Could not remove failed backup: $!";
    });
}

1; # Module must return true
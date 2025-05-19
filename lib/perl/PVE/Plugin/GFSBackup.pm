package PVE::Plugin::GFSBackup;

use strict;
use warnings;
use base qw(PVE::RESTHandler);
use PVE::Storage;
use PVE::Tools qw(run_command);
use POSIX qw(strftime);

# Version
our $VERSION = '1.0.0';

# Constructor
sub new {
    my ($class, $config) = @_;
    my $self = bless {
        config => $config,
    }, $class;
    return $self;
}

# Create GFS backup method
sub create_gfs_backup {
    my ($self, $params) = @_;
    
    # Validate required parameters
    die "Missing VMID" unless $params->{vmid};
    die "Missing storage" unless $params->{storage};
    die "Missing mode" unless $params->{mode};
    
    # Verify storage exists
    my $storage_cfg = PVE::Storage::config();
    die "Storage '$params->{storage}' not found" 
        unless $storage_cfg->{ids}->{$params->{storage}};
    
    # Generate backup name with timestamp
    my $timestamp = strftime("%Y-%m-%d_%H-%M-%S", localtime);
    my $backup_name = sprintf("vm-%s-%s-%s", $params->{vmid}, $params->{mode}, $timestamp);
    
    # Build vzdump command
    my @cmd = (
        'vzdump',
        $params->{vmid},
        '--compress', ($params->{compress} || 'zstd'),
        '--storage', $params->{storage},
        '--mode', 'snapshot',
    );
    
    # Execute backup
    eval {
        run_command(\@cmd);
    };
    if ($@) {
        die "Backup failed: $@";
    }
    
    return "Backup started for VMID: $params->{vmid} as $backup_name";
}

# Required method for PVE plugins
sub api_version {
    return '2.0';
}

# Register plugin methods
__PACKAGE__->register_method({
    name => 'index',
    path => '',
    method => 'GET',
    description => 'Directory index.',
    parameters => {
        additionalProperties => 0,
        properties => {
            node => { type => 'string', optional => 1 },
            storage => { type => 'string', optional => 1 },
        },
    },
    returns => {
        type => 'array',
        items => {
            type => 'object',
            properties => {
                vmid => { type => 'integer' },
                name => { type => 'string' },
                status => { type => 'string' },
            },
        },
    },
    code => sub {
        my ($param) = @_;
        return [];
    },
});

# Register GFS backup method
__PACKAGE__->register_method({
    name => 'create_gfs_backup',
    path => 'backup',
    method => 'POST',
    description => 'Create a GFS (Grandfather-Father-Son) backup',
    parameters => {
        additionalProperties => 0,
        properties => {
            vmid => { type => 'integer', description => 'The ID of the VM/CT to backup' },
            storage => { type => 'string', description => 'Target storage for backup' },
            mode => {
                type => 'string',
                enum => ['daily', 'weekly', 'monthly'],
                description => 'Backup mode (daily, weekly, monthly)'
            },
            compress => {
                type => 'string',
                enum => ['zstd', 'gzip', 'none'],
                optional => 1,
                default => 'zstd',
            },
        },
    },
    returns => { type => 'string' },
    code => sub {
        my ($param) = @_;
        # Implementierung folgt
        return "Backup started for VMID: $param->{vmid}";
    },
});

1;

use strict;
use warnings;
use Test::More;
use lib '/root/proxmox-gfs-backup/lib/perl';
use PVE::APIClient::Exception;

# Test basic plugin loading
require_ok('PVE::Plugin::GFSBackup');

# Test plugin instantiation with config
my $config = {
    compress => 'zstd',
    level => 1,
};
my $plugin = PVE::Plugin::GFSBackup->new($config);
ok(defined $plugin, 'Plugin created');

# Test plugin registration with proper path
my $methods = $plugin->register_method({
    name => 'gfs_backup',
    path => 'backup',
    method => 'POST',
    description => 'Create GFS backup',
    parameters => {
        node => {
            type => 'string',
            description => 'Node name',
            optional => 0,
        },
    },
});
ok(defined $methods, 'Plugin methods registered');

# Test GFS backup method
eval {
    my $result = $plugin->create_gfs_backup({
        vmid => 100,
        storage => 'local',
        mode => 'daily',
        compress => 'zstd'
    });
    ok(defined $result, 'Backup method returns result');
    like($result, qr/Backup started/, 'Backup message is correct');
};
if ($@) {
    fail("Backup method failed: $@");
}

# Test backup with invalid parameters
eval {
    $plugin->create_gfs_backup({
        storage => 'local',
        mode => 'daily',
    });
};
like($@, qr/Missing VMID/, 'Caught missing VMID error');

# Test backup with invalid storage
eval {
    $plugin->create_gfs_backup({
        vmid => 100,
        storage => 'invalid_storage',
        mode => 'daily',
    });
};
like($@, qr/Storage.*not found/, 'Caught invalid storage error');

done_testing();

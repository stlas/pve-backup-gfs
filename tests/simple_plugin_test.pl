#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Data::Dumper;
use Cwd 'getcwd';

# Clear visual marker for start
print "\n" . "#" x 80 . "\n";
print "#  Starting Test Script\n";
print "#" x 80 . "\n\n";

print "Hallo Welt!!\n";
print "Debug Output Enabled\n\n";

# Configure debug output
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 1;

# Setup paths with visual markers
print "=" x 40 . "\n";
print "Environment Setup:\n";
print "=" x 40 . "\n";

my $lib_path = "$FindBin::Bin/../lib/perl";
print "- Library path: $lib_path\n";
print "- Current directory: " . getcwd() . "\n";
print "- Perl version: $]\n";
print "- \@INC paths:\n";
foreach my $path (@INC) {
    print "  * $path\n";
}
print "=" x 40 . "\n\n";

use lib $lib_path;

# Test 1: Basic module loading
print "\nTest 1: Module Loading\n";
my $module = 'PVE::Plugin::GFSBackup';
print "- Attempting to load: $module\n";

# Test loading the module
eval {
    require_ok($module) or BAIL_OUT("Module load failed");
};
if ($@) {
    BAIL_OUT("Module load error: $@");
}

done_testing();

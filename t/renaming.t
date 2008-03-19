use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;

# Make sure Sub::Exporter's -prefix method does what we expect
use_ok('Log::Syslog::Abstract', -all => { -prefix => 'md_' });

is( ref \&md_syslog, 'CODE', 'Got a subref for md_syslog');
is( ref \&md_openlog, 'CODE', 'Got a subref for md_openlog');
is( ref \&md_closelog, 'CODE', 'Got a subref for md_closelog');

ok( ! exists $::{syslog}, 'No symbol in table for syslog');
ok( ! exists $::{openlog}, 'No symbol in table for openlog');
ok( ! exists $::{closelog}, 'No symbol in table for closelog');

#!/usr/bin/perl -w
use Test::More;

eval { require Unix::Syslog };

plan( skip_all => q{Unix::Syslog not installed; can't test against real module} ) if $@;
plan tests => 1;

use_ok('Log::Syslog::Abstract', qw( openlog syslog closelog ));

# TODO Automated testing of Log::Syslog::Abstract methods against a
# real backend is difficult...

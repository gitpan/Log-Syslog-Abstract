#!/usr/bin/perl -w
use Test::More tests => 47;
use Test::Exception;

# Fake up a Unix::Syslog class
BEGIN { $INC{'Unix/Syslog.pm'} = 1; }
package Unix::Syslog;
sub _stub    { die [ q{Unix::Syslog stub}, @_ ] }
*openlog  = \&_stub;
*syslog   = \&_stub;
*closelog = \&_stub;

# Constants borrowed from sys/syslog.h on Linux.  May not be the same
# on all platforms, but for testing purposes it should be fine.
sub LOG_PID     { 0x01 };
sub LOG_NDELAY  { 0x08 };

sub LOG_EMERG   { 0    };
sub LOG_ALERT   { 1    };
sub LOG_CRIT    { 2    };
sub LOG_ERR     { 3    };
sub LOG_WARNING { 4    };
sub LOG_NOTICE  { 5    };
sub LOG_INFO    { 6    };
sub LOG_DEBUG   { 7    };

sub LOG_KERN     { 0<<3 };
sub LOG_USER     { 1<<3 };
sub LOG_MAIL     { 2<<3 };
sub LOG_DAEMON   { 3<<3 };
sub LOG_AUTH     { 4<<3 };
sub LOG_SYSLOG   { 5<<3 };
sub LOG_LPR      { 6<<3 };
sub LOG_NEWS     { 7<<3 };
sub LOG_UUCP     { 8<<3 };
sub LOG_CRON     { 9<<3 };
sub LOG_AUTHPRIV { 10<<3 };
sub LOG_FTP      { 11<<3 };
sub LOG_LOCAL0   { 16<<3 };
sub LOG_LOCAL1   { 17<<3 };
sub LOG_LOCAL2   { 18<<3 };
sub LOG_LOCAL3   { 19<<3 };
sub LOG_LOCAL4   { 20<<3 };
sub LOG_LOCAL5   { 21<<3 };
sub LOG_LOCAL6   { 22<<3 };
sub LOG_LOCAL7   { 23<<3 };

package main;

BEGIN { use_ok('Log::Syslog::Abstract', qw( openlog syslog closelog )) };

dies_ok { openlog() } 'openlog with no args dies';
like ( $@, qr/first argument must be an identifier string/, '... with expected error');

dies_ok { openlog('wookie') } 'openlog with one arg dies';
like ( $@, qr/second argument must be flag string/, '... with expected error');

dies_ok { openlog('wookie', 'pid,ndelay') } 'openlog with 2 args dies';
like ( $@, qr/third argument must be a facility string/, '... with expected error');

dies_ok { openlog('wookie', 'pid,ndelay', 'mail') } 'openlog hits our stub'; 
is_deeply( $@, [ q{Unix::Syslog stub}, 'wookie', Unix::Syslog::LOG_PID | Unix::Syslog::LOG_NDELAY, Unix::Syslog::LOG_MAIL ], '... got expected data via the stub');

dies_ok { syslog('err', '%s', 'Our wookie is broken') } 'syslog hits our stub'; 
is_deeply( $@, [ q{Unix::Syslog stub}, Unix::Syslog::LOG_ERR, '%s', 'Our wookie is broken' ], '... got expected data via the stub');

dies_ok { closelog() } 'closelog hits our stub'; 
is_deeply( $@, [ q{Unix::Syslog stub} ], '... got expected data via the stub');

# Only check mapping of values if we have a real Unix::Syslog on this
# platform.

# check _convert_flags
my %flag_to_value = (
	pid     => Unix::Syslog::LOG_PID(),
	ndelay  => Unix::Syslog::LOG_NDELAY(),
);
is( Log::Syslog::Abstract::_convert_flags( 'pid,ndelay'), 0x01 | 0x08, 'bitwise-or of all flags is as expected');
foreach my $flag ( keys %flag_to_value ) {
	is( Log::Syslog::Abstract::_convert_flags( $flag ), $flag_to_value{$flag}, "Flag $flag works");
}

# check _convert_facility
# TODO: works on Linux... what about elsewhere?
my %facility_to_value = (
	emerg => Unix::Syslog::LOG_EMERG(),
	panic => Unix::Syslog::LOG_EMERG(),
	alert => Unix::Syslog::LOG_ALERT(),
	crit => Unix::Syslog::LOG_CRIT(),
	error => Unix::Syslog::LOG_ERR(),
	'err' => Unix::Syslog::LOG_ERR(),
	warning => Unix::Syslog::LOG_WARNING(),
	notice => Unix::Syslog::LOG_NOTICE(),
	info => Unix::Syslog::LOG_INFO(),
	debug => Unix::Syslog::LOG_DEBUG(),

	kern => Unix::Syslog::LOG_KERN(),
	user => Unix::Syslog::LOG_USER(),
	mail => Unix::Syslog::LOG_MAIL(),
	daemon => Unix::Syslog::LOG_DAEMON(),
	auth => Unix::Syslog::LOG_AUTH(),
	syslog => Unix::Syslog::LOG_SYSLOG(),
	lpr => Unix::Syslog::LOG_LPR(),
	news => Unix::Syslog::LOG_NEWS(),
	uucp => Unix::Syslog::LOG_UUCP(),
	cron => Unix::Syslog::LOG_CRON(),
	authpriv => Unix::Syslog::LOG_AUTHPRIV(),
	ftp => Unix::Syslog::LOG_FTP(),
	local0 => Unix::Syslog::LOG_LOCAL0(),
	local1 => Unix::Syslog::LOG_LOCAL1(),
	local2 => Unix::Syslog::LOG_LOCAL2(),
	local3 => Unix::Syslog::LOG_LOCAL3(),
	local4 => Unix::Syslog::LOG_LOCAL4(),
	local5 => Unix::Syslog::LOG_LOCAL5(),
	local6 => Unix::Syslog::LOG_LOCAL6(),
	local7 => Unix::Syslog::LOG_LOCAL7(),
);

foreach my $facility ( keys %facility_to_value ) {
	is( Log::Syslog::Abstract::_convert_facility( $facility ), $facility_to_value{$facility}, "Flag $facility works");
}

# Try some combinations
is( Log::Syslog::Abstract::_convert_facility( 'notice|local7') , $facility_to_value{notice} | $facility_to_value{local7}, 'bitwise-OR works');

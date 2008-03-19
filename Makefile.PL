use strict;
use warnings;
use inc::Module::Install;

name           'Log-Syslog-Abstract';
all_from       'lib/Log/Syslog/Abstract.pm';

requires       'Sub::Exporter';

recommends     'Unix::Syslog';
recommends     'Sys::Syslog';

build_requires 'Test::More';
build_requires 'Test::Exception';
build_requires 'Devel::Hide';

WriteAll;

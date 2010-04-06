use inc::Module::Install;

name 'Lyra-Core';
all_from 'lib/Lyra/Core.pm';

requires 'AnyEvent';
requires 'AnyEvent::DBI';
requires 'Cache::Memcached::AnyEvent' => 0.00015;
requires 'Plack::Runner';
requires 'Moose';
requires 'namespace::autoclean';

# Test infrastructure
requires 'Class::Accessor::Lite';
requires 'Test::mysqld';
requires 'Test::Memcached';
requires 'Time::HiRes';

if (! cc_available()) {
    print STDERR "No compiler available. Cannot continue\n";
    exit 0;
}

cc_warnings;
cc_src_paths 'xs';

auto_set_repository;
WriteAll;
use inc::Module::Install;

name 'Lyra-Core';
version '0.00001';

requires 'AnyEvent';
requires 'AnyEvent::DBI';
requires 'Cache::Memcached::AnyEvent' => 0.00015;
requires 'Plack::Runner';
requires 'Moose';
requires 'namespace::autoclean';

WriteAll;
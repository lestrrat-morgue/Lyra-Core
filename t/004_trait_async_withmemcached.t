use strict;
use Test::More tests => 2;
use Moose;

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::Async::WithMemcached' ],
    );

    can_ok($meta->name, 'cache', 'cache_servers', 'cache_compress_threshold', 'cache_namespace', '_build_cache');
};
ok(!$@) or diag($@);
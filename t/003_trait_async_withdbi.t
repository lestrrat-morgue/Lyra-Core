use strict;
use Test::More tests => 2;
use Moose;

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::Async::WithDBI' ],
    );

    can_ok($meta->name, 'dbh', 'execsql');
};
ok(!$@) or diag($@);
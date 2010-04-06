use strict;
use Test::More tests => 2;

use Moose;

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::App::StandaloneServer' ]
    );
};
like($@, qr/'Lyra::Trait::App::StandaloneServer' requires the method 'build_app'/) or diag($@);

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::App::StandaloneServer' ],
        methods => {
            build_app => sub { "dummy" }
        }
    );
};
ok(!$@) or diag($@);
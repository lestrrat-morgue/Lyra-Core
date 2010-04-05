use strict;
use Test::More tests => 3;

use Moose;

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::Async::PsgiApp' ]
    );
};
like($@, qr/'Lyra::Trait::Async::PsgiApp' requires the method 'process'/) or diag($@);

eval {
    my $meta = Moose::Meta::Class->create_anon_class(
        roles => [ 'Lyra::Trait::Async::PsgiApp' ],
        methods => {
            process => sub { "dummy" }
        }
    );

    can_ok($meta->name, 'psgi_app', 'respond_cb');
};
ok(!$@) or diag($@);
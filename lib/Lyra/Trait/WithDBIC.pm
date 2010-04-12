package Lyra::Trait::WithDBIC;
use Moose::Role;
use Lyra::Schema;
use namespace::autoclean;

has schema => (
    is => 'ro',
    isa => 'Lyra::Schema',
    lazy_build => 1,
    handles => {
        txn_guard => 'txn_scope_guard',
        resultset => 'resultset',
    }
);

has connect_info => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

sub _build_schema {
    my $self = shift;
    return Lyra::Schema->connect( @{ $self->connect_info } );
}

1;
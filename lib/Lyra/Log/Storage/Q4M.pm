package Lyra::Log::Storage::Q4M;
use Moose;
use Lyra::Util qw(NOOP);
use namespace::autoclean;

extends 'Lyra::Log::Storage';

with 'Lyra::Trait::WithDBI';

has table => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has sql => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_sql {
    my $self = shift;
    sprintf("INSERT INTO %s (ad_id, data, created_on) VALUES (?, ?, ?)", $_[0]->table);
}

sub store {
    my ($self, $data, $cb) = @_;

    $cb ||= \&NOOP;
    $self->execsql(
        $self->sql,
        $data->{id}, encode_json $data, \'NOW()',
        $cb
    );
}

__PACKAGE__->meta->make_immutable();

1;

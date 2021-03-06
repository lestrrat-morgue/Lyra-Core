package Lyra::Log::Storage::File;
use Moose;
use AnyEvent;
use AnyEvent::AIO;
use IO::AIO;
use Fcntl;
use Lyra::Util qw(NOOP);
use POSIX ();
use namespace::autoclean;

extends 'Lyra::Log::Storage';

has prefix => (
    is => 'ro',
    isa => 'Str',
    default => 'click',
);

has groups => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} }
);

# filename is <prefix>.<timestamp>.<pid>
# where timestamp is YYYYMMDDhhXX, and it's recycled every 15 minutes.
# so on a given hour, you get YYYYMMDDhh01, 02, 03, 04

has filehandles => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{} }
);

sub store {
    my ($self, $message, $cb) = @_;

    # get the current file name we should be writing to
    my @localtime = localtime();
    my $filename = join('.', 
        $self->prefix,
        sprintf('%s%02d', 
            POSIX::strftime('%Y%m%d%H', @localtime),
            int($localtime[1] / 15) + 1
        ),
        $$,
        'dat',
    );

    my $fh = $self->filehandles->{ $filename };

    if ( ! $fh ) {
        open($fh, '>>', $filename) or die "Failed to open $filename for writing $!";
        $self->filehandles->{ $filename } = $fh;
        my $t; $t = AE::timer 15 * 60, 0, sub {
            undef $t;
            delete $self->filehandles->{ $filename };
        };
    }

    # このCB、本当はいらないんだけど、これがないとテストがうまく書けない・・・
    $cb ||= \&NOOP;
    my $length = length $message;
    aio_write $fh, -1, $length, $message, 0, sub { 
        $cb->($filename);
    };
}

__PACKAGE__->meta->make_immutable();

1;
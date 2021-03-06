package Lyra::Test;
use strict;
use base qw(Exporter);
use Carp ();
use Lyra::Test::Plackup;
use Lyra::Test::Fixture::Daemons;

our @EXPORT_OK = qw(
    adengine_byarea
    async_dbh
    click_server 
    dbic_schema
    find_program
    start_daemons 
);

sub null_log {
    require Lyra::Log::Storage::Null;
    Lyra::Log::Storage::Null->new();
}

sub start_daemons(@) {
    my $guard = Lyra::Test::Fixture::Daemons->new();
    $guard->start();
    return $guard;
}

sub dbic_schema(@) {
    my @connect_info = @_;
    require Lyra::Schema;

    if (! @connect_info) {
        @connect_info = (
            $ENV{TEST_DSN} || Carp::confess("No DSN provided for Test DBIC Schema"),
            $ENV{TEST_USERNAME},
            $ENV{TEST_PASSWORD},
            {
                RaiseError => 1,
                AutoCommit => 1,
            }
        );
    }
    return Lyra::Schema->connect( @connect_info );
}

sub async_dbh(@) {
    require AnyEvent::DBI;
    return AnyEvent::DBI->new(
        $ENV{TEST_DSN},
        $ENV{TEST_USERNAME},
        $ENV{TEST_PASSWORD},
        exec_server => 1,
        RaiseError => 1,
        AutoCommit => 1,
    );
}

sub async_memcached(@) {
    require Cache::Memcached::AnyEvent;
    return Cache::Memcached::AnyEvent->new(
        servers => [ "127.0.0.1:$ENV{ TEST_MEMCACHED_PORT }" ],
        compress_threshld => 10_000,
        namespace => join('.', 'lyra', 'test', $$, {}, rand())
    );
}

sub plackup(@) {
    my $plackup = Lyra::Test::Plackup->new(@_);
    $plackup->start or die "Could not start server";
    return $plackup;
}

sub click_server(@) {
    return plackup(
        base_dir => 't/',
        server => 'Twiggy',
        app => sub {
            require Lyra::Server::Click;

            Lyra::Server::Click->new(
                dbh => async_dbh(),
                cache => async_memcached(),
                log_storage => null_log(),
            )->psgi_app
        },
        @_,
    );
}

sub adengine_byarea(@) {
    my %args = @_;
    my $click_uri = delete $args{click_server}
        or die "You need to specify a click server URL";
    my $templates_dir = delete $args{templates_dir} || 'templates';
    my $request_log = delete $args{request_log};
    my $impression_log = delete $args{impression_log};
    return plackup(
        base_dir => 't/',
        server => 'Twiggy',
        app => sub {
            require Lyra::Server::AdEngine::ByArea;

            Lyra::Server::AdEngine::ByArea->new(
                dbh => async_dbh(),
                cache => async_memcached(),
                click_uri => $click_uri,
                request_log_storage => $request_log || null_log(),
                impression_log_storage => $impression_log || null_log(),
                templates_dir => $templates_dir,
            )->psgi_app
        },
        %args,
    );
}

sub find_program($) {
    my $prog = shift;
    my $path = _get_path_of($prog);
    return $path
        if $path;
    die "could not find $prog, please set appropriate PATH";
}

sub _get_path_of {
    my $prog = shift;
    my $path = `which $prog 2> /dev/null`;
    chomp $path
        if $path;
    $path = ''
        unless -x $path;
    $path;
}


1;
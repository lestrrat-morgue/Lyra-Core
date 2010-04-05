package Lyra::Trait::App::WithLogger;
use MooseX::Role::Parameterized;
use namespace::autoclean;

with 'MooseX::Getopt';

parameter loggers => (
    isa => 'ArrayRef',
    required => 1,
);

role {
    my $p = shift;

    foreach my $logger (@{ $p->loggers }) {
        my $prefix = $logger->{prefix};

        has "${prefix}_log_class" => (
            is => 'ro',
            isa => 'Str',
            default => 'File',
            documentation => "Class for logging $prefix. Defaut is File",
        );
    
        has "${prefix}_log_disable" => (
            is => 'ro',
            isa => 'Bool',
            default => 0,
            documentation => "Flag to enable/disable $prefix logging",
        );
    
        has "${prefix}_log_prefix" => (
            is => 'ro',
            isa => 'Str',
            default => "$prefix.",
            documentation => "Prefix to use for log file names for $prefix"
        );
    
        has "${prefix}_log_dsn" => (
            is => 'ro',
            isa => 'Str',
            documentation => "DSN for logging $prefix via Q4M",
        );
    
        has "${prefix}_log_user" => (
            is => 'ro',
            isa => 'Str',
            documentation => "Username for logging $prefix via Q4M",
        );

        has "${prefix}_log_password" => (
            is => 'ro',
            isa => 'Str',
            documentation => "Password for logging $prefix via Q4M",
        );

        has "${prefix}_log_table" => (
            is => 'ro',
            isa => 'Str',
            default => "${prefix}_log_queue",
            documentation => "Table name for logging $prefix via Q4M",
        );

        has "${prefix}_log_dsn" => (
            is => 'ro',
            isa => 'Str',
            documentation => "SQL to use for logging $prefix via Q4M",
        );
    
        my $p_log_class = "${prefix}_log_class";
        my $p_log_disable = "${prefix}_log_disable";
        my $p_log_prefix = "${prefix}_log_prefix";
        my $p_log_dsn = "${prefix}_log_dsn";
        my $p_log_user = "${prefix}_log_user";
        my $p_log_password = "${prefix}_log_password";
        my $p_log_table = "${prefix}_log_table";
        my $p_log_sql = "${prefix}_log_sql";

        method "build_${prefix}_log" => sub {
            my $self = shift;

            my $class = $self->$p_log_class;
            if ($self->$p_log_disable) {
                $class = "Lyra::Log::Storage::Null";
            } elsif ($class !~ s/^\+//) {
                $class = "Lyra::Log::Storage::$class";
            }
    
            if (! Class::MOP::is_class_loaded($class) ) {
                Class::MOP::load_class($class);
            }
    
            my $object;
            if ( $class->isa('Lyra::Log::Storage::File') ) {
                $object = $class->new(prefix => $self->$p_log_prefix);
            } elsif ( $class->isa('Lyra::Log::Storage::Q4M') ) {
                my $cv = AE::cv;
    
                my $dbh = AnyEvent::DBI->new(
                    $self->$p_log_dsn,
                    $self->$p_log_user,
                    $self->$p_log_password,
                    on_connect => sub { $cv->send() },
                    exec_server => 1,
                    RaiseError => 1,
                    AutoCommit => 1,
                );
    
                $cv->recv;
    
                my %args = (
                    dbh => $dbh,
                    table => $self->$p_log_table,
                );
                $args{sql} = $self->$p_log_sql if defined $self->$p_log_sql;
    
                $object = $class->new(%args);
            } else {
                $object = $class->new();
            }
            return $object;
        };
    }
};

1;

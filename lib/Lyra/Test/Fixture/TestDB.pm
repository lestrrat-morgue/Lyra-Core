package Lyra::Test::Fixture::TestDB;
use Moose;
use Digest::SHA1 qw(sha1_hex);
use namespace::autoclean;

has adserver_uri => (
    is => 'ro',
    isa => 'Str',
    default => 'http://127.0.0.1/'
);

sub deploy {
    my ($self, $schema) = @_;

    my $guard = $schema->txn_scope_guard();

    $self->deploy_members( $schema );
    $self->deploy_adsmaster( $schema );

    $guard->commit();
}

sub deploy_members {
    my ($self, $schema) = @_;

    $schema->resultset('Member')->create({
        id       => 'cb4f1ef2-45df-11df-afbd-37ecf7137823',
        email    => 'admin@lyra',
        password => sha1_hex( 'admin' ),
    })->create_related( roles => {
        rolename => 'admin'
    } );

    $schema->resultset('Member')->create({
        id       => '0e2feb66-45e0-11df-afbd-37ecf713782',
        email    => 'client@lyra',
        password => sha1_hex( 'client' ),
    })->create_related( roles => {
        rolename => 'client'
    } );
}

sub deploy_adsmaster {
    my ($self, $schema) = @_;
    my $master_rs = $schema->resultset('AdsMaster');

    # XXX use some other method if you want to bulk insert 
    my $count = 1;
    my @ads = map {
        $_->{id} ||= sprintf('test_ads_by_area%03d', $count++);
        $_->{landing_uri} ||= "http://127.0.0.1/$_->{id}";
        $_->{status} = 1 unless exists $_->{status};
        $_->{member_id} = '0e2feb66-45e0-11df-afbd-37ecf713782';
        $_;
    } (
        {
            title => 'オペラシティ',
            content => '最寄り駅は初台です',
            location => \q|GeomFromText('POINT(139.685945 35.683616)')|,
        },
        {
            title => 'NTT東日本',
            content => '最寄り駅は初台です',
            location => \q|GeomFromText('POINT(139.678481 35.689265)')|,
        },
        {
            title => '幡ヶ谷駅',
            content => '初台のとなりです',
            location => \q|GeomFromText('POINT(139.674506 35.678603)')|,
        },
        {
            title => '明治大学',
            content => '最寄り駅は明大前です',
            location => \q|GeomFromText('POINT(139.641874 35.675566)')|,
        },
        {
            title => '渋谷駅',
            content => '南口の使いにくさは異常です',
            location => \q|GeomFromText('POINT(139.703946 35.657775)')|,
        },
        {
            title => '三軒茶屋駅',
            content => 'こちらのハナマサの魚は結構質がいいですね',
            location => \q|GeomFromText('POINT(139.700174 35.656826)')|,
        },
    );

    foreach my $ad (@ads) {
        $master_rs->create( $ad );
    }
}

__PACKAGE__->meta->make_immutable();

1;

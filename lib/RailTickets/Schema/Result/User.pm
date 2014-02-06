package RailTickets::Schema::Result::User;

use strict;
use warnings;

use Authen::Passphrase::BlowfishCrypt;
use Encode qw(encode);

use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components('InflateColumn::Serializer', 'Core');
__PACKAGE__->table('user');

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    login => {
        data_type   => 'varchar',
        size        => 16,
        is_nullable => 0,
    },
    email => {
        data_type   => 'varchar',
        size        => 32,
        is_nullable => 0,
    },
    joined => {
        data_type         => 'integer',
        is_nullable       => 0,
    },
    preferences => {
        data_type => 'varchar',
        size      => 128,
        'serializer_class' => 'JSON',
    },
    activated => {
        data_type         => 'integer',
        is_nullable       => 0,
    },
    password => {
        data_type => 'char',
        size      => 60,
    },
);

__PACKAGE__->set_primary_key(qw/id/);
__PACKAGE__->add_unique_constraints( [qw/email/], [qw/login/]);
__PACKAGE__->has_many('bookmarks', 'RailTickets::Schema::Result::Bookmark', 'id');

sub new {
    my ($self, $attrs) = @_;
    $attrs->{'password'} = Authen::Passphrase::BlowfishCrypt->new(
        cost => 8,
        salt_random => 1,
        key_nul => 1,
        passphrase => encode("UTF-8", $attrs->{'password'}))->as_crypt;
    $self->next::method($attrs);
}

sub check_password {
    my ($self, $password) = @_;
    Authen::Passphrase::BlowfishCrypt->from_crypt($self->password)->match(encode("UTF-8", $password));
}

1;


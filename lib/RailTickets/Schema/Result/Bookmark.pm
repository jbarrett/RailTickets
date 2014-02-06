package RailTickets::Schema::Result::Bookmark;

use strict;
use warnings;

use LWP::Simple;
use HTML::TreeBuilder::XPath;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('bookmark');

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    user_id => {
        data_type   => 'integer',
        is_nullable => 0,
    },
    url => {
        data_type   => 'varchar',
        size        => 256,
        is_nullable => 0,
    },
    title => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 0,
    },
    description => {
        data_type   => 'varchar',
        size        => 1024,
        is_nullable => 0,
    },
    private => {
        data_type         => 'integer',
        is_nullable       => 0,
    },
    read => {
        data_type         => 'integer',
        is_nullable       => 0,
    },
    timestamp => {
        data_type         => 'integer',
        is_nullable       => 0,
    },
);

__PACKAGE__->set_primary_key(qw/id/);
__PACKAGE__->belongs_to('user', 'RailTickets::Schema::Result::User', 'user_id');
__PACKAGE__->has_many('bookmark_tags', 'RailTickets::Schema::Result::BookmarkTag', 'bookmark');
__PACKAGE__->many_to_many('tags' => 'bookmark_tags', 'tag');

sub new {
    my ($self, $attrs) = @_;
    $attrs->{'url'} = "http://" . $attrs->{'url'} if ($attrs->{'url'} !~ /^ftp:|^https?:\/\//i);
    if ($attrs->{'title'} =~ /^\s*$/) {
        my $title = HTML::TreeBuilder::XPath->new->parse_content(get($attrs->{'url'}))->findvalue('/html/head/title'); # needs an aggressive timeout.
        ($title) && ($attrs->{'title'} = $title);
    }
    $self->next::method($attrs);
}

1;


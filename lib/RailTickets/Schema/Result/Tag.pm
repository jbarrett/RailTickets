package RailTickets::Schema::Result::Tag;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tag');

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    name => {
        data_type   => 'varchar',
        size        => 16,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('bookmark_tag', 'RailTickets::Schema::Result::BookmarkTag', 'tag');
__PACKAGE__->many_to_many('bookmarks', 'bookmark_tag', 'bookmark');


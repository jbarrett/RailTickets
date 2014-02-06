package RailTickets::Schema::Result::BookmarkTag;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('bookmark_tag');
__PACKAGE__->add_columns(
    bookmark => {
        data_type   => 'integer',
        is_nullable => 0,
    },
    tag => {
        data_type   => 'integer',
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key(qw/tag bookmark/);
__PACKAGE__->belongs_to('bookmark', 'RailTickets::Schema::Result::Bookmark', 'bookmark');
__PACKAGE__->belongs_to('tag', 'RailTickets::Schema::Result::Tag', 'tag');

1;


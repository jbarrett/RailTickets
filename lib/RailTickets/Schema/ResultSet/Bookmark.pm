package RailTickets::Schema::ResultSet::Bookmark;

use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub page_for_user {
    my ($self, $user_id, $page, $results) = @_;

    $self->search (
        {   user_id => $user_id
        },
        {   page  => $page,
            rows => $results,
            order_by => { -desc => 'timestamp' },
            prefetch => { bookmark_tags => 'tag' }
        },
    );
}

sub page_for_user_tag {
    my ($self, $user_id, $page, $results, $tag) = @_;

#    my $subq = $schema->resultset('Bookmark')->search(
#        { user_id => $user_id, 'tag.name' => param('tag') },
#        { join => [ qw/bookmark_tag, tag/ ] }
#    )

    $self->search(
        {   user_id => $user_id,
            'tag.name' => $tag,
        },
        {   join => { bookmark_tags => 'tag' },
            page  => $page,
            rows => $results,
            order_by => { -desc => 'timestamp' }
        } # This results in extra queries later, need to subquery this / prefetch tags.

    );
}

1;


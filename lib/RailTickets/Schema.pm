package RailTickets::Schema;

use strict;
use warnings;

use base qw/DBIx::Class::Schema/;

# Schema version, used in database deployment
our $VERSION = 2;

__PACKAGE__->load_namespaces();
__PACKAGE__->stacktrace(0);

1;


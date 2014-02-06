#!/usr/bin/env perl

use strict;
use warnings;
use aliased 'DBIx::Class::DeploymentHandler' => 'DH';
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Dancer2 ':script';
use RailTickets;
use RailTickets::Schema;

# Based on script in DBIx::Class::DeploymentHandler::Manual::Intro

my $force_overwrite = 0;

unless ( GetOptions( 'force_overwrite!' => \$force_overwrite ) ) {
    die "Invalid options";
}

my $schema = RailTickets::schema('default');

my $dh = DH->new(
    {
        schema              => $schema,
        script_directory    => "$FindBin::Bin/../dbicdh",
        sql_translator_args => { add_drop_table => 0 },
        force_overwrite     => $force_overwrite,
    }
);

$dh->prepare_install;
$dh->install;


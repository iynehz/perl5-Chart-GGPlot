#!/usr/bin/env perl

use 5.014;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(economics);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $economics = economics();

my $p = ggplot(
    data    => $economics,
    mapping => aes( x => 'date', y => 'unemploy' )
)->geom_line();

if (defined $save_as) {
    $p->save($save_as);
} else {
    $p->show();
}


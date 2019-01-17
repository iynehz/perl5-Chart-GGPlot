#!/usr/bin/env perl

use 5.014;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(diamonds);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $diamonds = diamonds();

my $p = ggplot(
    data    => $diamonds,
    mapping => aes( x => 'carat' )
)->geom_histogram( binwidth => 0.01 );


if (defined $save_as) {
    $p->save($save_as);
} else {
    $p->show();
}


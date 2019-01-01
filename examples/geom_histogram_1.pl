#!perl

use 5.014;
use warnings;

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(diamonds);

my $diamonds = diamonds();

my $p = ggplot(
    data    => $diamonds,
    mapping => aes( x => 'carat' )
)->geom_histogram( binwidth => 0.01 );


$p->show();


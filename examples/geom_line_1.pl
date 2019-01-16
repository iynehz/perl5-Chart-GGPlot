#!perl

use 5.014;
use warnings;

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(economics);

my $economics = economics();

my $p = ggplot(
    data    => $economics,
    mapping => aes( x => 'date', y => 'unemploy' )
)->geom_line();

$p->show();


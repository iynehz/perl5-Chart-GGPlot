#!perl

use 5.014;
use warnings;

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mpg);

my $mpg = mpg();

my $p = ggplot(
    data    => $mpg,
    mapping => aes( x => 'class' )
)->geom_bar();

$p->show();


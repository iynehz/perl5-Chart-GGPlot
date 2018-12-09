#!perl

use 5.014;
use warnings;

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mtcars);

my $mtcars = mtcars();

my $p = ggplot(
    data    => $mtcars,
    mapping => aes( x => 'wt', y => 'mpg' )
)->geom_point();

$p->show();


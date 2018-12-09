#!perl

use 5.014;
use warnings;

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More;
use PDL::Primitive qw(random grandom);

my $df = Data::Frame::More->new(
    columns => [
        x => random(100),
        y => random(100),
        z1 => grandom(100),
        z2 => grandom(100)->abs,
    ],
);

my $p = ggplot(
    data    => $df,
    mapping => aes( x => 'x', y => 'y' )
)->geom_point( mapping => aes( color => 'z2' ) );

$p->show();


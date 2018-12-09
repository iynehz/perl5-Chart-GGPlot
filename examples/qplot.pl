#!perl

use 5.014;
use warnings;

use PDL::Primitive qw(grandom random);

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mtcars);


my $mtcars = mtcars();

my $p = qplot(
    x     => [ 0 .. 9 ],
    y     => grandom(10), 
    color => random(10),
    title => 'random numbers',
);

$p->show();


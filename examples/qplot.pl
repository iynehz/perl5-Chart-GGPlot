#!/usr/bin/env perl

use 5.014;
use warnings;

use Getopt::Long;
use PDL::Primitive qw(grandom random);

use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mtcars);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $mtcars = mtcars();

my $p = qplot(
    x     => [ 0 .. 9 ],
    y     => grandom(10), 
    color => random(10),
    title => 'random numbers',
);

if (defined $save_as) {
    $p->save($save_as);
} else {
    $p->show();
}


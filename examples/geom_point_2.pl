#!/usr/bin/env perl

use 5.014;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mtcars);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $mtcars = mtcars();

my $p = ggplot(
    data    => $mtcars,
    mapping => aes( x => 'wt', y => 'mpg' )
)->geom_point( mapping => aes( color => 'factor($cyl)' ) );

if (defined $save_as) {
    $p->save($save_as);
} else {
    $p->show();
}


#!/usr/bin/env perl

use 5.014;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Data::Frame::More::Examples qw(mpg);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $mpg = mpg();

my $p = ggplot(
    data    => $mpg,
    mapping => aes( x => 'class' )
)->geom_bar();

if (defined $save_as) {
    $p->save($save_as);
} else {
    $p->show();
}


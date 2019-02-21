#!/usr/bin/env perl

use 5.016;
use warnings;

use Getopt::Long;
use Chart::GGPlot qw(:all);
use Data::Frame::More::Examples qw(diamonds);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $p = ggplot(
    data    => diamonds(),
    mapping => aes( x => 'price', fill => 'cut' )
)->geom_histogram( position => 'dodge2' );

if ( defined $save_as ) {
    $p->save($save_as);
}
else {
    $p->show();
}


#!/usr/bin/env perl

use 5.016;
use warnings;

use Getopt::Long;
use Chart::GGPlot qw(:all);
use Data::Frame::More::Examples qw(mpg);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $mpg = mpg();

my $p = ggplot(
    data    => $mpg,
    mapping => aes( x => 'displ', y => 'hwy' )
)->geom_point()
 ->scale_x_continuous(name => "Engine displacement (L)")
 ->scale_y_continuous(name => "Highway MPG");

if ( defined $save_as ) {
    $p->save($save_as);
}
else {
    $p->show();
}


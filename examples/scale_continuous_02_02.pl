#!/usr/bin/env perl

use 5.016;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Chart::GGPlot::Util::Scales qw(dollar);
use PDL::Core qw(pdl);
use PDL::Primitive qw(random);
use Data::Frame::More;

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $df = Data::Frame::More->new(
    columns => [
        x => random(10) * 100000,
        y => pdl( [ 0 .. 9 ] ) / 9
    ]
);

my $p = ggplot(
    data    => $df,
    mapping => aes( x => 'x', y => 'y' )
)->geom_point()
 ->scale_y_continuous( labels => \&dollar );

if ( defined $save_as ) {
    $p->save($save_as);
}
else {
    $p->show();
}


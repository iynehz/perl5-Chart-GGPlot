#!perl

use Chart::GGPlot::Setup;

use List::AllUtils;
use Test2::V0;

use Chart::GGPlot::Geom::Functions qw(:all);
use Chart::GGPlot::Aes::Functions qw(:all);

subtest geom_histogram => sub {
    my $g = geom_histogram();
    is( $g->geom, 'Chart::GGPlot::Geom::Bar', 'geom' );
};

done_testing;

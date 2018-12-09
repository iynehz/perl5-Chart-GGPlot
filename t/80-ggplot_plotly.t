#!perl

use Chart::GGPlot::Setup qw(:base :pdl);

use Data::Frame::More;
use Data::Frame::More::Examples qw(mtcars);

use Test2::V0;
use Test2::Tools::DataFrame;
use Test2::Tools::PDL;

use Chart::GGPlot;
use Chart::GGPlot::Built;
use Chart::GGPlot::Aes::Functions qw(:ggplot);
use Chart::GGPlot::Util qw(:all);

#use Carp::Always;

my $mtcars = mtcars();

subtest geom_point_1 => sub {
    my $p = Chart::GGPlot->new(
        data    => $mtcars,
        mapping => aes( x => 'wt', y => 'mpg' )
    )->geom_point();

    isa_ok( $p, ['Chart::GGPlot'], 'Chart::GGPlot->new' );

    my $built = $p->backend->build($p);
    isa_ok( $built, [qw(Chart::GGPlot::Built)], '$plot->build' );

    my $data = $built->data;
    is( $data->length, 1 );

    my $data_expected = Data::Frame::More->new(
        columns => [
            x      => $mtcars->at('wt'),
            y      => $mtcars->at('mpg'),
            PANEL  => pdl(0)->repeat( $mtcars->nrow ),
            group  => pdl(0)->repeat( $mtcars->nrow ),
            alpha  => NA()->repeat( $mtcars->nrow ),
            color  => PDL::SV->new( ['black'] )->repeat( $mtcars->nrow ),
            fill   => NA()->repeat( $mtcars->nrow ),
            shape  => pdl(19)->repeat( $mtcars->nrow ),
            size   => pdl(1.5)->repeat( $mtcars->nrow ),
            stroke => pdl(0.5)->repeat( $mtcars->nrow ),
        ]
    );
    dataframe_is( $data->[0], $data_expected, '$built->data' );

    my $layout = $built->layout;
    dataframe_is(
        $layout->layout,
        Data::Frame::More->new(
            columns => [
                PANEL   => pdl( [0] ),
                ROW     => pdl( [0] ),
                COL     => pdl( [0] ),
                SCALE_X => pdl( [0] ),
                SCALE_Y => pdl( [0] ),
            ]
        ),
        '$built->layout->layout'
    );

    my $coord = $layout->coord;
    isa_ok( $coord, [qw(Chart::GGPlot::Coord::Cartesian)],
        '$built->layout->coord' );

    my $facet = $layout->facet;
    isa_ok( $facet, [qw(Chart::GGPlot::Facet::Null)], '$built->layout->facet' );

    my $scales   = $layout->get_scales(0);
    my $scales_x = $scales->{x};
    my $scales_y = $scales->{y};
    isa_ok( $scales_x, [qw(Chart::GGPlot::Scale::ContinuousPosition)],
        '$scales->{x}' );
    pdl_is(
        $scales_x->range->range,
        pdl( [ 1.513, 5.424 ] ),
        '$scale->{x}->range'
    );
    ok( $scales_x->limits->isempty, '$scale->{x}->limits' );
    isa_ok( $scales_y, [qw(Chart::GGPlot::Scale::ContinuousPosition)],
        '$scales->{y}' );
    pdl_is(
        $scales_y->range->range->pdl,
        pdl( [ 10.4, 33.9 ] ),
        '$scale->{y}->range'
    );
    ok( $scales_y->limits->isempty, '$scale->{y}->limits' );
};

subtest geom_point_2 => sub {
    my $p = Chart::GGPlot->new(
        data    => $mtcars,
        mapping => aes( x => 'wt', y => 'mpg' )
    )->geom_point( mapping => aes( color => 'factor($cyl)' ) );

    my $built = $p->backend->build($p);
    my $data  = $built->data;

    my $data_expected = Data::Frame::More->new(
        columns => [
            color => PDL::SV->new(
                $mtcars->at('cyl')->unpdl->map(
                    sub {
                        state $mapping =
                          { 6 => '#00b938', 4 => '#f7766c', 8 => '#609bff' };
                        $mapping->{$_};
                    }
                )
            ),
            x     => $mtcars->at('wt'),
            y     => $mtcars->at('mpg'),
            PANEL => pdl(0)->repeat( $mtcars->nrow ),
            group => pdl(
                $mtcars->at('cyl')->unpdl->map(
                    sub {
                        state $mapping = { 4 => 0, 6 => 1, 8 => 2 };
                        $mapping->{$_};
                    }
                )
            ),
            alpha  => NA()->repeat( $mtcars->nrow ),
            fill   => NA()->repeat( $mtcars->nrow ),
            shape  => pdl(19)->repeat( $mtcars->nrow ),
            size   => pdl(1.5)->repeat( $mtcars->nrow ),
            stroke => pdl(0.5)->repeat( $mtcars->nrow ),
        ]
    );
    dataframe_is( $data->[0], $data_expected, '$built->data' );

    is( $built->plot->labels,
        { x => 'wt', y => 'mpg', color => 'factor($cyl)' },
        '$built->plot->labels' );

    #    my $layout = $built->layout;
    #    dataframe_is(
    #        $layout->layout,
    #        Data::Frame::More->new(
    #            columns => [
    #                PANEL   => pdl( [0] ),
    #                ROW     => pdl( [0] ),
    #                COL     => pdl( [0] ),
    #                SCALE_X => pdl( [0] ),
    #                SCALE_Y => pdl( [0] ),
    #            ]
    #        ),
    #        '$built->layout->layout'
    #    );

#    my $coord = $layout->coord;
#    isa_ok( $coord, [qw(Chart::GGPlot::Coord::Cartesian)],
#        '$built->layout->coord' );
#
#    my $facet = $layout->facet;
#    isa_ok( $facet, [qw(Chart::GGPlot::Facet::Null)], '$built->layout->facet' );
#
#    my $scales = $layout->get_scales(0);
#    my $scales_x = $scales->{x};
#    my $scales_y = $scales->{y};
#    isa_ok($scales_x, [qw(Chart::GGPlot::Scale::ContinuousPosition)], '$scales->{x}');
#    pdl_is($scales_x->range->range, pdl([1.513, 5.424]), '$scale->{x}->range');
#    ok($scales_x->limits->isempty, '$scale->{x}->limits');
#    isa_ok($scales_y, [qw(Chart::GGPlot::Scale::ContinuousPosition)], '$scales->{y}');
#    pdl_is($scales_y->range->range->pdl, pdl([10.4, 33.9]), '$scale->{y}->range');
#    ok($scales_y->limits->isempty, '$scale->{y}->limits');
};

done_testing();

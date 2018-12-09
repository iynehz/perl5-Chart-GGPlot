#!perl

use Chart::GGPlot::Setup;

use List::AllUtils;
use Ref::Util qw(is_arrayref);

use Test2::V0;

use Chart::GGPlot::Aes;
use Chart::GGPlot::Aes::Functions qw(:all);

{
    my $aes = Chart::GGPlot::Aes->new( x => 'mpg', y => 'wt', color => 'cyl' );
    ok( $aes, 'Aes->new' );

    is( $aes->keys, [ sort(qw(color x y)) ], '$aes->keys' );
    is( $aes->names, $aes->keys, '$aes->names');

    ok( $aes->exists('x'),  '$aes->exists' );
    ok( !$aes->exists('z'), '$aes->exists' );

    is( $aes->at('y'), 'wt', '$aes->at' );
    $aes->set( 'y', 'disp' );
    is( $aes->at('y'), 'disp', '$aes->set' );

    ok(
        (
            List::AllUtils::all { $_ eq 'cyl' }
            ( map { $aes->at($_) } qw(color colour col) )
        ),
        "attribute aliasing"
    );

    my $all_aesthetics = $aes->all_aesthetics;
    ok( ( is_arrayref($all_aesthetics) and @$all_aesthetics > 10 ),
        '$aes->all_aesthetics' );
}

{
    my $aes = aes( x => 'mpg', y => 'wt', color => 'cyl' );
    is( $aes->as_hashref, { x => 'mpg', y => 'wt', color => 'cyl' }, 'aes()' );

    is(
        $aes->hslice( [qw(x color)] )->as_hashref,
        { x => 'mpg', color => 'cyl' },
        '$aes->hslice()'
    );

    is(
        $aes->rename( { color => 'fill' } )->as_hashref,
        { x => 'mpg', y => 'wt', fill => 'cyl' },
        '$aes->rename()'
    );

    is(
        $aes->merge( aes( fontsize => 20 ) )->as_hashref,
        { x => 'mpg', y => 'wt', color => 'cyl', fontsize => 20 },
        '$aes->merge()'
    );

    my $aes2 = aes( $aes->flatten );
    is( $aes2->as_hashref,
        { x => 'mpg', y => 'wt', color => 'cyl' }, '$aes->flatten' );

    my $aes_all = aes_all( "x", "y", "color" );
    is( $aes_all->as_hashref,
        { x => 'x', y => 'y', color => 'color' }, 'aes_all()' );

    ok( is_position_aes( [qw(x y)] ), 'is_position_aes()' );
    is( aes_to_scale( [qw(colour x xmin y ymax)] ),
        [qw(color x x y y)], 'aes_to_scale()' );
}

done_testing;

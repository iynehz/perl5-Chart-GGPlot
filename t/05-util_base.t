#!perl

use Chart::GGPlot::Setup qw(:base :pdl);

# Test2::V0 also has a function called "match".
use Chart::GGPlot::Util qw(:all !match);

use Test2::V0;
use Test2::Tools::PDL;

diag($INC{'Test2/Tools/PDL.pm'});

pdl_is( sign( pdl( -5, 0, 2, "inf", "-inf", "nan" )->setbadat(5) ),
    pdl([ -1, 0, 1, 1, -1, 'nan' ])->setnantobad, 'sign()' );
ok( !is_null( pdl( [] ) ), 'is_null(pdl([]))' );
ok( is_null(null), 'is_null(null)' );

pdl_is( is_finite( pdl( "inf", "-inf", 42, -7.0, 'nan' ) ),
    pdl([ 0, 0, 1, 1, 0 ]), 'is_finite' );
pdl_is(
    is_infinite( pdl( "inf", "-inf", 42, -7.0, 'nan' ) ),
    pdl([ 1, 1, 0, 0, 0 ]),
    'is_infinite()'
);

subtest seq => sub {
    pdl_is( seq_by( 1, 3, 0.5 ), pdl([ 1, 1.5, 2, 2.5, 3 ]), "seq_by()" );

    pdl_is( seq_n( 1, 3, 5 ), pdl([ 1, 1.5, 2, 2.5, 3 ]), "seq_n()" );
    pdl_is( seq_n( 3, 1, 5 ), pdl([ 3, 2.5, 2, 1.5, 1 ]), "seq_n()" );
    pdl_is( seq_n( 15, 15, 1 ), pdl([ 15 ]), "seq_n()" );
};

pdl_is( range_( pdl( 1 .. 4 ) ), pdl([ 1, 4 ]), 'range_()' );

subtest match => sub {
    pdl_is(
        Chart::GGPlot::Util::match( pdl( [ 1, 2, 3 ] ), pdl( [ 3, 1, 2 ] ) ),
        pdl([ 1, 2, 0 ]),
        'match()'
    );
    pdl_is(
        Chart::GGPlot::Util::match(
            PDL::SV->new( [qw(foo bar baz)] ),
            PDL::SV->new( [qw(baz foo bar)] )
        ),
        pdl([ 1, 2, 0 ]),
        'match()'
    );
};

done_testing();

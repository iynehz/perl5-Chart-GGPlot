#!perl

use Chart::GGPlot::Setup qw(:base :pdl);

use Graphics::Color::RGB;

use Chart::GGPlot::Util qw(:scales);
use Chart::GGPlot::Util::_Labeling qw(:all);

use Test2::V0;
use Test2::Tools::PDL;

ok( zero_range( pdl( [ 1, 1 ] ) ), 'zero_range()' );

subtest censor => sub {
    pdl_is(
        censor( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ) ),
        pdl( [ 'nan', 0, 0.5, 1, 'nan', 'nan' ] )->setnantobad,
        'censor() with default options'
    );

    pdl_is( censor( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ), pdl( [ 1, 2 ] ) ),
        pdl( [ 'nan', 'nan', 'nan', 1, 1.5, 2 ] )->setnantobad, 'censor()' );
};

subtest rescale => sub {
    pdl_is(
        rescale( pdl( [ 1 .. 5 ] ) ),
        pdl( [ 0, 0.25, 0.5, 0.75, 1.0 ] ),
        'rescale() to default "to"'
    );
    pdl_is( rescale( pdl( [ 1 .. 5 ] ), pdl( [ 1, 3 ] ) ),
        pdl( [ 1, 1.5, 2, 2.5, 3 ] ), 'rescale()' );
    pdl_is( rescale( pdl( [qw(2 2.5 3 3.5 4 4.5 5 5.5 6)] ) ),
        pdl( [ 0 .. 8 ] ) / 8, 'rescale()' );
};

subtest regular_minor_breaks => sub {
    my $func_minor_breaks_non_reverse = regular_minor_breaks();
    for my $case (
        {
            breaks   => pdl( [ 1, 3, 4 ] ),
            limits   => pdl( [ 1, 4 ] ),
            n        => 2,
            expected => pdl( [ 1, 2, 3, 3.5, 4 ] )
        },
        {
            breaks   => pdl( [ 1, 3, 4 ] ),
            limits   => pdl( [ 0, 4.5 ] ),
            n        => 2,
            expected => pdl( [ 0, 1, 2, 3, 3.5, 4 ] )
        },
      )
    {
        pdl_is(
            $func_minor_breaks_non_reverse->(
                $case->{breaks}, $case->{limits}, $case->{n}
            ),
            $case->{expected},
            "regular_minor_breaks(false)"
        );
    }

    my $func_minor_breaks_reverse = regular_minor_breaks(true);
    for my $case (
        {
            breaks   => pdl( [ 4, 3, 1 ] ),
            limits   => pdl( [ 1, 4 ] ),
            n        => 2,
            expected => pdl( [ 4, 3.5, 3, 2, 1 ] )
        },
        {
            breaks   => pdl( [ 4,   3, 1 ] ),
            limits   => pdl( [ 0,   4.5 ] ),
            n        => 2,
            expected => pdl( [ 4.5, 4, 3.5, 3, 2, 1, 0.5, 0 ] )
        },
      )
    {
        pdl_is(
            $func_minor_breaks_reverse->(
                $case->{breaks}, $case->{limits}, $case->{n}
            ),
            $case->{expected},
            "regular_minor_breaks(true)"
        );
    }
};

subtest squish => sub {
    pdl_is(
        squish( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ) ),
        pdl( [ 0, 0, 0.5, 1, 1, 1 ] ),
        'squish() with default options'
    );
    pdl_is(
        squish( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ), pdl( [ 1, 2 ] ) ),
        pdl( [ 1, 1, 1, 1, 1.5, 2 ] ),
        'squish() with default options'
    );
};

subtest discard => sub {
    pdl_is(
        discard( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ) ),
        pdl( [ 0, 0.5, 1 ] ),
        'discard() with default options'
    );
    pdl_is(
        discard( pdl( [ -0.5, 0, 0.5, 1, 1.5, 2 ] ), pdl( [ 1, 2 ] ) ),
        pdl( [ 1, 1.5, 2 ] ),
        'discard() with non-default options'
    );
};

pdl_is(
    expand_range( pdl( [ 0, 1 ] ), 1, 2 ),
    pdl( [ 0 - 3, 1 + 3 ] ),
    'expand_range()'
);

subtest alpha => sub {
    skip_all "revisit this once we find we need alpha()";

    is(
        alpha("red")->map( sub { $_->as_hex_string } ),
        [ Graphics::Color::RGB->from_color_library("red") ]
        ->map( sub { $_->as_hex_string } ),
        "alpha"
    );
    is(
        alpha( [ "red", "blue" ] )->map( sub { $_->as_hex_string } ),
        [
            Graphics::Color::RGB->from_color_library("red"),
            Graphics::Color::RGB->from_color_library("blue")
        ]->map( sub { $_->as_hex_string } ),
        "alpha"
    );
    is(
        alpha( "red", [ 0.1, 0.2 ] )->map( sub { $_->as_hex_string } ),
        [
            Graphics::Color::RGB->new( r => 1, g => 0, b => 0, a => 0.1 ),
            Graphics::Color::RGB->new( r => 1, g => 0, b => 0, a => 0.2 )
        ]->map( sub { $_->as_hex_string } ),
        "alpha"
    );
};

subtest hue_pal => sub {
    no warnings 'qw';

    pdl_is( hue_pal()->(4),
        PDL::SV->new( [qw(#f7766c #7bae00 #00bfc4 #c77cff)] ), 'hue_pal()' );
    pdl_is(
        hue_pal( l => 90 )->(9),
        PDL::SV->new(
            [
                qw(#ffbbb3 #ffd64c #d6ef16 #54ff8a #00ffe4
                  #00fdff #b0e0ff #ffbcff #ffadff)
            ]
        ),
        'hue_pal()'
    );
    pdl_is(
        hue_pal( h => [ 0, 90 ] )->(9),
        PDL::SV->new(
            [
                qw(#ff6c90 #fa7376 #f27b57 #e9832d #de8b00
                  #d19300 #c29a00 #b1a000 #9da600)
            ]
        ),
        'hue_pal()'
    );
};

# Util::_Labeling

# this is from in R `labeling` package's doc
pdl_is(
    labeling_extended( 8.1, 14.1, 4 ),
    pdl( [ 8, 10, 12, 14 ] ),
    'labeling_extended()'
);

done_testing();

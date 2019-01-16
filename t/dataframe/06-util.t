#!perl

use Data::Frame::More::Setup;

use PDL::Core qw(pdl null);
use PDL::SV ();
use PDL::Factor ();

use Test2::V0;
use Test2::Tools::PDL;

use Data::Frame::More::Util qw(:all);

subtest ifelse => sub {
    my $x = pdl( 0 .. 5 );

    pdl_is( ifelse( $x > 3.14, pdl( (0) x 6 ), $x ),
        pdl( 0 .. 3, 0, 0 ), 'ifelse()' );

    pdl_is( ifelse( $x > 3.14, 0, $x ), pdl( 0 .. 3, 0, 0 ), 'ifelse()' );
    pdl_is( ifelse( $x >= 0, 0, $x ), pdl( (0) x 6 ), 'ifelse()' );
    pdl_is( ifelse( $x < 0, 0, $x ), $x, 'ifelse()' );
    pdl_is(
        ifelse( 1, 1, 2 ),
        pdl( [1] ),
        'ifelse() always returns a dimensioned piddle'
    );
};

subtest is_discrete => sub {
    ok( is_discrete( PDL::Factor->new( [qw(foo bar)] ) ),
        'is_discrete($pdlfactor)' );
    ok( is_discrete( PDL::SV->new( [qw(foo bar)] ) ), 'is_discrete($pdlsv)' );
    ok( !is_discrete( PDL->new([1 .. 10]) ), 'not is_discrete($aref)' );
};

subtest factor => sub {
    my $x = pdl( [qw(6 6 4 6 8 6 8 4 4 6)]); # first 10 from $mtcars->at('cyl')
    my $f = factor($x);
    is($f->levels, [qw(4 6 8)], 'levels');
    is($f->unpdl, [qw(1 1 0 1 2 1 2 0 0 1)], 'unpdl');
};

done_testing;

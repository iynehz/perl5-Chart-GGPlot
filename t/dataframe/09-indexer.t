#!perl

use Data::Frame::More::Setup;

use PDL::Core qw(pdl);
use Test2::V0;

use Data::Frame::More::Indexer qw(:all);

subtest loc => sub {
    is( loc(),      undef, 'loc()' );
    is( loc(undef), undef, 'loc(undef)' );
    is( loc( pdl( [ 1, 2 ] ) )->indexer, [ 1, 2 ], 'loc($pdl)' );

    my $indexer = loc( [qw(x y)] );
    isa_ok( $indexer, ['Data::Frame::More::Indexer::ByLabel'] );
    is( $indexer->indexer, [qw(x y)], 'loc([qw(x y)])' );
    is( iloc($indexer), $indexer, 'iloc($indexer)' );
};

subtest iloc => sub {
    is( iloc(),      undef, 'iloc()' );
    is( iloc(undef), undef, 'iloc(undef)' );

    my $indexer = iloc( [ 1, 2 ] );
    isa_ok( $indexer, ['Data::Frame::More::Indexer::ByIndex'] );
    is( $indexer->indexer, [ 1, 2 ], 'loc([1, 2])' );

    is( loc($indexer), $indexer, 'loc($indexer)' );
};

done_testing;

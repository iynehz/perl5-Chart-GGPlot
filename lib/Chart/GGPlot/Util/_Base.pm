package Chart::GGPlot::Util::_Base;

# ABSTRACT: R 'base' package functions used by Chart::GGPlot

use Chart::GGPlot::Setup qw(:base :pdl);

use Types::PDL qw(Piddle);
use Data::Frame::More::Util qw(:all);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = (
    qw(
      NA BAD
      is_finite is_infinite is_na is_null sign
      range_ seq_n seq_by
      match
      ), @Data::Frame::More::Util::EXPORT_OK
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# Range of Values
fun range_ ( $p, $na_rm = false, $finite = false ) {
    if ( !$finite and $na_rm ) {
        if ( $p->nbad ) {
            return pdl( [ 'nan', 'nan' ] )->setnantobad;
        }
    }
    my $p1 = $finite ? $p->index( which( $p->isfinite ) ) : $p;
    return pdl( [ $p1->min, $p1->max ] );
}

# the R seq function is implemented by seq_n and seq_by here,
# so we avoid a single function with named parameters.
fun seq_by ( $from, $to, $by = ( $from >= $to ? 1 : -1 ) ) {
    return ( PDL->sequence( ( $to - $from ) / $by + 1 ) * $by + $from );
}

fun seq_n ( $from, $to, $n ) {
    return pdl( [$from] ) if ( $n == 1 );

    my $by = ( $to - $from ) / ( $n - 1 );
    return seq_by( $from, $to, $by );
}

fun is_na ($p) { $p->isbad; }
fun is_finite ($p) { $p->isfinite; }

fun is_infinite ($p) {
    return ( ( $p == 0 + 'inf' ) | ( $p == 0 + '-inf' ) );
}

fun is_null ($p) {
    if ( $p->$_can('isnull') ) {
        return $p->isnull;
    }
    if ( $p->$_can('isempty') ) {
        return $p->isempty;
    }
    if ( $p->$_can('length') ) {
        return $p->length == 0;
    }
    return 1;
}

fun sign ($p) { $p <=> 0; }

# Set operations on two arrayrefs.

use PDL::Ufunc qw(qsorti);
use PDL::Primitive qw(which vsearch_match);

fun match (Piddle $a, Piddle $b) {
    my $is_discrete =
      List::AllUtils::any { $_->$_DOES('PDL::SV') or $_->type eq 'byte' }
    ( $a, $b );

    if ($is_discrete) {
        my %b_hash = map { $b->at($_) => $_ } reverse( 0 .. $b->length - 1 );
        my $rslt = [ $a->flatten ]->map( sub { $b_hash{$_} // -1; } );
        return pdl($rslt)->setvaltobad(-1);
    }
    else {
        my $sorted_idx = $b->qsorti;
        my $sorted     = $b->slice($sorted_idx);
        my $match      = $a->vsearch_match($sorted);
        my $rslt       = [ 0 .. $a->length - 1 ]->map(
            sub {
                my $idx = $match->at($_);
                $idx < 0 ? -1 : $sorted_idx->at($idx);
            }
        );
        return pdl($rslt)->setvaltobad(-1);
    }
}

1;

__END__

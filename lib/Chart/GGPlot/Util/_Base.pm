package Chart::GGPlot::Util::_Base;

# ABSTRACT: R 'base' package functions used by Chart::GGPlot

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Data::Frame::Util qw(:all);
use PDL::Ufunc qw(qsorti);
use PDL::Primitive qw(vsearch_match);
use Types::PDL qw(Piddle);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = (
    qw(
      NA BAD
      is_finite is_infinite is_na is_null sign
      range_ seq_n seq_by
      match
      pmax pmin
      ), @Data::Frame::Util::EXPORT_OK
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# Range of Values
fun range_ (Piddle $p, $na_rm = false, $finite = false) {
    if ( !$finite and $na_rm ) {
        if ( $p->nbad ) {
            return pdl( [ 'nan', 'nan' ] )->setnantobad;
        }
    }
    my $p = $finite ? $p->where( $p->isfinite ) : $p;
    my $class = ref($p);
    return $class->new( [ $p->minmax ] );
}

# the R seq function is implemented by seq_n and seq_by here,
# so we avoid a single function with named parameters.
fun seq_by ( $from, $to, $by = ( $from >= $to ? 1 : -1 ) ) {
    return ( PDL->sequence( ( $to - $from ) / $by + 1 ) * $by + $from );
}

fun seq_n ( $from, $to, $n ) {
    return pdl( [$from] ) if ( $n == 1 );

    my $by = ( $to - $from ) / ( $n - 1 );
    my $s = seq_by( $from, $to, $by );
    $s->set(-1, $to);   # avoid float epsilon issues
    return $s;
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

=func match

    match(Piddle $a, $Piddle $b)

Returns a vector of the positions of (first) matches of its first argument
in its second.

=cut

fun match (Piddle $a, Piddle $b) {
    my $is_string =
      List::AllUtils::any { $_->$_DOES('PDL::SV') or $_->type eq 'byte' }
    ( $a, $b );

    if ($is_string) {
        $a = $a->as_pdlsv;
        $b = $b->as_pdlsv;
        my %b_hash = map { $b->at($_) => $_ } reverse( 0 .. $b->length - 1 );
        my $rslt   = [ $a->flatten ]->map( sub { $b_hash{$_} // -1; } );
        return pdl($rslt)->setvaltobad(-1);
    }
    else {
        if ( $b->$_DOES('PDL::Factor') ) {
            return $a->{PDL};
        }
        else {
            my $sorted_idx = $b->qsorti;
            my $sorted     = $b->slice($sorted_idx);
            $sorted = $sorted->where( $sorted->isgood ) if $sorted->badflag;
            my $match = $a->vsearch_match($sorted);
            my $idx   = $match->slice( pdl( [ 0 .. $a->length - 1 ] ) );
            $idx = $idx->setbadif($idx < 0) if $idx->badflag;
            return $sorted_idx->slice($idx);
        }
    }
}

fun pmax ($a, $b) { ifelse($a > $b, $a, $b); }
fun pmin ($a, $b) { ifelse($a < $b, $a, $b); }

1;

__END__

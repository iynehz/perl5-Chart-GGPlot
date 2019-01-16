package Data::Frame::More::Util;

# ABSTRACT: Utility functions

use Data::Frame::More::Setup;

# VERSION

use Type::Params;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  BAD NA
  ifelse is_discrete
  factor
  guess_and_convert_to_pdl
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

use PDL::Core qw(pdl);
use PDL::Factor;
use PDL::Primitive qw(which);
use PDL::SV;

use Data::Munge qw(elem);
use List::AllUtils;
use Scalar::Util qw(looks_like_number);
use Types::PDL qw(Piddle Piddle1D PiddleFromAny);
use Types::Standard qw(ArrayRef Value);

fun BAD($n=1) {
    pdl(('nan') x $n)->setnantobad;
}
*NA = \&BAD;

fun ifelse ($test, $yes, $no) {
    state $check = Type::Params::compile(
        ( Piddle->plus_coercions(PiddleFromAny) ),
        ( ( Piddle->plus_coercions(PiddleFromAny) ) x 2 )
    );
    ( $test, $yes, $no ) = $check->( $test, $yes, $no );

    my $l   = $test->length;
    my $idx = which( !$test );

    $yes = $yes->repeat_to_length($l);
    if ( $idx->length == 0 ) {
        return $yes;
    }

    $no = $no->repeat_to_length($l);
    $yes->slice($idx) .= $no->slice($idx);

    return $yes;
}

=func is_discrete

    my $bool = is_discrete(Piddle $x);

Returns true if C<$x> is discrete, that is, an object of below types,

=for :list
* PDL::Factor
* PDL::SV

=cut

fun is_discrete (Piddle $x) {
    return (
             $x->$_DOES('PDL::Factor')
          or $x->$_DOES('PDL::SV')
          or $x->type eq 'byte'
    );
}

=func factor

Convert a thing to a L<PDL::Factor> object.

    my $f = factor($x);

=cut

fun factor ($x) {
    return $x if ( $x->$_DOES('PDL::Factor') );

    # TODO get this logic into PDL::Factor::new
    if ( $x->$_DOES('PDL') ) {
        if ( $x->$_DOES('PDL::SV') ) {
            return PDL::Factor->new( $x->unpdl );
        }
        else {
            my $integer = PDL::Core::zeros( $x->length );
            my $uniq    = $x->uniq->qsort;
            for my $i ( 0 .. $uniq->length - 1 ) {
                $integer->slice( which( $x == $uniq->at($i) ) ) .= $i;
            }
            return PDL::Factor->new(
                levels  => $uniq->unpdl,
                integer => $integer->unpdl
            );
        }
    }
    else {
        return PDL::Factor->new($x);
    }
}

fun guess_and_convert_to_pdl ( (ArrayRef | Value | Piddle) $x,
        :$strings_as_factors=false, :$test_count=1000, :$na=[qw(BAD NA)]) {
    return $x if ( $x->$_DOES('PDL') );

    my $like_number;
    if ( !ref $x ) {
        $like_number = looks_like_number($x);
        $x           = [$x];
    }
    else {
        $like_number = List::AllUtils::all {
            my $x = $_;
            looks_like_number($x)
              or length($x) == 0
              or (
                # should be somewhat faster than elem()
                List::AllUtils::any { $x eq $_ } @$na
              )
        }
        @$x[ 0 .. List::AllUtils::min( $test_count - 1, $#$x ) ];
    }

    my $is_na = sub { length( $_[0] ) == 0 or elem( $_[0], $na ); };

    if ($like_number) {
        my @data = map { &$is_na($_) ? 'nan' : $_ } @$x;
        my $piddle = pdl( \@data );
        $piddle->inplace->setnantobad;
        return $piddle;
    }
    else {
        my $piddle =
          $strings_as_factors
          ? PDL::Factor->new($x)
          : PDL::SV->new($x);
        my @is_bad = List::AllUtils::indexes { &$is_na($_) } @$x;
        if (@is_bad) {
            $piddle = $piddle->setbadif( pdl( \@is_bad ) );
        }
        return $piddle;
    }
}

1;

__END__

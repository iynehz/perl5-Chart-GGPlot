package Chart::GGPlot::Util::_Scales;

# ABSTRACT: R 'scales' package functions used by Chart::GGPlot

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Color::Brewer;
use Convert::Color::LCh;
use Graphics::Color::RGB;
use Machine::Epsilon qw(machine_epsilon);
use Math::Gradient qw(multi_array_gradient);
use Math::Interpolate;
use Scalar::Util qw(looks_like_number);

use PDL::Primitive qw(which);

use Type::Params;
use Types::PDL qw(Piddle Piddle1D PiddleFromAny);
use Types::Standard qw(ArrayRef Num Optional Str);

use Chart::GGPlot::Types qw(:all);

use Chart::GGPlot::Util::_Base qw(:all);
use Chart::GGPlot::Util::_Labeling qw(:all);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  alpha
  censor discard expand_range zero_range
  rescale squish
  hue_pal brewer_pal gradient_n_pal rescale_pal
  seq_gradient_pal div_gradient_pal
  area_pal
  identity_pal
  extended_breaks regular_minor_breaks
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

## color

fun alpha($color, $alpha=[]) {
    my $color_length = $color->length;
    my $alpha_length = $alpha->length;

    if ( $color_length != $alpha_length ) {
        if ( $color_length > 1 and $alpha_length > 1 ) {
            croak("Only one of colour and alpha can be vectorised");
        }
        if ( $color_length > 1 ) {
            $alpha = [ ( $alpha->at(0) ) x $color_length ];
        }
        elsif ( $alpha->length > 1 ) {
            $color = [ ( $color->at(0) ) x $alpha_length ];
        }
    }

    my @new_color = List::AllUtils::pairwise {
        my ( $col, $alpha ) = ( $a, $b );

        Graphics::Color::RGB->new(
            r => $col->r,
            g => $col->g,
            b => $col->b,
            a => ( $alpha // $col->a )
        );
    }
    @$color, @$alpha;
    return \@new_color;
}

## range

=func censor

    censor($p, $range=pdl([0,1]), $only_finite=true)

Censor any values outside of range.

=cut

fun censor ( $p, $range = pdl([ 0, 1 ]), $only_finite = true ) {
    my ( $min, $max ) = $range->minmax;
    my $finite = $only_finite ? $p->isfinite : PDL->ones( $p->length );
    return $p->setbadif( $finite & ( ( $p < $min ) | ( $p > $max ) ) );
}

=func discard

    discar($p, $range=pdl([0,1]))

Discard any values outside of range.

=cut

fun discard ( $p, $range = pdl([ 0, 1 ]) ) {
    my ( $min, $max ) = $range->minmax;
    return $p->index( which( ( $p >= $min ) & ( $p <= $max ) ) );
}

# Expand a range with a multiplicative or additive constant
fun expand_range ( $range, $mul = 0, $add = 0, $zero_width = 1 ) {
    return if ( $range->isempty );  # TODO: return undef or return empty $range?

    my ( $min, $max ) = $range->minmax;
    if ( zero_range($range) ) {
        return pdl( [ $max - $zero_width / 2, $min + $zero_width / 2 ] );
    }
    else {
        my $delta = ( $max - $min ) * $mul + $add;
        return pdl( [ $min - $delta, $max + $delta ] );
    }
}

=func zero_range

    zero_range($range, $tol=1000*machine_epsilon)

Determine if range is close to zero, with a specified tolerance.

=cut

fun zero_range ( $range, $tol = 1000 * machine_epsilon() ) {
    state $check =
      Type::Params::compile( Piddle1D->where( sub { $_->length == 2 } ) );
    ($range) = $check->($range);
    return ( abs( $range->at(1) - $range->at(0) ) < $tol );
}

=func squish
    
    squish($p, $range=pdl([0,1]), $only_finite=true)

Squish values into range.

=cut

fun squish ( $p, $range = pdl([ 0, 1 ]), $only_finite = true ) {
    my ( $min, $max ) = $range->minmax;
    my $finite = $only_finite ? $p->isfinite : PDL->ones( $p->length );
    my $r = $p->copy;

    ( $r->slice( which( $finite & ( $r < $min ) ) ) ) .= $min;
    ( $r->slice( which( $finite & ( $r > $max ) ) ) ) .= $max;
    return $r;
}

## scale

# Rescale range to have specified minimum and maximum
fun rescale ( $p, $to = pdl([0, 1]), $from = range_($p) ) {
    my $from_diff = $from->at(1) - $from->at(0);
    my $to_diff = $to->at(1) - $to->at(0);
    if ($from_diff == 0) {
        return pdl([($to->at(0) + $to_diff/2) x $p->length]);
    }
    my $slope = $to_diff / $from_diff;
    return ( $p - $from->at(0) ) * $slope + $to->at(0);
}

## palette

my %brewer = (
    div => [
        "BrBG",   "PiYG",   "PRGn", "PuOr", "RdBu", "RdGy",
        "RdYlBu", "RdYlGn", "Spectral"
    ],
    qual => [
        "Accent",  "Dark2", "Paired", "Pastel1",
        "Pastel2", "Set1",  "Set2",   "Set3"
    ],
    seq => [
        "Blues",   "BuGn", "BuPu", "GnBu",   "Greens", "Greys",
        "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd",   "Purples",
        "RdPu",    "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd"
    ],
);

my %pal_names = map { $_ => 1 } map { @$_ } values %brewer;

fun _pal_name ( $palette, $type ) {
    if ( !looks_like_number($palette) ) {
        return exists( $pal_names{$palette} ) ? $palette : 'Greens';
    }
    return $brewer{$type}[$palette];
}

=func hue_pal

    hue_pal($h=pdl([0, 360]), $c=100, $l=65, $h_start=0, $direction=1)

=cut

fun hcl ($h, $c, $l) {
    my $c = Convert::Color::LCh->new( $l, $c, $h );
    my ( $r, $g, $b ) = map { $_ > 1 ? 1 : $_ < 0 ? 0 : $_ } $c->rgb;
    return Graphics::Color::RGB->new( red => $r, green => $g, blue => $b );
}

fun hue_pal (:$h=pdl([0, 360])+15, :$c=100, :$l=65, :$h_start=0, :$direction=1) {
    my $check =
      Type::Params::compile( Piddle1D->where( sub { $_->length == 2 } )
          ->plus_coercions(PiddleFromAny) );
    ($h) = $check->($h);

    return fun($n) {
        if ( $n == 0 ) {
            die "Must request at least one color from a hue palette.";
        }

        my $h_tmp = $h->copy;
        if ( ( $h_tmp->at(1) - $h_tmp->at(0) ) % 360 < 1 ) {
            $h_tmp = pdl( [ $h_tmp->at(0), $h_tmp->at(1) - 360 / $n ] );
        }
        my $rotate = sub { ( ( $_[0] + $h_start ) % 360 ) * $direction };
        my $hues = $rotate->( pdl( seq_n( $h_tmp->list, $n ) ) );
        return PDL::SV->new(
            $hues->unpdl->map( sub { hcl( $_, $c, $l )->as_css_hex; } ) );
    };
}

fun brewer_pal ( $type, $palette = 0, $direction = 1 ) {
    my $pal_name = _pal_name( $palette, $type );

    # $n is number of colors
    return fun($n) {
        my @colors = Color::Brewer::named_color_scheme(
            number_of_data_classes => List::AllUtils::max( $n, 3 ),
            name                   => $pal_name
        );

        # convert to Graphics::Color object
        @colors = map {
            my ( $r, $g, $b ) =
              map { $_ / 0xff; } ( $_ =~ /^rgb\((\d+),(\d+),(\d+)\)/ );
            Graphics::Color::RGB->new( red => $r, green => $g, blue => $b );
        } @colors[ 0 .. $n - 1 ];

        if ( $direction == -1 ) {
            @colors = reverse @colors;
        }
        return PDL::SV->new( @colors->map( sub { $_->as_css_hex } ) );
    };
}

sub to_color_rgb {
    my ($x) = @_;
    return (
        $x =~ /^\#?[[:xdigit:]]+$/
        ? Graphics::Color::RGB->from_hex_string($x)
        : Graphics::Color::RGB->from_color_library($x)
    );
}

# Color interpolation. map interval [0,1] to a set of colors
fun _color_ramp ($colors) {
    if ( $colors->isempty ) {
        die("Must provide at least one color to create a color ramp");
    }

    my @hot_spots = map {
        my $c = to_color_rgb($_);
        [ map { my $x = $_ * 255; $x > 255 ? 255 : $x < 0 ? 0 : $x; }
              $c->as_array ];
    } ( $colors->flatten );
    my @gradient =
      map {
        my $c = Graphics::Color::RGB->new(
            r => $_->[0] / 255,
            g => $_->[1] / 255,
            b => $_->[2] / 255
        );
        $c->as_css_hex;
      } multi_array_gradient( 10, @hot_spots );

    return fun( Piddle $p) {
        my @rslt = map {
            my $i = int( $_ * scalar(@gradient) );
            $gradient[$i];
        } $p->flatten;
        return PDL::SV->new( \@rslt );
    };
}

# Arbitrary colour gradient palette (continous).
fun gradient_n_pal ( $colors, $values = PDL->null ) {
    my $ramp = _color_ramp($colors);

    my $length = $values->length;
    my $xs = $length ? seq_n( 0, 1, $length ) : undef;

    return fun($p) {
        return PDL->null if ( $p->isempty );

        if ($xs) {
            my $p_adjusted = pdl(
                map {
                    Math::Interpolate::robust_interpolate( $_, $values, \$xs )
                } @{ $p->unpdl }
            );
            return $ramp->($p_adjusted);
        }
        else {
            return $ramp->($p);
        }
    };
}

fun seq_gradient_pal ($low, $high) {
    return gradient_n_pal( [ $low, $high ] );
}

fun div_gradient_pal ($low, $mid, $high) {
    return gradient_n_pal( [ $low, $mid, $high ] );
}

# Rescale palette (continuous).
fun rescale_pal ( $range = PDL->new( [ 0.1, 1 ] ) ) {
    return fun($p) {
        rescale( $p, $range, PDL->new( [ 0, 1 ] ) );
    };
}

fun area_pal ($range) {
    state $check =
      Type::Params::compile( Piddle1D->plus_coercions(PiddleFromAny) );
    ($range) = $check->($range);

    return fun($x) { return rescale( $x->sqrt, $range, pdl( [ 0, 1 ] ) ); };
}

fun identity_pal() {
    return fun($x) { $x };
}

## trans

fun extended_breaks ( $n = 5, @rest ) {
    return fun($p) {
        my $p1 = $p->slice( which( $p->isfinite ) );
        return null if ( $p1->isempty );

        my $range = range_($p1);
        return labeling_extended( $range->at(0), $range->at(1), $n, @rest );
    };
}

# Minor breaks. Places minor breaks between major breaks.
fun regular_minor_breaks ( $reverse = false ) {

    # $n : To create $n - 1 minor breaks between two major breaks
    return fun( $b, $limits, $n ) {
        my $b1 = $b->index( which( !is_na($b) ) );

        return PDL->null if ( $b1->length < 2 );

        my ( $min_b,     $max_b )     = ( $b1->min,     $b1->max );
        my ( $min_limit, $max_limit ) = ( $limits->min, $limits->max );

        my @b  = @{ $b1->unpdl };
        my $bd = $b[1] - $b[0];
        if ( !$reverse ) {
            if ( $min_limit < $min_b ) { unshift @b, ( $b[0] - $bd ); }
            if ( $max_limit > $max_b ) { push @b, ( $b[-1] + $bd ); }
        }
        else {
            if ( $max_limit > $max_b ) { unshift @b, ( $b[0] - $bd ); }
            if ( $min_limit < $min_b ) { push @b, ( $b[-1] + $bd ); }
        }

        my $seq_between = fun( $a, $b ) {
            my $rslt = seq_n( $a, $b, $n + 1 )->unpdl;
            pop @$rslt;
            return $rslt;
        };

        my @breaks =
          map { @{ $seq_between->( $b[$_], $b[ $_ + 1 ] ) } } ( 0 .. $#b - 1 );
        return discard( PDL->new( [ @breaks, $b[-1] ] ), $limits );
    }
}

1;

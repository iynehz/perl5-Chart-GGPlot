package Chart::GGPlot::Backend::Plotly::Util;

# ABSTRACT:

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Data::Munge qw(elem);
use Graphics::Color::RGB;
use List::AllUtils qw(pairmap reduce);
use PDL::Primitive qw(which);
use Types::PDL qw(Piddle);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  pt_to_px
  cex_to_px
  br
  to_rgb
  group_to_NA
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my $dpi = 96;

fun pt_to_px ($x) { $x / 72 * $dpi }

# This is approximately similar to the size in ggplot2.
# Default R fontsize is 12pt. And R scales many symbols by 0.75.
# 0.3 is a magic number from my guess.
fun cex_to_px ($x) { pt_to_px( 12 * $x * 0.75 * 0.3) }

sub br { '<br />' }

# plotly does not understands some non-rgb colors like "grey35"
fun to_rgb(Piddle $x) {
    my $rgb = sub {
        my ($color) = @_;
        
        if ($color =~ /^\#/) {
            return $color;
        } else {
            try {
                my $c = Graphics::Color::RGB->from_color_library($color);
                return $c->as_css_hex;
            } catch {
                return $color;
            }
        }
    };

    my $p = PDL::SV->new($x->unpdl->map($rgb));
    if ($x->badflag) {
        $p = $p->setbadif($x->isbad);
    }
    return $p
}

=func group_to_NA

    my $df1 = group_to_NA($df, $group_vars=['group'],
                          :$nested=[], :$ordered=[], :$retrace=false);

If a group of scatter traces share the same non-positional characteristics
(i.e., color, fill, etc), it is more efficient to draw them as a single
trace with missing values that separate the groups (instead of multiple
traces) In this case, one should also take care to make sure
L<https://plot.ly/r/reference/#scatter-connectgaps}{connectgaps}|connectgaps>
is set to false.

=cut

fun group_to_NA ($df, $group_vars=['group'],
                 :$nested=[], :$ordered=[], :$retrace=false) {
    return $df if ( $df->nrow == 0 );

    my $df_names = $df->names;
    $group_vars = $group_vars->intersect($df_names);
    $nested     = $nested->intersect($df_names);
    $ordered    = $ordered->intersect($df_names);

    # if group does not exist, just order the rows and exit
    unless ( $group_vars->length ) {
        my @key_vars = ( @$nested, @$ordered );
        return ( @key_vars ? $df->sort( \@key_vars ) : $df );
    }

    # ordered the rows
    $df = $df->sort( [ @$nested, @$group_vars, @$ordered ] );

    #inserting NAs to ensure each "group"
    my @key_vars = ( @$nested, @$group_vars );
    my $id       = $df->select_columns( \@key_vars )->id;

    # indices for where a new group starts
    my $idx           = which( $id->diff != 0 ) + 1;
    my @group_indices =
      ( 0, ( map { $_ - 1, $_ } $idx->flatten ), $df->nrow - 1 );

    my @splitted =
      pairmap { $df->select_rows( pdl( [ $a .. $b ] ) ) } @group_indices;
    return $df if @splitted == 1;

    return (reduce {
        my $x = $a;
        if ($retrace) {
            $x = $x->append( $x->select_rows( [0] ) );
        }
        my $na = $x->select_rows( [ $x->nrow - 1 ] )->copy;
        for
          my $name ( grep { !elem( $_, \@key_vars ) } $na->names->flatten )
        {
            $na->at($name)->setbadat(0);
        }
        $x->append($na)->append($b);
    } (shift @splitted), @splitted);
}

1;

__END__

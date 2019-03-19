package Chart::GGPlot::Backend::Plotly::Util;

# ABSTRACT: Utilities used by Chart::GGPlot::Backend::Plotly

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Data::Munge qw(elem);
use Graphics::Color::RGB;
use List::AllUtils qw(pairmap reduce);
use PDL::Primitive qw(which);
use Types::PDL qw(Piddle);
use Types::Standard qw(Str);

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
fun cex_to_px ($x) { pt_to_px( 12 * $x * 0.75 * 0.3 ) }

sub br { '<br />' }

# plotly does not understands some non-rgb colors like "grey35"
fun to_rgb ($x) {
    state $check = Type::Params::compile((Piddle | Str));
    ($x) = $check->($x);

    my $rgb = sub {
        my ($color) = @_;

        if ( $color =~ /^\#/ ) {
            return $color;
        }
        else {
            try {
                my $c = Graphics::Color::RGB->from_color_library($color);
                return $c->as_css_hex;
            }
            catch {
                return $color;
            }
        }
    };

    if ( !ref($x) ) {
        return $rgb->($x);
    }
    else {
        my $p = PDL::SV->new( $x->unpdl->map($rgb) );
        $p = $p->setbadif( $x->isbad ) if $x->badflag;
        return $p;
    }
}

=func group_to_NA

    group_to_NA($df, :$group_vars=['group'],
                :$nested=[], :$ordered=[], :$retrace_first=false)

If a group of scatter traces share the same non-positional characteristics
(i.e., color, fill, etc), it is more efficient to draw them as a single
trace with missing values that separate the groups (instead of multiple
traces) In this case, one should also take care to make sure
L<connectgaps|https://plot.ly/r/reference/#scatter-connectgaps>
is set to false.

Returns a data frame with rows ordered by C<$nested> then C<$group_vars>
then C<$ordered>. As long as C<$group_vars> contains valid variable names,
new rows will be inserted to separate the groups, at places where group
changes in each chunk of same C<$nested> values.

=cut

fun group_to_NA ($df, :$group_vars=['group'],
                 :$nested=[], :$ordered=[], :$retrace_first=false) {
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

    if ( $df->nrow == 1 ) {
        return ( $retrace_first ? $df->append( $df->select_rows(0) ) : $df );
    }

    # ordered the rows
    $df = $df->sort( [ @$nested, @$group_vars, @$ordered ] );

    #inserting NAs to ensure each "group"
    my $changes_group = ( $df->select_columns($group_vars)->id->diff != 0 );
    my $to_insert     = $changes_group;
    if ( $nested->length > 0 ) {
        my $changes_nested = ( $df->select_columns($nested)->id->diff == 0 );
        $to_insert = ( $to_insert & $changes_nested );
    }
    my $idx_to_insert = which($to_insert);    # insert after the indices

    # prepare row indices, each item has start row, stop row,
    #  and places to retrace.

    state $split_range = sub {
        my ( $upper, $after ) = @_;
        return (
            pairmap { [ $a .. $b ] }
            (
                0,
                ( map { ( $_, $_ + 1 ) } grep { $_ < $upper } $after->flatten ),
                $upper
            )
        );
    };

    my @group_rows = $split_range->( $df->nrow - 1, $idx_to_insert );
    my @splitted   = map { $df->select_rows($_) } @group_rows;
    if ($retrace_first) {
        my $to_retrace = $changes_group->glue( 0, pdl( [1] ) );
        my @retrace_at = map {
            my $rindices = pdl($_);
            which( $to_retrace->slice($rindices) )->unpdl;
        } @group_rows;

        @splitted = map {
            my $d            = $splitted[$_];
            my @retrace_rows = $split_range->( $d->nrow - 1, $retrace_at[$_] );
            my @splitted_for_retrace = map {
                my $x = $d->select_rows($_);
                $x->append( $x->select_rows( [0] ) )
            } @retrace_rows;
            reduce { $a->append($b); } ( shift @splitted_for_retrace ),
              @splitted_for_retrace;
        } ( 0 .. $#splitted );
    }

    my @key_vars   = ( @$nested, @$group_vars );
    my @vars_to_na = grep { !elem( $_, \@key_vars ) } $df->names->flatten;
    return (
        reduce {

            # copy last row and make it a NA row
            my $na = $a->select_rows( [ $a->nrow - 1 ] )->copy;
            for my $var (@vars_to_na) {
                $na->at($var)->setbadat(0);
            }
            $a->append($na)->append($b);
        }
        ( shift @splitted ),
        @splitted
    );
}

1;

__END__

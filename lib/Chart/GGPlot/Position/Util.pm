package Chart::GGPlot::Position::Util;

# ABSTRACT: Utilities internally used by Chart::GGPlot::Position

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use List::AllUtils qw(reduce);
use PDL::Primitive qw(which);

use Chart::GGPlot::Util qw(ifelse match pmax pmin);

use parent qw(Exporter::Tiny);

our @EXPORT_OK   = qw(collide pos_dodge pos_stack);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

fun collide_setup ($data, $width, $name, $strategy,
                   $check_width=true, $reverse=false) {
    # determine width
    if ( defined $width ) {
        unless ( List::AllUtils::all { $data->exists($_) } qw(xmin xmax) ) {
            $data->set( 'xmin', $data->at('x') - $width / 2 );
            $data->set( 'xmax', $data->at('x') + $width / 2 );
        }
    }
    else {
        unless ( List::AllUtils::all { $data->exists($_) } qw(xmin xmax) ) {
            $data->set( 'xmin', $data->at('x') );
            $data->set( 'xmax', $data->at('x') );
        }

        my $widths = ( $data->at('xmax') - $data->at('xmin') )->uniq;
        $widths = $widths->slice( which( $widths->isgood ) )
          if $widths->badflag;

        $width = $widths->at(0);
    }

    return { data => $data, width => $width };
}

fun collide ($data, $width, $name, $strategy,
             :$check_width=true, :$reverse=false, %rest) {
    my $dlist =
      collide_setup( $data, $width, $name, $strategy, $check_width, $reverse );
    $data  = $dlist->{data};
    $width = $dlist->{width};

    # Reorder by x position, then on group. The default stacking order
    # reverses the group in order to match the legend order.
    $data =
        $reverse
      ? $data->sort( [qw(xmin group)] )
      : $data->sort( [qw(xmin group)], [ true, false ] );

    state $ddply = sub {
        my ( $df, $vars, $func ) = @_;

        my $ids         = $df->select_columns($vars)->id;
        my $splitted    = $df->split($ids);
        my @transformed = map { $func->($_) } values %$splitted;
        return ( reduce { $a->append($b) } @transformed );
    };

    my $strategy_wrapped = sub { $strategy->( $_[0], $width, %rest ) };
    if ( $data->exists('ymax') ) {
        return $ddply->( $data, ['xmin'], $strategy_wrapped );
    }
    elsif ( $data->exists('y') ) {
        $data->set( 'ymax', $data->at('y') );
        $data = $ddply->( $data, ['xmin'], $strategy_wrapped );
        $data->set( 'y', $data->at('ymax') );
        return $data;
    }
    else {
        die "Neither y nor ymax defined";
    }
}

fun pos_dodge ($df, $width, :$n=undef) {
    my $n //= $df->at('group')->uniq->length;
    if ( $n == 1 ) {
        return $df;
    }

    my $d_width = ( $df->at('xmax') - $df->at('xmin') )->max;

    my $group    = $df->at('group');
    my $groupidx = match( $group, $group->uniq->qsort );
    $df->set( 'x', $df->at('x') + $width * ( ( $groupidx + 0.5 ) / $n - 0.5 ) );

    my $half_width = $d_width / $n / 2;
    $df->set( 'xmin', $df->at('x') - $half_width );
    $df->set( 'xmax', $df->at('x') + $half_width );
    return $df;
}

fun pos_stack ($df, $width, :$vjust=1, :$fill=false) {
    my $n       = $df->nrow + 1;
    my $y       = ifelse( $df->at('y')->isbad, 0, $df->at('y') );
    my $heights = pdl( [0] )->glue( 0, $y->cumusumover() );

    if ($fill) {
        $heights = $heights / $heights->at(-1)->abs;
    }

    my $heights1 = $heights->slice( [ 0 .. $heights->length - 2 ] );
    my $heights2 = $heights->slice( [ 1 .. $heights->length - 1 ] );
    $df->set( 'ymin', pmin( $heights1, $heights2 ) );
    $df->set( 'ymax', pmax( $heights1, $heights2 ) );
    $df->set( 'y',
        ( 1 - $vjust ) * $df->at('ymin') + $vjust * $df->at('ymax') );
    return $df;
}

1;

__END__



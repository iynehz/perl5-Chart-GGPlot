package Chart::GGPlot::Backend::Plotly::Geom;

# ABSTRACT: Role for how geoms are drawn with Plotly backend

use strict;
use warnings;

# VERSION

package Chart::GGPlot::Backend::Plotly::Geom {
    use Chart::GGPlot::Role;

    # whether or not to use webgl
    method use_webgl ($df) {
        my $threshold = $Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD;
        return 0 if ($threshold < 0);
        return ($df->nrow > $threshold);
    }

    requires 'to_trace';
}

package Chart::GGPlot::Backend::Plotly::Geom::Blank {
    use Chart::GGPlot::Class;
    with qw(Chart::GGPlot::Backend::Plotly::Geom);

    classmethod to_trace ($df, %rest) { }

    __PACKAGE__->meta->make_immutable;
}

package Chart::GGPlot::Backend::Plotly::Geom::Path {
    use Chart::GGPlot::Class qw(:pdl);
    with qw(Chart::GGPlot::Backend::Plotly::Geom);

    use List::AllUtils qw(pairmap);
    use Module::Load;

    use Chart::GGPlot::Backend::Plotly::Util qw(cex_to_px to_rgb group_to_NA);
    use Chart::GGPlot::Util qw(ifelse);

    sub mode {
        return 'lines';
    }

    classmethod marker($df, %rest) {
        return;
    }

    classmethod to_trace ($df, %rest) {
        $df = group_to_NA($df);

        my $use_webgl = $class->use_webgl($df);
        my $plotly_trace_class =
          $use_webgl
          ? 'Chart::Plotly::Trace::Scattergl'
          : 'Chart::Plotly::Trace::Scatter';

        autoload $plotly_trace_class;

        if ($log->is_debug) {
            $log->debug($use_webgl ? "to use webgl" : "not to use webgl");
        }

        my ( $x, $y ) = map { $df->at($_) } qw(x y);
        my $marker = $class->marker($df, %rest);

        my $mode = $class->mode;
        my $line;
        if ($mode eq 'lines') {

            # TODO: plotly does not yet support gradient line color and width
            #  See https://github.com/plotly/plotly.js/issues/581

            my $color = to_rgb($df->at('color')->slice(pdl(0)));
            my $size = cex_to_px( $df->at('size')->slice(pdl(0)));
            $size = ifelse( $size < 2, 2, $size );

            # plotly supports solid, dashdot, dash, dot
            my $linetype = $df->at('linetype')->at(0);

            $line = {
                color => $color->at(0),
                width => $size->at(0),
                ( $linetype ne 'solid' ? ( dash        => $linetype )  : () ),
            };
        }

        return $plotly_trace_class->new(
            x    => $x->unpdl,
            y    => $y->unpdl,
            mode => $mode,
            maybe
              line => $line,
            maybe
              marker => $marker,

            # TODO: hovertext for webgl does not seem to work. Maybe it's
            #  because of large data count. To revisit this in future.
            (
                $use_webgl
                ? ()
                : (
                    hovertext => $df->at('hovertext')->unpdl,
                    hoverinfo => 'text',
                )
            ),
        );
    }

    __PACKAGE__->meta->make_immutable;
}

package Chart::GGPlot::Backend::Plotly::Geom::Line {
    use Chart::GGPlot::Class;
    extends qw(Chart::GGPlot::Backend::Plotly::Geom::Path);

    __PACKAGE__->meta->make_immutable;
}

package Chart::GGPlot::Backend::Plotly::Geom::Point {
    use Chart::GGPlot::Class;
    extends qw(Chart::GGPlot::Backend::Plotly::Geom::Path);

    use Module::Load;

    use Chart::GGPlot::Backend::Plotly::Util qw(cex_to_px to_rgb);
    use Chart::GGPlot::Util qw(ifelse);

    sub mode {
        return 'markers';
    }

    classmethod marker($df, %rest) {
        my $color = to_rgb($df->at('color'));
        my $fill =
          $df->exists('fill')
          ? ifelse( $df->at('fill')->isbad, $color, to_rgb( $df->at('fill') ) )
          : $color;
        my $size    = cex_to_px( $df->at('size') );
        $size = ifelse( $size < 2, 2, $size );
        my $opacity = $df->at('alpha')->setbadtoval(1);
        my $stroke = cex_to_px( $df->at('stroke') );

        my $use_webgl = $class->use_webgl($df);
        my $plotly_trace_class =
          $use_webgl
          ? 'Chart::Plotly::Trace::Scattergl'
          : 'Chart::Plotly::Trace::Scatter';
        my $plotly_marker_class = "${plotly_trace_class}::Marker";

        autoload $plotly_marker_class;

        return $plotly_marker_class->new(
            color => $fill->unpdl,
            size  => $size->unpdl,
            line  => {
                color => $color->unpdl,
                width => $stroke->unpdl,
            },

            # TODO: support scatter symbol
            symbol  => [ (0) x $df->at('size')->length ],
            opacity => $opacity->unpdl,
        );
    }

    __PACKAGE__->meta->make_immutable;
}

package Chart::GGPlot::Backend::Plotly::Geom::Bar {
    use Chart::GGPlot::Class;
    with qw(Chart::GGPlot::Backend::Plotly::Geom);

    use List::AllUtils qw(pairmap);
    use Module::Load;

    use Chart::GGPlot::Backend::Plotly::Util qw(cex_to_px to_rgb);
    use Chart::GGPlot::Util qw(ifelse);

    classmethod to_trace ($df, %rest) {
        autoload Chart::Plotly::Trace::Bar;
        autoload Chart::Plotly::Trace::Bar::Marker;

        my $fill    = to_rgb($df->at('fill'));
        my $opacity = $df->at('alpha')->setbadtoval(1);

        my $marker = Chart::Plotly::Trace::Bar::Marker->new(
            color => $fill->unpdl,
            opacity => $opacity->unpdl,
        );

        my ($x, $y) = map { $df->at($_)->unpdl } qw(x y);
        my $width = ($df->at('xmax') - $df->at('xmin'))->unpdl;

        return Chart::Plotly::Trace::Bar->new(
            x         => $x,
            y         => $y,
            width     => $width,
            marker    => $marker,
            hovertext => $df->at('hovertext')->unpdl,
            hoverinfo => [ ('text') x $df->nrow ],
        );
    }

    __PACKAGE__->meta->make_immutable;
}


1;

__END__


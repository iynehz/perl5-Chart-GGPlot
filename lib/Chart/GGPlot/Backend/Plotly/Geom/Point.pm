package Chart::GGPlot::Backend::Plotly::Geom::Point;

# ABSTRACT: Chart::GGPlot's Plotly implementation for Geom::Point

use Chart::GGPlot::Class;

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Path);

use Module::Load;

use Chart::GGPlot::Backend::Plotly::Util qw(to_px to_rgb pdl_to_plotly);
use Chart::GGPlot::Util qw(ifelse);

sub mode {
    return 'markers';
}

classmethod scatter_marker ($df, $params, @rest) {
    my $color = to_rgb( $df->at('color') );
    my $fill =
      $df->exists('fill')
      ? ifelse( $df->at('fill')->isbad, $color, to_rgb( $df->at('fill') ) )
      : $color;
    my $size = to_px( $df->at('size') );
    $size->where($size < 2) .= 2;
    my $opacity = $df->at('alpha')->setbadtoval(1);
    my $stroke  = to_px( $df->at('stroke') );

    my $use_webgl = $class->use_webgl($df);
    my $plotly_trace_class =
      $use_webgl
      ? 'Chart::Plotly::Trace::Scattergl'
      : 'Chart::Plotly::Trace::Scatter';
    my $plotly_marker_class = "${plotly_trace_class}::Marker";

    load $plotly_marker_class;

    return $plotly_marker_class->new(
        color => pdl_to_plotly( $fill, true ),
        size  => pdl_to_plotly( $size, true ),
        line  => {
            color => pdl_to_plotly( $color,  true ),
            width => pdl_to_plotly( $stroke, true ),
        },

        # TODO: support scatter symbol
        symbol  => [ (0) x $df->at('size')->length ],
        opacity => pdl_to_plotly( $opacity, true ),
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>,
L<Chart::GGPlot::Geom::Point>

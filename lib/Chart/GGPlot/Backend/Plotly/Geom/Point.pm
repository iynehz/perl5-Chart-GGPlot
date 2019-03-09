package Chart::GGPlot::Backend::Plotly::Geom::Point;

# ABSTRACT: Chart::GGPlot's Plotly support for Geom::Point

use Chart::GGPlot::Class;

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Path);

use Module::Load;

use Chart::GGPlot::Backend::Plotly::Util qw(cex_to_px to_rgb);
use Chart::GGPlot::Util qw(ifelse);

sub mode {
    return 'markers';
}

classmethod marker ($df, %rest) {
    my $color = to_rgb( $df->at('color') );
    my $fill =
      $df->exists('fill')
      ? ifelse( $df->at('fill')->isbad, $color, to_rgb( $df->at('fill') ) )
      : $color;
    my $size = cex_to_px( $df->at('size') );
    $size = ifelse( $size < 2, 2, $size );
    my $opacity = $df->at('alpha')->setbadtoval(1);
    my $stroke  = cex_to_px( $df->at('stroke') );

    my $use_webgl = $class->use_webgl($df);
    my $plotly_trace_class =
      $use_webgl
      ? 'Chart::Plotly::Trace::Scattergl'
      : 'Chart::Plotly::Trace::Scatter';
    my $plotly_marker_class = "${plotly_trace_class}::Marker";

    load $plotly_marker_class;

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

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>


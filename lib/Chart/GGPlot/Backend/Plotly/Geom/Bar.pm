package Chart::GGPlot::Backend::Plotly::Geom::Bar;

# ABSTRACT: Chart::GGPlot's Plotly support for Geom::Bar

use Chart::GGPlot::Class;

# VERSION

with qw(Chart::GGPlot::Backend::Plotly::Geom);

use Module::Load;

use Chart::GGPlot::Backend::Plotly::Util qw(to_rgb);

classmethod to_trace ($df, %rest) {
    load Chart::Plotly::Trace::Bar;
    load Chart::Plotly::Trace::Bar::Marker;

    my $fill    = to_rgb( $df->at('fill') );
    my $opacity = $df->at('alpha')->setbadtoval(1);

    my $marker = Chart::Plotly::Trace::Bar::Marker->new(
        color   => $fill->unpdl,
        opacity => $opacity->unpdl,
    );

    my $x     = $df->at('x')->unpdl;
    my $y     = ( $df->at('ymax') - $df->at('ymin') )->unpdl;
    my $base  = $df->at('ymin')->unpdl;
    my $width = ( $df->at('xmax') - $df->at('xmin') )->unpdl;

    return Chart::Plotly::Trace::Bar->new(
        x         => $x,
        y         => $y,
        base      => $base,
        width     => $width,
        marker    => $marker,
        hovertext => $df->at('hovertext')->unpdl,
        hoverinfo => 'text',
    );
}

around _hovertext_data_for_aes( $orig, $class : $df, $aes ) {
    return (
          $aes eq 'y'
        ? $df->at('ymax') - $df->at('ymin')
        : $class->$orig( $df, $aes )
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>


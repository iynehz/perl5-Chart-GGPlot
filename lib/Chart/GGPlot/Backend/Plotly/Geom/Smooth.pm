package Chart::GGPlot::Backend::Plotly::Geom::Smooth;

# ABSTRACT: Chart::GGPlot's Plotly support for Geom::Smooth

use Chart::GGPlot::Class qw(:pdl);

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Line);

use Module::Load;

use Chart::GGPlot::Backend::Plotly::Util qw(
  cex_to_px to_rgb group_to_NA pdl_to_plotly
);
use Chart::GGPlot::Backend::Plotly::Geom::Polygon;
use Chart::GGPlot::Backend::Plotly::Util qw(ribbon);
use Chart::GGPlot::Util qw(BAD);

around to_traces( $orig, $class : $df, $params, $plot ) {
    return [] if $df->nrow == 0;

    my $path = $df->copy;
    $path->set('alpha', BAD());     # alpha for the path is always 1
    my $traces_fitted = $class->$orig( $path, $params, $plot );
    unless ( $df->exists('ymin') and $df->exists('ymax') ) {
        return [@$traces_fitted];
    }

    my $ribbon = ribbon($df);
    $ribbon->set( 'color', BAD() );
    my $traces_confintv =
      Chart::GGPlot::Backend::Plotly::Geom::Polygon->to_traces( $ribbon,
        $params, $plot );
    for my $trace (@$traces_confintv) {
        $trace->{hoverinfo} = 'x+y';
    }

    return [ @$traces_confintv, @$traces_fitted ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>,
L<Chart::GGPlot::Geom::Smooth>

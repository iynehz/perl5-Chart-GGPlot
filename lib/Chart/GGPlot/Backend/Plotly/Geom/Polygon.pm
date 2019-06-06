package Chart::GGPlot::Backend::Plotly::Geom::Polygon;

# ABSTRACT: Chart::GGPlot's Plotly implementation for Geom::Bar

use Chart::GGPlot::Class;

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Line);

use PDL::Core qw(pdl);
use Module::Load;

use Chart::GGPlot::Backend::Plotly::Util qw(
  cex_to_px to_rgb group_to_NA pdl_to_plotly
);

classmethod split_on () { [qw(fill color size)] }
classmethod hover_on () { 'fills' }

around to_traces ($orig, $class : $df, $params, $plot) {
    my $traces = $class->$orig($df, $params, $plot);
    for my $trace (@$traces) {
        my $size = cex_to_px( $df->at('size')->slice( pdl(0) ) )->at(0);
        my $fillcolor = to_rgb( $df->at('fill'), $df->at('alpha') )->at(0);
        $trace->text($df->at('hovertext')->at(0));
        $trace->line->width($size);
        $trace->fill('toself');
        $trace->fillcolor($fillcolor);
    }
    return $traces;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>,
L<Chart::GGPlot::Geom::Bar>


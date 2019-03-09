package Chart::GGPlot::Backend::Plotly::Geom::Blank;

# ABSTRACT: Chart::GGPlot's Plotly support for Geom::Bar 

use Chart::GGPlot::Class;

# VERSION

with qw(Chart::GGPlot::Backend::Plotly::Geom);

classmethod to_trace ($df, %rest) { }

__PACKAGE__->meta->make_immutable;

1;

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>


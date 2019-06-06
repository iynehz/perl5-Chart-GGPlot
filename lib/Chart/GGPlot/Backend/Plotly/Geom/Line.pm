package Chart::GGPlot::Backend::Plotly::Geom::Line;

# ABSTRACT: Chart::GGPlot's Plotly implementation for Geom::Line

use Chart::GGPlot::Class;

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Path);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>,
L<Chart::GGPlot::Geom::Line>

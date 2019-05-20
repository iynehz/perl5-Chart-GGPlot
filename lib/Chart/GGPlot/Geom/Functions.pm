package Chart::GGPlot::Geom::Functions;

# ABSTRACT: Function interface for Chart::GGPlot::Geom

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Util qw(collect_functions_from_package);

use parent qw(Exporter::Tiny);

my @export_ggplot;

our @sub_namespaces = qw(
  Blank
  Bar Boxplot
  Path Point Line
  Polygon
);

for my $name (@sub_namespaces) {
    my $package = "Chart::GGPlot::Geom::$name";
    my @func_names = collect_functions_from_package($package);
    push @export_ggplot, @func_names;
}

our @EXPORT_OK = (
    @export_ggplot,
);

our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);


1;

__END__

=head1 DESCRIPTION

This module provides the C<geom_*> functions supported by this Chart-GGPlot
library.  When used standalone, each C<geom_*> function generates a
L<Chart::GGPlot::Layer> object. Also the functions can be used as
L<Chart::GGPlot::Plot> methods, to add layers into the plot object.

=head1 FUNCTIONS

=srcAlias GeomFunctions temp/GeomFunctions.pod

=include funcs@GeomFunctions

=head1 SEE ALSO

L<Chart::GGPlot::Layer>,
L<Chart::GGPlot::Plot>


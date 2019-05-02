package Chart::GGPlot::Coord::Functions;

# ABSTRACT: Functions of coordination systems

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Chart::GGPlot::Util qw(collect_functions_from_package);

use parent qw(Exporter::Tiny);

my @export_ggplot;

our @sub_namespaces = qw(Cartesian Flip);

for my $name (@sub_namespaces) {
    my $package = "Chart::GGPlot::Coord::$name";
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

=head1 FUNCTIONS

=srcAlias CoordFunctions temp/CoordFunctions.pod

=include funcs@CoordFunctions

=head1 SEE ALSO

L<Chart::GGPlot::Coord>


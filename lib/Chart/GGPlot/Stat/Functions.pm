package Chart::GGPlot::Stat::Functions;

# ABSTRACT: Function interface for stats

use Chart::GGPlot::Setup;

# VERSION

use Module::Load;

use Chart::GGPlot::Util qw(collect_functions_from_package);

use parent qw(Exporter::Tiny);

my @export_ggplot;

our @sub_namespaces = qw(Bin Boxplot Count Identity);

for my $name (@sub_namespaces) {
    my $package = "Chart::GGPlot::Stat::$name";
    my @func_names = collect_functions_from_package($package);
    push @export_ggplot, @func_names;
}

our @EXPORT_OK   = @export_ggplot;
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

1;

__END__

=head1 DESCRIPTION

=head1 FUNCTIONS

=srcAlias StatFunctions temp/StatFunctions.pod

=include funcs@StatFunctions

=head1 SEE ALSO

L<Chart::GGPlot::Stat>

package Chart::GGPlot::Facet::Functions;

# ABSTRACT: Function interface for Chart::GGPlot::Facet

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Chart::GGPlot::Facet::Null;
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = qw(facet_null);
our @EXPORT_OK = ( @export_ggplot );
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

=func facet_null

    facet_null(:$shrink=true)

This method creates a L<Chart::GGPlot::Facet::Null> object.

=cut

sub facet_null {
    return Chart::GGPlot::Facet::Null->new(@_);
}


1;

__END__

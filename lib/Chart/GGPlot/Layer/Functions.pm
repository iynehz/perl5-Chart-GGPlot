package Chart::GGPlot::Layer::Functions;

# ABSTRACT: Layer functions

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Util qw(:all);

use Chart::GGPlot::Layer;
use Chart::GGPlot::Aes::Functions qw(aes);

use Exporter qw(import);

my @export_ggplot = qw(layer);

our @EXPORT_OK   = @export_ggplot;
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot
);

=func layer(...)

Returns a Chart::GGPlot::Layer object.

=cut

sub layer {
    return Chart::GGPlot::Layer->new(@_);
}

1;

__END__

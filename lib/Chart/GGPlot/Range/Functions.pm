package Chart::GGPlot::Range::Functions;

use Chart::GGPlot::Setup;

use Chart::GGPlot::Range::Continuous;
use Chart::GGPlot::Range::Discrete;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  continuous_range discrete_range
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

fun continuous_range () {
    return Chart::GGPlot::Range::Continuous->new();
}

fun discrete_range () {
    return Chart::GGPlot::Range::Discrete->new();
}

1;

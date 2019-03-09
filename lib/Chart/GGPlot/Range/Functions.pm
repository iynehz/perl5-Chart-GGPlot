package Chart::GGPlot::Range::Functions;

# ABSTRACT: Function interface for range

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Range::Continuous;
use Chart::GGPlot::Range::Discrete;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  continuous_range discrete_range
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

=func continuous_range

=cut

fun continuous_range () {
    return Chart::GGPlot::Range::Continuous->new();
}

func discrete_range

=cut

fun discrete_range () {
    return Chart::GGPlot::Range::Discrete->new();
}

1;

__END__

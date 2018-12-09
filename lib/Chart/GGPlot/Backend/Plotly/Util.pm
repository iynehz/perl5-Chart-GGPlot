package Chart::GGPlot::Backend::Plotly::Util;

# ABSTRACT:

use Chart::GGPlot::Setup;

# VERSION

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  pt_to_px
  cex_to_px
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my $dpi = 96;

fun pt_to_px ($x) { $x / 72 * $dpi }

# This is approximately similar to the size in ggplot2.
# Default R fontsize is 12pt. And R scales many symbols by 0.75.
# 0.3 is a magic number from my guess.
fun cex_to_px ($x) { pt_to_px( 12 * $x * 0.75 * 0.3) }

1;

__END__

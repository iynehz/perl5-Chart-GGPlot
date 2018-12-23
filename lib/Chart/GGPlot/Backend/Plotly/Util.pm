package Chart::GGPlot::Backend::Plotly::Util;

# ABSTRACT:

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Graphics::Color::RGB;
use Types::PDL qw(Piddle);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  pt_to_px
  cex_to_px
  br
  to_rgb
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my $dpi = 96;

fun pt_to_px ($x) { $x / 72 * $dpi }

# This is approximately similar to the size in ggplot2.
# Default R fontsize is 12pt. And R scales many symbols by 0.75.
# 0.3 is a magic number from my guess.
fun cex_to_px ($x) { pt_to_px( 12 * $x * 0.75 * 0.3) }

sub br { '<br />' }

# plotly does not understands some non-rgb colors like "grey35"
fun to_rgb(Piddle $x) {
    my $rgb = sub {
        my ($color) = @_;
        
        if ($color =~ /^\#/) {
            return $color;
        } else {
            try {
                my $c = Graphics::Color::RGB->from_color_library($color);
                return $c->as_css_hex;
            } catch {
                return $color;
            }
        }
    };

    my $p = PDL::SV->new($x->unpdl->map($rgb));
    if ($x->badflag) {
        $p = $p->setbadif($x->isbad);
    }
    return $p
}

1;

__END__

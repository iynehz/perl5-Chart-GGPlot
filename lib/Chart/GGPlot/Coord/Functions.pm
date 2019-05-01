package Chart::GGPlot::Coord::Functions;

# ABSTRACT: Functions of coordination systems

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Chart::GGPlot::Coord::Cartesian;
use Chart::GGPlot::Coord::Flip;
use Chart::GGPlot::Coord::Polar;
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = qw(coord_cartesian coord_flip coord_polar);

our @EXPORT_OK = (
    @export_ggplot,
    qw(
      )
);

our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

sub coord_cartesian {
    return Chart::GGPlot::Coord::Cartesian->new(@_);
}

fun coord_polar(:$theta ='x', :$start = 0, :$direction = 1) {
    return Chart::GGPlot::Coord::Polar->new(
        theta     => $theta,
        start     => $start,
        direction => ( $direction <=> 0 )
    );
}

sub coord_flip {
    return Chart::GGPlot::Coord::Flip->new(@_);
}

1;

__END__

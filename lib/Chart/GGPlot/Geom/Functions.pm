package Chart::GGPlot::Geom::Functions;

# ABSTRACT: Function interface for Chart::GGPlot::Geom

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Chart::GGPlot::Geom::Blank;
use Chart::GGPlot::Geom::Point;
use Chart::GGPlot::Geom::Rect;
use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Types;
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = qw(geom_blank geom_point geom_histogram);

our @EXPORT_OK = (
    @export_ggplot,
    qw(
      )
);

our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

fun geom_blank (
    : $mapping     = undef,
    : $data        = undef,
    : $stat        = "identity",
    : $position    = "identity",
    : $show_legend = 'auto',
    : $inherit_aes = true, %rest
  ) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        check_aes   => false,
        geom        => 'blank',
        params      => \%rest,
    );
}

fun geom_point (
    : $mapping = undef,
    : $data= undef,
    : $stat = 'identity',
    : $position = 'identity',
    : $na_rm = false,
    : $show_legend = 'auto',
    : $inherit_aes = true, 
    %rest) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'point',
        params      => { na_rm => $na_rm, %rest },
    );
}

fun geom_histogram (
    : $data        = undef,
    : $mapping     = undef,
    : $stat        = "bin",
    : $position    = "stack",
    : $binwidth    = undef,
    : $bins        = undef,
    : $na_rm       = false,
    : $show_legend = 'auto',
    : $inherit_aes = true,
    %rest
  ) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => stat,
        geom        => 'bar',
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        params      => {
            binwidth => $binwidth,
            bins     => $bins,
            na_rm    => $na_rm,
            pad      => false,
            %rest
        },
    );
}

1;

__END__

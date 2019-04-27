package Chart::GGPlot::Stat::Functions;

# ABSTRACT: Function interface for stats

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Module::Load;

use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Types;
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = qw(
  stat_identity stat_count
);
our @EXPORT_OK   = @export_ggplot;
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

=func stat_identity

=cut

fun stat_identity (:$mapping = undef, :$data = undef,
                   :$geom = "point", :$position = "identity",
                   :$show_legend = undef, :$inherit_aes = true, %rest) {
    return layer(
        mapping     => $mapping,
        data        => $data,
        stat        => 'identify',
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'blank',
        params      => { na_rm => false, %rest },
    );
}

=func stat_count

=cut

fun stat_count (:$mapping = undef, :$data = undef,
                :$geom = 'bar', :$position = 'stack', 
                :$width = undef, :$na_rm = false,
                :$show_legend = undef, :$inherit_aes = true,
                %rest ) {
    my $params = {
        na_rm => $na_rm,
        width => $width,
        %rest
    };
    if ( $data->exists('y') ) {
        die "stat_count() must not be used with a y aesthetic.";
    }

    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => 'count',
        geom        => $geom,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        params      => $params,
    );
}

my @stat_namespaces = qw(Boxplot);

for my $partial_ns (@stat_namespaces) {
    my $package = "Chart::GGPlot::Stat::$partial_ns";
    load $package;

    my $func_name = "stat_" . lc($partial_ns);
    no strict 'refs';
    *{$func_name} = $package->ggplot_function;
}

1;

__END__

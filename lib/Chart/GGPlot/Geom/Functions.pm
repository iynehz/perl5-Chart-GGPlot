package Chart::GGPlot::Geom::Functions;

# ABSTRACT: Function interface for Chart::GGPlot::Geom

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Types;
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = qw(
  geom_blank
  geom_point
  geom_path geom_line
  geom_bar geom_histogram
);

our @EXPORT_OK = (
    @export_ggplot,
);

our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

fun geom_blank (:$mapping = undef, :$data = undef,
                :$stat = "identity", :$position = "identity",
                :$show_legend = 'auto', :$inherit_aes = true,
                %rest) {
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

=method geom_path

    geom_path (:$mapping = undef, :$data = undef, 
               :$stat = 'identity', :$position = 'identity', 
               :$na_rm = false,
               :$show_legend = 'auto', :$inherit_aes = true, 
               %rest)

C<geom_path()> connects the observations in the order in which they appear in
the data. 

=cut

fun geom_path (:$mapping = undef, :$data = undef, 
               :$stat = 'identity', :$position = 'identity', 
               :$na_rm = false,
               :$show_legend = 'auto', :$inherit_aes = true, 
               %rest) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'path',
        params      => { na_rm => $na_rm, %rest },
    );
}

=method geom_line

    geom_line (:$mapping = undef, :$data = undef, 
               :$stat = 'identity', :$position = 'identity', 
               :$na_rm = false,
               :$show_legend = 'auto', :$inherit_aes = true, 
               %rest)

C<geom_line()> connects the observations in the order of the variable on the
x axis. 

=cut

fun geom_line (:$mapping = undef, :$data = undef, 
               :$stat = 'identity', :$position = 'identity', 
               :$na_rm = false,
               :$show_legend = 'auto', :$inherit_aes = true, 
               %rest) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'line',
        params      => { na_rm => $na_rm, %rest },
    );
}

=method geom_point

=cut

fun geom_point (:$mapping = undef, :$data = undef,
                :$stat = 'identity', :$position = 'identity',
                :$na_rm = false,
                :$show_legend = 'auto', :$inherit_aes = true, 
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

fun geom_bar(:$mapping = undef, :$data = undef,
             :$stat = 'count', :$position = 'stack', 
             :$width = undef, :$na_rm = false,
             :$show_legend = 'auto', :$inherit_aes = true,
             %rest) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        geom        => 'bar',
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        params      => {
            width => $width,
            na_rm => $na_rm,
            %rest,
        },
    );
}

fun geom_histogram (:$data = undef, :$mapping = undef,
                    :$stat = "bin", :$position = "stack",
                    :$binwidth = undef, :$bins = undef,
                    :$na_rm = false,
                    :$show_legend = 'auto', :$inherit_aes = true,
                    %rest) {
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
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

=head1 SEE ALSO

L<Chart::GGPlot::Geom>


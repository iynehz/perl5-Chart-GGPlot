package Chart::GGPlot::Stat::Identity;

# ABSTRACT: Statistic method that does identity

use Chart::GGPlot::Class;
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

use Chart::GGPlot::Layer;

with qw(
  Chart::GGPlot::Stat
);

my $stat_identity_pod = <<'END_OF_TEXT';
END_OF_TEXT
my $stat_identity_code = fun (
        :$mapping = undef, :$data = undef,
        :$geom = "point", :$position = "identity",
        :$show_legend = undef, :$inherit_aes = true,
        %rest )
{
    return Chart::GGPlot::Layer->new(
        mapping     => $mapping,
        data        => $data,
        stat        => 'identify',
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'blank',
        params      => { na_rm => false, %rest },
    );
};

classmethod ggplot_functions() {
    return [
        {
            name => 'stat_identity',
            code => $stat_identity_code,
            pod  => $stat_identity_pod,
        }
    ];
}

method compute_layer( $data, $params, $layout ) {
    return $data;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

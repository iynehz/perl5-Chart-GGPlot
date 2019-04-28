package Chart::GGPlot::Stat::Count;

# ABSTRACT: Statistic method that counts number of data in bin

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean -except => 'stat';
use MooseX::Singleton;

# VERSION

use Data::Frame;

use Chart::GGPlot::Aes::Functions qw(aes);
use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Util qw(resolution stat);

with qw(
  Chart::GGPlot::Stat
);

has '+default_aes'  => (
    default => sub {
        aes(
            y      => q{stat($count)},
            weight => 1,
        );
    }
);

classmethod required_aes() { ['x'] }

my $stat_count_pod = <<'END_OF_TEXT';
END_OF_TEXT
my $stat_count_code = fun (
        :$mapping = undef, :$data = undef,
        :$geom = 'bar', :$position = 'stack', 
        :$width = undef, :$na_rm = false,
        :$show_legend = undef, :$inherit_aes = true,
        %rest )
{ 
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
};

classmethod ggplot_functions() {
    return [
        {
            name => 'stat_count',
            code => $stat_count_code,
            pod  => $stat_count_pod,
        }
    ];
}

method setup_params ($data, $params) {
    if ( $data->exists('y') ) {
        die "stat_count() must not be used with a y aesthetic.";
    }
    return $params;
}

method compute_group ($data, $scales, $params) {
    my $width  = $params->at('width');

    my $x      = $data->at('x');
    my $weight =
        $data->exists('weight')
      ? $data->at('weight')
      : PDL::Core::ones($x->length);
    $width  = $width // pdl(resolution($x) * 0.9);

    # TODO: R does tapply() here. It's somewhat like groupby and then
    #  summarise on #  each group. We can change this once we have
    #  groupby + summarize in our data frame implementations.

    my $uniq = $x->uniq->qsort;
    my $count = pdl(
        $uniq->unpdl->map( sub { $weight->where($x == $_)->sum; } )
    );
    $count->setbadtoval(0);

    return Data::Frame->new(
        columns => [
            count => $count,
            prop  => $count / $count->abs->sum,
            x     => $uniq,
            width => $width,
        ]
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

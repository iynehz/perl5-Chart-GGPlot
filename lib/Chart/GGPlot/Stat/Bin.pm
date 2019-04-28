package Chart::GGPlot::Stat::Bin;

# ABSTRACT: Statistic method that gets histogram of data

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean -except => 'stat';
use MooseX::Singleton;

# VERSION

use PDL::Primitive qw(which);
use POSIX qw(floor);

use Chart::GGPlot::Aes::Functions qw(aes);
use Chart::GGPlot::Bins;
use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Util qw(call_if_coderef seq_n stat);

with qw(
  Chart::GGPlot::Stat
);

has '+default_aes' => (
    default => sub {
        aes(
            y      => q{stat($count)},
            weight => 1,
        );
    }
);

classmethod required_aes () { ['x'] }

classmethod _parameters () {
    [
        qw(
          na_rm
          bins binwidth boundary breaks center pad
          )
    ]
}

my $stat_bin_pod = <<'END_OF_TEXT';
END_OF_TEXT
my $stat_bin_code = fun (
    :$mapping=undef, :$data=undef,
    :$geom="bar", :$position="stack",
    :$binwidth=undef, :$bins=undef,
    :$center=undef, :$boundary=undef, :$breaks=undef,
    :$pad=false,
    :$na_rm=false,
    :$show_legend='auto', :$inherit_aes=true,
    %rest )
{                           
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => 'bin',
        geom        => $geom,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        params      => {
            binwidth => $binwidth,
            bins     => $bins,
            center   => $center,
            boundary => $boundary,
            breaks   => $breaks,
            pad      => $pad,
            na_rm    => $na_rm,
            %rest
        }
    );
};

classmethod ggplot_functions () {
    return [
        {
            name => 'stat_bin',
            code => $stat_bin_code,
            pod  => $stat_bin_pod,
        }
    ];
}

method setup_params ($data, $params) {
    if ( $data->exists('y') ) {
        die "stat_count() must not be used with a y aesthetic.";
    }
    if (    !$params->at('breaks')
        and !$params->at('binwidth')
        and !$params->at('bins') )
    {
        $params->set( bins => 30 );
        warn
          "'stat_bin()' using 'bins = 30'. Pick better value with 'binwidth'.";
    }
    return $params;
}

method compute_group ($data, $scales, $params) {
    my ( $binwidth, $bins, $center, $boundary, $breaks, $pad ) =
      map { $params->at($_) }
      qw(
      binwidth bins center boundary breaks pad
    );

    if ( defined $breaks ) {
        my $scale_x = $scales->at('x');
        if ( $scale_x->$_DOES('Chart::GGPlot::Scales::Discrete') ) {
            $breaks = $scale_x->transform->($breaks);
        }
        $bins = Chart::GGPlot::Bins->bin_breaks($breaks);
    }
    elsif ( defined $binwidth ) {
        $binwidth = call_if_coderef( $binwidth, $data->at('x') );
        $bins     = Chart::GGPlot::Bins->bin_breaks_width(
            $scales->at('x')->dimension(),
            $binwidth,
            center   => $center,
            boundary => $boundary
        );
    }
    else {
        $bins = Chart::GGPlot::Bins->bin_breaks_bins(
            $scales->at('x')->dimension(),
            $bins,
            center   => $center,
            boundary => $boundary
        );
    }

    return $bins->bin_vector(
        $data->at('x'),
        ( $data->exists('weight') ? ( weight => $data->at('weight') ) : () ),
        maybe pad => $pad
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

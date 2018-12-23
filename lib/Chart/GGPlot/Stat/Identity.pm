package Chart::GGPlot::Stat::Identity;

# ABSTRACT: Statistics method that does identity

use Chart::GGPlot::Class;
use MooseX::Singleton;

# VERSION

with qw(
  Chart::GGPlot::Stat
);

method compute_layer( $data, $params, $layout ) {
    return $data;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

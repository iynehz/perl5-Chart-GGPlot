package Chart::GGPlot::Stat::Identity;

# ABSTRACT: Chart::GGPlot's identity statistics

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

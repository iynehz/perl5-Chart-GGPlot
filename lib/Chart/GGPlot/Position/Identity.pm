package Chart::GGPlot::Position::Identity;

# ABSTRACT: Position class that does not adjust position

use Chart::GGPlot::Class;

# VERSION

with qw(Chart::GGPlot::Position);

method compute_layer($data, $params, $scales) {
    return $data;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

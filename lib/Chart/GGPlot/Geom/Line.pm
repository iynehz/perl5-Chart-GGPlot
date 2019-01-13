package Chart::GGPlot::Geom::Line;

# ABSTRACT: Class for path geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

extends qw(Chart::GGPlot::Geom::Path);

# VERSION

method setup_data ($data, $params) {
    return $data->sort( [qw(PANEL group x)] );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__

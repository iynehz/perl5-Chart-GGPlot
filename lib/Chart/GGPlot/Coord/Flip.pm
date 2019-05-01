package Chart::GGPlot::Coord::Flip;

# ABSTRACT: Cartesian coordinates with x and y flipped

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

extends qw(Chart::GGPlot::Coord::Cartesian); 

use Chart::GGPlot::Scale::Functions qw(scale_flip_position);

# The R ggplot2 code has some logic for flipping things inside its
#  CoordFlip class. For Chart::Plot we don't do similar things here.
#  Instead we implement that in the graphics backend. 

__PACKAGE__->meta->make_immutable;

1;

__END__

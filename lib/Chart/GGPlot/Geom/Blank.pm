package Chart::GGPlot::Geom::Blank;

# ABSTRACT: Class for blank geom

use Chart::GGPlot::Class;
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

with qw(Chart::GGPlot::Geom);

method handle_na ( $data, $params ) { $data; }

__PACKAGE__->meta->make_immutable();

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>

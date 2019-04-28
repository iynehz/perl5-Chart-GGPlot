package Chart::GGPlot::Geom::Rect;

# ABSTRACT: Class for rect geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

use Chart::GGPlot::Aes;
use Chart::GGPlot::Util qw(:all);

with qw(Chart::GGPlot::Geom);

has '+non_missing_aes' => ( default => sub { [qw(size shape color)] } );
has '+default_aes'     => (
    default => sub {
        Chart::GGPlot::Aes->new(
            color    => NA(),
            fill     => PDL::SV->new(["grey35"]),
            size     => pdl(0.5),
            linetype => PDL::SV->new(["solid"]),
            alpha    => NA(),
        );
    }
);

classmethod ggplot_functions() { ... }

classmethod required_aes() { [qw(xmin xmax ymin ymax)] };

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>

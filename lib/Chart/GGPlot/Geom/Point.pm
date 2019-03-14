package Chart::GGPlot::Geom::Point;

# ABSTRACT: Class for point geom

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
            shape  => pdl(19),
            color  => PDL::SV->new(["black"]),
            size   => pdl(1.5),
            fill   => NA(),
            alpha  => NA(),
            stroke => pdl(0.5),
        );
    }
);

classmethod required_aes() { [qw(x y)] }

__PACKAGE__->meta->make_immutable();

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>

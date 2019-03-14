package Chart::GGPlot::Geom::Bar;

# ABSTRACT: Class for bar geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;
use MooseX::Singleton;

extends qw(Chart::GGPlot::Geom::Rect);

# VERSION

use Chart::GGPlot::Aes;
use Chart::GGPlot::Util qw(:all);

has '+non_missing_aes' => ( default => sub { [qw(xmin xmax ymin ymax)] } );

classmethod required_aes() { [qw(x y)] }
classmethod extra_params() { [qw(na_rm width)] }

method setup_data ($data, $params) {
    unless ( $data->exists('width') ) {
        $data->set( 'width',
            $params->at('width')
              // pdl( resolution( $data->at('x'), false ) * 0.9 ) );
    }
    return $data->transform( {
            ymin => fun($col, $df) { pmin($df->at('y'), 0) }, 
            ymax => fun($col, $df) { pmax($df->at('y'), 0) },
            xmin => fun($col, $df) { $df->at('x') - $df->at('width') / 2 },
            xmax => fun($col, $df) { $df->at('x') + $df->at('width') / 2 },
            width => undef,
        } );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>

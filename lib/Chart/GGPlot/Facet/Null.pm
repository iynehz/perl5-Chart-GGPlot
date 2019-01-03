package Chart::GGPlot::Facet::Null;

# ABSTRACT: A single panel for faceting

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use PDL::Primitive qw(which);
use Type::Params;
use Types::Standard qw(ArrayRef Bool CodeRef Enum Maybe Str);

use Chart::GGPlot::Types qw(:all);

=attr shrink

If true, will shrink scales to fit output of statistics, not
raw data. If fause will be range of raw data before statistical
summary.

The default is true.

=cut

with qw(Chart::GGPlot::Facet);

has '+shrink' => ( default => 1 );
has '+params' => (init_arg => undef);

method compute_layout ($data, $params) {
    return $self->layout_null();
}

method map_data ($data, $layout, $params) {
    if ( not defined $data ) {
        return Data::Frame::More->new( columns => [ PANEL => null ] );
    }
    if ( $data->isempty ) {
        return $data->merge( PANEL => null );
    }

    $data->set('PANEL', pdl([0])->repeat( $data->nrow ));
    return $data;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This class represents a single panel for faceting.
This is the default facet specification.

=head1 SEE ALSO

L<Chart::GGPlot::Facet> 


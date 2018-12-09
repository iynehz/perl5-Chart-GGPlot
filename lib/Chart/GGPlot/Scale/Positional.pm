package Chart::GGPlot::Scale::Positional;

# Role for positional scale

use Chart::GGPlot::Role qw(:pdl);

# VERSION

use Chart::GGPlot::Types qw(:all);
use Types::Standard qw(ArrayRef CodeRef Str);

=attr position

=cut

has position => ( is => 'rw', isa => PositionEnum, default => "left" );

=method break_positions

    break_positons($range=$self->get_limits)

The numeric position of scale breaks, used by coord/guide.

=method axis_order

    axis_order()

Only relevant for positional scales.

=cut

method break_positions ($range=$self->get_limits()) {
    return $self->map_to_limits( $self->get_breaks($range) );
}

method axis_order () {
    my @ord = qw(primary secondary);
    if ( List::Util::any { $self->position eq $_ } qw(right bottom) ) {
        @ord = reverse @ord;
    }
    return \@ord;
}

1;

__END__

package Chart::GGPlot::Range;

# ABSTRACT: The role for range

use Chart::GGPlot::Role qw(:pdl);
use namespace::autoclean;

# VERSION

use Types::PDL qw(Piddle PiddleFromAny);

use Chart::GGPlot::Types qw(:all);

=attr range

For continuous range it has two elements to indicate the start
and end of the range. For discrete range the arrayref contains
the discrete items of the range.

=cut

has range => (
    is      => 'rw',
    isa     => Piddle->plus_coercions(PiddleFromAny),
    coerce  => 1,
    builder => '_build_range'
);

sub _build_range { null; }

=method reset()

Resets the range.

=cut

method reset () {
    $self->range( $self->_build_range );
}

=method train($piddle)

Train the range according to given data.

=cut

requires 'train';

1;

__END__

=pod

=head1 DESCRIPTION

Mutable ranges have two methods (C<train> and C<reset>), and make
it possible to build up complete ranges with multiple passes.


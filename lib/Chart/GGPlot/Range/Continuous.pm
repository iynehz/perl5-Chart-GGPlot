package Chart::GGPlot::Range::Continuous;

# ABSTRACT: Continuous range

use Chart::GGPlot::Class qw(:pdl);

# VERSION

with qw(Chart::GGPlot::Range);

use Types::PDL -types;

use Chart::GGPlot::Util qw(is_discrete range_);

method train ($p) {
    return $self->range if $p->isnull;

    if (is_discrete($p)) {
        die("Discrete value supplied to continuous scale");
    }
    my $range = range_( pdl( [ @{ $self->range->unpdl }, @{ $p->unpdl } ] ) );
    $self->range($range);

    return $self->range;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Range>


package Chart::GGPlot::Position::Fill;

# ABSTRACT: Position for "fill"

use Chart::GGPlot::Class;
use namespace::autoclean;

# VERSION

extends qw(Chart::GGPlot::Position::Stack);

sub fill { true }

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This class inherits L<Chart::GGPlot::Position::Stack>. Compared to "stack",
this class standardises each stack to have constant height.

=head1 SEE ALSO

L<Chart::GGPlot::Position>,
L<Chart::GGPlot::Position::Stack>


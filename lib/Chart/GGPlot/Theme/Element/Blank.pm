package Chart::GGPlot::Theme::Element::Blank;

# ABSTRACT: Blank theme element

use Chart::GGPlot::Class;
use namespace::autoclean;

# VERSION

with qw(Chart::GGPlot::Theme::Element);

classmethod parameters() { [] }

method grob (@rest) { zeroGrob(); }

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

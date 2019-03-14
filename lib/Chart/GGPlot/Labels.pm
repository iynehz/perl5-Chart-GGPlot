package Chart::GGPlot::Labels;

# ABSTRACT: Axis, legend, and plot labels

use Chart::GGPlot::Setup;
use namespace::autoclean;

# VERSION

use parent qw(Chart::GGPlot::Aes);

1;

__END__

=head1 DESCRIPTION

This class inherits L<Chart::GGPlot::Aes>.
Now it actually does nothing more than its parent class, but is just for
having its own type which is used by L<Chart::GGPlot::Plot>. 

=head1 SEE ALSO

L<Chart::GGPlot::Labels::Functions>, L<Chart::GGPlot::Aes>


package Chart::GGPlot::HasLabeller;

# ABSTRACT: The role for the 'labeller' attr

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(CodeRef Str);

use Chart::GGPlot::Types qw(Labeller);

=tmpl attr_labeller

=attr labeller

A L<Chart::GGPlot::Labeller> object, or a string of one of

for :list
*C<"value">
Only displays the value of a factor.
*C<"both">
Displays both the variable name and the factor.
*C<"context">
Context-dependent and uses C<"value"> for single factor
faceting and C<"both"> when multiple factors are involved.

=tmpl

=cut

has labeller => (
    is      => 'ro',
    isa     => Labeller,
    default => 'value',
    coerce  => 1
);

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Facet>

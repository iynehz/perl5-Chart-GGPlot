package Chart::GGPlot::HasNonMissingAes;

# ABSTRACT: The role for the 'non_missing_aes' attr

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(ArrayRef);

=attr non_missing_aes

This attr is for specifying additional variables to be used in
C<remove_missing()>.

=cut

has non_missing_aes => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

1;

__END__

=head1 DESCRIPTION


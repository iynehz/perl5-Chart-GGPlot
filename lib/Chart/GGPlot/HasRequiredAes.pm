package Chart::GGPlot::HasRequiredAes;

# ABSTRACT: The role for the 'required_aes' attr

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(ArrayRef);

=classmethod required_aes 

=cut

classmethod required_aes() { [] }

=method check_required_aes($aesthetics)

=cut

method check_required_aes($aesthetics) {
    my %aesthetics = map { $_ => 1 } @$aesthetics;
    my $missing_aes = $self->required_aes->grep(sub { !exists $aesthetics{$_} } );
    return if @$missing_aes == 0;

    croak( sprintf("%s requires the following missing aesthetics: %s",
        ref($self), join( ', ', @$missing_aes ) ));
}

1;

__END__

=head1 DESCRIPTION


package Data::Frame::More::Role::CompareResult;

# ABSTRACT: Role for column compare result

use Data::Frame::More::Setup;
use Moo::Role;
use namespace::autoclean;

# VERSION

use PDL::Core qw(null);
use Data::Frame::More::Types qw(DataFrame);

=attr both_bad

A data frame of the same dimensions as the two compared data frames.
It Indicates by the true values in it which columns/rows are both bad
in the two compared data frames.

=cut

has both_bad => (
    is      => 'rwp',
    isa     => DataFrame,
);

1;

__END__

package Data::Frame::More::Indexer::Role;

use Data::Frame::More::Role;

# VERSION

use Types::Standard qw(ArrayRef);
use Types::PDL qw(Piddle);

has indexer => (
    is       => 'ro',
    isa      => ( ArrayRef->plus_coercions( Piddle, sub { $_->unpdl } ) ),
    required => 1,
    coerce   => 1,
);

1;

__END__

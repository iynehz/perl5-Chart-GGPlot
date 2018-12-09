package Data::Frame::More::Indexer::Role;

use Data::Frame::More::Role;

# VERSION

use Types::Standard qw(ArrayRef);

has indexer => (is => 'ro', isa => ArrayRef, required => 1);

1;

__END__

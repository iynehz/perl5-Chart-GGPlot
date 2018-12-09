package Data::Frame::More::Types;

# ABSTRACT: Custom types

use strict;
use warnings;

# VERSION

use Type::Library -base, -declare => qw(
  DataFrame
  Indexer
  IndexerFromLabels
  IndexerFromIndices
);

use Type::Utils -all;
use Types::Standard -types;

declare DataFrame, as ConsumerOf ["Data::Frame::More"];

declare Indexer, as ConsumerOf ["Data::Frame::More::Indexer::Role"];
declare_coercion "IndexerFromLabels", to_type Indexer, from Any, via {
    require Data::Frame::More::Indexer;
    Data::Frame::More::Indexer::loc($_);
};
declare_coercion "IndexerFromIndices", to_type Indexer, from Any, via {
    require Data::Frame::More::Indexer;
    Data::Frame::More::Indexer::iloc($_);
};

1;

__END__

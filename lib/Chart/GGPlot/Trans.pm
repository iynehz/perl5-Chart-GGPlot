package Chart::GGPlot::Trans;

# ABSTRACT: Transformation

use Chart::GGPlot::Class qw(:pdl);

use Types::Standard qw(Str CodeRef);
use Types::PDL -types;

use Chart::GGPlot::Util qw(:all);

# VERSION

has name      => ( is => 'ro', isa => Str,     required => 1 );
has transform => ( is => 'ro', isa => CodeRef, required => 1 );
has inverse   => ( is => 'ro', isa => CodeRef, required => 1 );
has breaks    => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub { extended_breaks() },
);
has minor_breaks => (
    is      => 'ro',
    isa     => CodeRef,
    default => \&regular_minor_breaks,
);
has format => (
    is      => 'ro',
    isa     => CodeRef,
    default => sub { sub { $_[0] } },
);
has domain => (
    is      => 'ro',
    isa     => Piddle,
    default => sub { pdl([qw{-inf inf}]) },
);

method print () { "Transformer: @{[$self->name]}\n"; }

__PACKAGE__->meta->make_immutable;

1;



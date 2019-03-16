package Chart::GGPlot::Trans;

# ABSTRACT: Transformation class

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

use Types::Standard qw(Str CodeRef);
use Types::PDL -types;

use Chart::GGPlot::Util qw(:all);

# VERSION

=attr name

Name of the transformation object.

=attr transform

A coderef for the transform.

=attr inverse

A coderef for inverse of the transform.

=attr breaks

A coderef for generating the breaks. 

=attr minor_breaks

A coderef for generating the breaks. 

=attr format

A coderef that can be used for generating the break labels. 
The default behavior is that if the breaks piddle consumes
L<PDL::Role::HasNames> then its C<names()> method would be called to get
the labels, otherwise the labels would be from the breaks values.

=cut

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
    default => sub {
        sub {
            my ($x) = @_;
            return ( $x->$_call_if_can('names') // $x );
        }
    },
);
has domain => (
    is      => 'ro',
    isa     => Piddle,
    default => sub { pdl([qw{-inf inf}]) },
);

method print () { "Transformer: @{[$self->name]}\n"; }

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

A transformation object bundles together a transform, its inverse, and methods for
generating breaks and labels.


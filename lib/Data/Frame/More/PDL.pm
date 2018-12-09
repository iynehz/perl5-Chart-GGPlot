package Data::Frame::More::PDL;

# ABSTRACT: A mixin to add some methods to PDL

use strict;
use warnings;

# VERSION

use Role::Tiny;

use PDL::Core qw(pdl);
use PDL::Lite;
use PDL::Primitive qw(which);
use POSIX qw(ceil);
use Safe::Isa;
use Types::Standard qw(Int);
use Type::Params;

my $PositiveInt = Int->where( sub { $_ > 0 } );

=func length()

Returns the length of the first dimension.

=cut

sub length { $_[0]->dim(0); }

=func diff($lag=1)

=cut

sub diff {
    my ( $self, $lag ) = @_;
    $lag //= 1;

    my $idx = PDL->sequence( $self->length - $lag );
    return $self->slice( $idx + $lag ) - $self->slice($idx);
}

=func flatten()

This is same as C<@{$self-E<gt>unpdl}>.

=func flatten_deep()

This is same as C<list()>.

=cut

sub flatten { @{ $_[0]->unpdl }; }

sub flatten_deep { $_[0]->list; }

=func repeat($n)

Repeat on the first dimension for C<$n> times.

Only works with 1D piddle.  

=func repeat_to_length($length)

Repeat to have the given length.

Only works with 1D piddle.  

=cut

sub repeat {
    my ( $self, $n ) = @_;
    return $self->copy if ( $self->length == 0 or $n <= 1 );

    my $class = ref($self);

    my $p;
    if ( $self->$_DOES('PDL::SV') ) {
        $p = $class->new( [ ( @{ $self->unpdl } ) x $n ] );
    }
    elsif ( $self->$_DOES('PDL::Factor') ) {
        $p = $class->new(
            integer => [ ( @{ $self->unpdl } ) x $n ],
            levels => $self->levels
        );
    }
    else {
        my $data = [
            (
                $self->badflag
                ? ( map { $_ eq 'BAD' ? 0 : $_ } @{ $self->unpdl } )
                : ( @{ $self->unpdl } )
            ) x $n
        ];
        $p = $class->new($data);
    }

    if ( $self->badflag ) {
        $p = $p->setbadif( PDL::Core::pdl( [ ( $self->isbad->list ) x $n ] ) );
    }
    return $p;
}

sub repeat_to_length {
    my ( $self, $length ) = @_;
    return $self->copy if ( $self->length == 0 );

    my $x = $self->repeat( ceil( $length / $self->length ) );
    return ( $x->length == $length ? $x : $x->slice( "0:" . ( $length - 1 ) ) );
}

1;

__END__

=head1 DESCRIPTION

This module provides a role that can add a few methods to
the PDL class.

=head1 SEE ALSO

L<PDL>

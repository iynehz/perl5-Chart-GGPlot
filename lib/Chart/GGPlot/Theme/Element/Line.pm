package Chart::GGPlot::Theme::Element::Line;

# ABSTRACT: Line theme element

use Chart::GGPlot::Class;
use MooseX::Aliases;

# VERSION

use Types::Standard;

has color         => ( is => 'rw', alias => 'colour' );
has size          => ( is => 'rw' );
has linetype      => ( is => 'rw' );
has lineend       => ( is => 'rw' );
has arrow         => ( is => 'rw', default => sub { false } );
has inherit_blank => ( is => 'rw', default => sub { false } );

with qw(Chart::GGPlot::Theme::Element);

around parameters( $orig, $class : ) {
    return [
        qw(color size linetype lineend arrow inherit_blank),
        @{ $class->$orig() }
    ];
}

method grob (:$x, :$y,
            :$color=undef, :$colour=undef, :$size=undef,
            :$linetype=undef, :$lineend=undef,
            :$id_lengths=undef, %rest) {

    # The gp settings can override element_gp
    my $gp = gpar(
        lwd      => len0_null( ( $size // $self->size ) * pt() ),
        color    => $color // $colour // $self->color,
        linetype => $linetype // $self->linetype,
        lineend  => $lineend // $self->lineend,
    );
    return polyline_grob(
        x          => $x,
        y          => $y,
        gp         => $gp,
        id_lengths => $id_lengths,
        arrow      => $self->arrow,
        %rest
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

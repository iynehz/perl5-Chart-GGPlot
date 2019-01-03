package Chart::GGPlot::Theme::Element::Rect;

# ABSTRACT: Rectangular theme element

use Chart::GGPlot::Class;
use namespace::autoclean;
use MooseX::Aliases;

# VERSION

use Types::Standard;

use Chart::GGPlot::Util qw(pt);

=attr fill

Fill color.

=attr color (colour)

Line/border color.

=attr size

Line border size in mm; text size in pts.

=attr inherit_blank

Should this element inherit the existence of an
L<Chart::GGPlot::Theme::Element::Blank> among its parents?
If true the existance of a blank element among its parents
will cause this element to be blank as well.

=cut

has fill          => ( is => 'rw' );
has color         => ( is => 'rw', alias => 'colour' );
has size          => ( is => 'rw' );
has linetype      => ( is => 'rw' );
has inherit_blank => ( is => 'rw', default => sub { false } );

with qw(Chart::GGPlot::Theme::Element);

around parameters($orig, $class:) {
    return [qw(fill color size linetype inherit_blank), @{$class->$orig()} ];
}

method grob (:$x = 0.5, :$y = 0.5,
            :$width = 1, :$height = 1, :$fill = undef, :$color = undef, :$colour=undef,
            :$size = undef, :$linetype = undef, %rest) {

    # The gp settings can override element_gp
    my $gp = gpar(
        lwd      => len0_null( ( $size // $self->size ) * pt() ),
        color    => $color // $colour // $self->color,
        fill     => $fill // $self->fill,
        linetype => $linetype // $self->linetype,
    );
    return rect_grob(
        x      => $x,
        y      => $y,
        width  => $width,
        height => $height,
        gp     => $gp,
        %rest
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

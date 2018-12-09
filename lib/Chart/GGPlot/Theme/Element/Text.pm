package Chart::GGPlot::Theme::Element::Text;

# ABSTRACT: Text theme element

use Chart::GGPlot::Class;
use MooseX::Aliases;

# VERSION

use Types::Standard;

has family => ( is => 'rw' );
has face   => ( is => 'rw' );
has color  => ( is => 'rw', alias => 'colour' );
has size   => ( is => 'rw' );
has [qw(hjust vjust)] => ( is => 'rw' );
has angle         => ( is => 'rw' );
has lineheight    => ( is => 'rw' );
has margin        => ( is => 'rw' );
has inherit_blank => ( is => 'rw', default => sub { false } );

with qw(Chart::GGPlot::Theme::Element);

around parameters ($orig, $class:) {
    return [
        qw(
          family face color size hjust vjust
          angle lineheight margin inherit_blank
          ),
        @{$class->$orig()}
    ];
}

method grob (:$label = '', :$x, :$y,
            :$family = undef, :$face = undef, :$color = undef, :$colour = undef, :$size = undef,
            :$hjust = undef, :$vjust = undef, :$angle = undef,
            :$margin = undef, :$margin_x = false, :$margin_y = false,
            %rest) {

    if ( $label eq ''
        or ( Ref::Util::is_arrayref($label) and $label->length == 0 ) )
    {
        return zero_grob();
    }

    my $gp = gpar(
        fontsize   => $size // $self->size,
        col        => $color // $colour // $self->color,
        fontfamily => $self->family,
        fontface   => $self->face,
        lineheight => $self->lineheight
    );
    return title_grob(
        label    => $label,
        x        => $x,
        y        => $y,
        hjust    => $hjust // $self->hjust,
        vjust    => $vjust // $self->vjust,
        angle    => $angle // $self->angle // 0,
        margin   => $margin // $self->margin,
        margin_x => $margin_x,
        margin_y => $margin_y,
        %rest
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

package Chart::GGPlot::Position::Stack;

# ABSTRACT: Position for "stack"

use Chart::GGPlot::Class;
use namespace::autoclean;

# VERSION

use PDL::Primitive qw(which);

use Chart::GGPlot::Position::Util qw(collide pos_stack);

=attr reverse

If true, will reverse the default stacking order.
This is useful if you're rotating both the plot and legend.
Default is false.

=cut

has var     => ( is => 'ro' );
has vjust   => ( is => 'ro', default => 1 );
has reverse => ( is => 'ro', default => sub { false } );

with qw(Chart::GGPlot::Position);

sub fill { false }

method setup_params ($data) {
    return {
        var     => ( $self->var // $self->stack_var($data) ),
        vjust   => $self->vjust,
        fill    => $self->fill,
        reverse => $self->reverse
    };
}

method setup_data ($data, $params) {
    my $var = $params->at('var');
    if ( defined $var and length($var) ) {
        return $data;
    }

    my $ymax;
    if ( $var eq 'y' ) {
        $ymax = $data->at('y');
    }
    elsif ( $var eq 'ymax' and ( $data->at('ymax') == 0 )->all ) {
        $ymax = $data->at('ymin');
    }
    $data->set( 'ymax', $ymax ) if defined $ymax;

    remove_missing(
        $data,
        vars => [qw(x xmin xmax y)],
        name => 'position_stack'
    );
}

method compute_panel ($data, $params, $scales) {
    my $var = $params->at('var');
    unless ($var) {
        return $data;
    }

    my $negative = $data->at($var) < 0;
    my $neg      = $data->select_rows( which($negative) );
    my $pos      = $data->select_rows( which( !$negative ) );

    if ( $neg->nrow ) {
        $neg = collide( $neg, undef, 'position_stack', \&pos_stack,
            map { $_ => $params->at($_) } qw(vjust fill reverse) );
    }
    if ( $pos->nrow ) {
        $pos = collide( $pos, undef, 'position_stack', \&pos_stack,
            map { $_ => $params->at($_) } qw(vjust fill reverse) );
    }

    return $neg->rbind($pos);
}

classmethod stack_var ($data) {
    if ( $data->exists('ymax') ) {
        return 'ymax';
    }
    elsif ( $data->exists('y') ) {
        return 'y';
    }

    warn "Stacking requires either ymin & ymax or y aesthetics";
    return undef;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This stacks bars on top of each other.

=head1 SEE ALSO

L<Chart::GGPlot::Position>


package Chart::GGPlot::Coord::Cartesian;

# ABSTRACT: The Cartesian coordinate system

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use Types::Standard qw(Bool Overload);

use Chart::GGPlot::Util qw(:all);

=attr xlim

Limits for the x axis. 

=attr ylim

Limits for the y axis. 

=cut

has xlim => ( is => 'ro' );
has ylim => ( is => 'ro' );

has limits =>
  ( is => 'ro', lazy => 1, builder => '_build_limits', init_arg => undef );

sub _build_limits {
    my $self = shift;
    return { x => $self->xlim, y => $self->ylim };
}

=attr expand
    
If true, adds a small expansion factor to the limits to ensure
that data and axes do not overlap. If false, limits are taken
exactly from the data or C<xlim>/C<ylim>.

Default is true.

=cut 

has expand => ( is => 'ro', default => sub { true } );

=attr default

Is this the default coordinate system?

=cut

has default => (is => 'ro', default => sub { false } );

with qw(Chart::GGPlot::Coord);

has '+is_linear' => ( default => sub { false } );

method distance ($x, $y, $panel_params) {
    my $max_dist = dist_euclidean( $panel_params->at('x_range'),
        $panel_params->at('y_range') );
    return dist_euclidean( $x, $y ) / $max_dist;
}

method transform ($data, $panel_params) {
    my ( $rescale_x, $rescale_y ) = map {
        fun($data) { rescale( $data, $panel_params->at($_) ) };
    } qw(x_range y_range);
    $data = transform_position( $data, $rescale_x, $rescale_y );
    return transform_position( $data, squish_infinite(), squish_infiniate() );
}

method setup_panel_params ($scale_x, $scale_y, $params = {}) {
    my $train_cartesian = fun( $scale, $limits, $xy ) {
        my $range = $self->scale_range( $scale, $limits, $self->expand );
        my $out = $scale->break_info($range);
        $out->set('arrange', $scale->axis_order);
        return $out->rename({ map { $_ => "${xy}.$_" } @{$out->names} });
    };

    return {
        $train_cartesian->( $scale_x, $self->limits->at('x'), 'x' )->flatten,
        $train_cartesian->( $scale_y, $self->limits->at('y'), 'y' )->flatten,
    };
}

method scale_range ($scale, $limits=undef, $expand=true) {
    my $expansion = $expand ? $self->expand_default($scale) : pdl([ 0, 0 ]);

    if ( not defined $limits ) {
        return $scale->dimension($expansion);
    }
    else {
        my $range = range( $scale->transform($limits) );
        return expand_range( $range, $expansion->at(0), $expansion->at(1) );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

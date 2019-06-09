package Chart::GGPlot::Coord;

# ABSTRACT: The role for coordinates

use Chart::GGPlot::Role qw(:pdl);
use namespace::autoclean;

# VERSION

use Types::Standard qw(Bool);

# Renders the horizontal axes.
has render_axis_h => ( is => 'rw' );

# Renders the vertical axes.
has render_axis_v => ( is => 'rw' );

with qw(Chart::GGPlot::HasCollectibleFunctions);

=classmethod is_linear

    is_linear()

Returns true if the coordinate system is linear; false otherwise.

=cut 

classmethod is_linear() { false; }

=method render_bg($panel_params, $theme) 

Renders background elements.

=method render_axis_h($panel_params, $theme)

Renders the horizontal axes.

=method render_axis_v($panel_params, $theme)

Renders the vertical axes.

=method range($panel_params)

Returns the x and y ranges.

=method transform($data, $range)

Transforms x and y coordinates.

=method distance($x, $y, $panel_params)

Calculates distance.

=method setup_data($data, $params)

Allows the coordinate system to manipulate the plot data.
Returns a hash ref of dataframes.

=method setup_layout($layout, $params)

Allows the coordinate system to manipulate the "layout" data frame
which assigns data to panels and scales.

=cut

requires 'transform';
requires 'distance';

# Returns the desired aspect ratio for the plot.
method aspect () { return; }

# Returns a list containing labels for x and y.
method labels ($panel_params) { $panel_params }

method range ($panel_params) {
    return {
        x => $panel_params->at('x_range'),
        y => $panel_params->at('y_range'),
    };
}

method setup_panel_params ($scale_x, $scale_y, $params = {}) { {}; }

method setup_params ($data)  { {}; }
method setup_data ($data, $params)  { $data }
method setup_layout ($layout, $params) { $layout }

# Optionally, modifies list of x and y scales in place. Currently
# used as a fudge for CoordFlip and CoordPolar
method modify_scales ($scales_x, $scales_y) { }

classmethod expand_default ($scale,
        $discrete = [0, 0.6, 0, 0.6], $continuous = [0.05, 0, 0.05, 0]) {
    return (
        (
            $scale->expand
              // ( $scale->$_DOES('Chart::GGPlot::Scale::Discrete') )
        )
        ? $discrete
        : $continuous
    );
}

1;

__END__

=head1 DESCRIPTION

This module is a Moose role for "coord".

For users of Chart::GGPlot you would mostly want to look at
L<Chart::GGPlot::Coord::Functions> instead.


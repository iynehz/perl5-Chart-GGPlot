package Chart::GGPlot::Facet;

# ABSTRACT: The facet class

use Chart::GGPlot::Role qw(:pdl);
use namespace::autoclean;

# VERSION

use Data::Munge qw(elem);
use Eval::Closure;
use List::AllUtils qw(firstidx);
use Types::Standard qw(ArrayRef Bool CodeRef);

#use Chart::GGPlot::LegendDraw qw(:all);
use Chart::GGPlot::Params;
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

has shrink => ( is => 'ro', default => sub { false } );
has params => (
    is      => 'ro',
    isa     => GGParams,
    coerce  => 1,
    default => sub { Chart::GGPlot::Params->new(); }
);

method setup_params ($data, $params) { $params }
method setup_data ($data, $params) { $data }

=method compute_layout($data, $params)

Based on layer data compute a mapping between panels, axes, and potentially
other parameters such as faceting variable level etc. This method must
return a data.frame containing at least the columns "PANEL", "SCALE_X",
and "SCALE_Y" each containing integer keys mapping a PANEL to which axes
it should use. In addition the data frame can contain whatever other
information is necessary to assign observations to the correct panel as
well as determining the position of the panel.

=method map_data($data, $layout, $params)

This method is supplied the data for each layer in turn and is expected to
supply a "PANEL" column mapping each row to a panel defined in the layout.
Additionally this method can also add or subtract data points as needed
e.g. in the case of adding margins to "facet_grid".

=cut

=method init_scales

    init_scales($layout, $params, :$x_scales=undef, :$y_scales=undef)

Given a master scale for x and y, create panel specific scales for each
panel defined in the layout.
The default is to simply clone the master scale.

=cut

method init_scales ($layout, $params, :$x_scale=undef, :$y_scale=undef) {
    my $scales = {};
    if ( defined $x_scale ) {
        $scales->{x} = [ ( $x_scale->clone ) x ($layout->at('SCALE_X')->max+1) ];
    }
    if ( defined $y_scale ) {
        $scales->{y} = [ ( $y_scale->clone ) x ($layout->at('SCALE_Y')->max+1) ];
    }
    return $scales;
}

=method train_scales

    train_scales($data, $layout, $params,
                 :$x_scales=undef, :$y_scales=undef)

Based on layer data train each set of panel scales.
The default is to train it on the data related to the panel.

=cut

method train_scales (ArrayRef $data, $layout, $params,
        :$x_scales=undef, :$y_scales=undef) {
    # loop over each layer, training x and y scales in turn
    for my $layer_data (@$data) {
        my $match_id =
          pdl( match( $layer_data->at('PANEL'), $layout->at('PANEL') ) );

        my $do_axis = fun( $axis, $scales ) {
            my $column_name = "SCALE_" . uc($axis);
            my $vars =
              $scales->at(0)->aesthetics->intersect($layer_data->names);
            my $SCALE = $layout->at($column_name)->slice($match_id);
            Chart::GGPlot::Layout->scale_apply( $layer_data, $vars, "train",
                $SCALE, $scales );
        };

        if ( defined $x_scales ) {
            &$do_axis( 'x', $x_scales );
        }
        if ( defined $y_scales ) {
            &$do_axis( 'y', $y_scales );
        }
    }
    return;
}

=method finish_data

    finish_data($data, $layout, $params,
                :$x_scales, :$y_scales)

Make last-minute modifications to layer data before it is rendered by the
Geoms.
The default is to not modify it.

=cut

method finish_data ($data, $layout, $params,
        :$x_scales, :$y_scales) { $data }

=classmethod render_axes($x, $y, $coord, $theme, $transpose=false)

Render panel axes.

Returns a hash ref with keys "x" and "y", each containing axis
specifications for the ranges passed in. Each axis specification is a hash
ref with a set of "top" and "bottom" or "left" and "right" keys,
holding the respective axis grobs. If C<transpose> is true the content
of the x and y elements will be transposed.

=cut

classmethod render_axes ($x, $y, $coord, $theme, $transpose=false) {
    my $axes = {};
    if ( defined $x ) {
        $axes->{x} = [ $x->map( sub { $coord->render_axis_h( $_, $theme ) } ) ];
    }
    if ( defined $y ) {
        $axes->{y} = [ $y->map( sub { $coord->render_axis_v( $_, $theme ) } ) ];
    }
    if ($transpose) {
        $axes->{x} = {
            top    => $axes->{x}->{top},
            bottom => $axes->{x}->{bottom}
        };
        $axes->{y} = {
            left   => $axes->{y}->{left},
            bottom => $axes->{y}->{right}
        };
    }
    return $axes;
}

=classmethod render_strips($x, $y, $labeller, $theme)

Render panel strips.

Returns a hashref with keys "x" and "y", each is a hash ref containing
a set of "top" and "bottom" or "left" and "right" keys respectively. These
contains a hash ref of rendered strips as gtables.

=cut

classmethod render_strips ($x, $y, $labeller, $theme) {
    return {
        x => $class->_build_strip( $x, $labeller, $theme, true ),
        y => $class->_build_strip( $y, $labeller, $theme, false ),
    };
}

# Evaluate variables in a facet specification.
# Returns a hashref with keys be names of the variables.
classmethod _eval_facet_vars ($vars, $data, $env = {}) {
    my $names = $vars->names;
    my $out   = {
        $names->map(
            sub { $_ => $class->_eval_facet_var( $vars->at($_), $data, $env ) }
        )->flatten
    };
    return $out;
}

# Evaluate a single variable in a facet specification.
classmethod _eval_facet_var ($var, $data, $env = {}) {
    if ( $data->exists($var) ) {
        return $data->at($var);
    }
    else {
        my $evaled = eval_closure(
            source      => $var,
            environment => $env,
        );
        return call_if_coderef($evaled);
    }
}

classmethod check_coord_freedom ($coord) {
    if (
        List::AllUtils::any { $coord->$_isa("Chart::GGPlot::$_") }
        qw(Cartesian Flip)
      )
    {
        return;
    }
    die(
q{Free scales are only supported with 'coord_cartesian()' and 'coord_flip()'}
    );
}

classmethod check_layout ($layout) {
    my $layout_names = $layout->names;
    unless (
        List::AllUtils::all { elem( $_, $layout_names ) }
        qw(PANEL SCALE_X SCALE_Y)
      )
    {
        die(    "Facet layout has bad format. "
              . "It must contain columns 'PANEL', 'SCALE_X', and 'SCALE_Y'" );
    }
}

classmethod layout_null () {
    return Data::Frame::More->new(
        columns => [
            PANEL   => pdl([0]),
            ROW     => pdl([0]),
            COL     => pdl([0]),
            SCALE_X => pdl([0]),
            SCALE_Y => pdl([0])
        ]
    );
}

1;

__END__

=head1 DESCRIPTION

A "facet" object describes how to assign data to different panels, how to
apply positional scales and how to layout the panels, once rendered. 

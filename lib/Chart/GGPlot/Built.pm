package Chart::GGPlot::Built;

# ABSTRACT: A processed ggplot that can be rendered

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use List::AllUtils qw(pairmap);
use Types::Standard qw(ArrayRef);

use Chart::GGPlot::Types qw(:all);

=attr data

An arrayref of data frames, one for each layer's processed data that would
later be used for rendering the plot.

=attr layout

A L<Chart::GGPlot::Layout> object, which contains info about axis limits,
breaks, etc.

=attr plot

The L<Chart::GGPlot::Plot> object from which the L<Chart::GGPlot::Built>
object is created.

=cut

has data   => ( is => 'ro' );
has layout => ( is => 'ro' );
has plot   => ( is => 'ro' );

=method layer_data

    layer_data($i=0)

Helper function that returns the data associated with a given layer.
C<$i> is the index of layer.

    my $data = $ggplot->layer_data(0);

=method layer_scales

    layer_scales($i=0, $j=0)

Helper function that returns the scales associated with a given layer.
Returns a hashref of x and y scales for the layer at row C<$i> and
column C<$j>.

=cut

method layer_data ( $i = 0 ) {
    return $self->data->at($i);
}

method layer_scales ( $i = 0, $j = 0 ) {
    my $layout = $self->layout->layout;

    my $which =
      ( which( $layout->at('ROW') == $i ) & which( $layout->at('COL') == $j ) );
    my $selected = $layout->select_rows($which);
    return {
        x => $self->layout->panel_scales_x->at( $selected->at('SCALE_X') ),
        y => $self->layout->panel_scales_y->at( $selected->at('SCALE_Y') ),
    };
}

#method summarize_layout () {
#    my $l = $self->layout;
#
#    my $layout =
#      [qw(panel row col)]->map( sub { $l->layout->at( uc( $_[0] ) ) } );
#
#    my $facet_vars = $l->facet->vars();
#
#    # Add a list-column of panel vars (for facets).
#    #$layout->at('vars') =
#
#    return $layout;
#}

1;

__END__

=head1 DESCRIPTION

This class represents a processed L<Chart::GGPlot::Plot> object that can
be rendered.
A L<Chart::GGPlot::Backend> consumer generates an object of this class as
an intermediate form during rendering a L<Chart::GGPlot::Plot> object.
    
=head1 SEE ALSO

L<Chart::GGPlot::Plot>,
L<Chart::GGPlot::Backend>


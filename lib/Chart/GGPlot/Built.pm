package Chart::GGPlot::Built;

# ABSTRACT: A processed ggplot that can be rendered

use Chart::GGPlot::Class qw(:pdl);

# VERSIONS

use List::AllUtils qw(pairmap);
use Types::Standard qw(ArrayRef);

use Chart::GGPlot::Types qw(:all);

has data   => ( is => 'ro' );
has layout => ( is => 'ro' );
has plot   => ( is => 'ro' );

=method layer_data($self, $i=0)

Helper function that returns the data associated with a given layer.

=method layer_scales($self, $i=0, $j=0)

Helper function that returns the scales associated with a given layer.

=cut

method layer_data ( $i = 0 ) {
    return $self->data->at($i);
}

method layer_scales ( $i = 0, $j = 0 ) {
    my $layout = $self->layout->layout;

    #TODO
    my $selected = $layout->at();
    return {
        x => $self->layout->panel_scales_x->at( $selected->SCALE_X ),
        y => $self->layout->panel_scales_y->at( $selected->SCALE_Y ),
    };
}

method summarize_layout () {
    my $l = $self->layout;

    my $layout =
      [qw(panel row col)]->map( sub { $l->layout->at( uc( $_[0] ) ) } );

    my $facet_vars = $l->facet->vars();

    # Add a list-column of panel vars (for facets).
    #$layout->at('vars') =

    return $layout;
}

1;

__END__

=head1 DESCRIPTION

This class represents a processed ggplot object that can be rendered.
    
=head1 SEE ALSO

L<Chart::GGPlot::Functions>


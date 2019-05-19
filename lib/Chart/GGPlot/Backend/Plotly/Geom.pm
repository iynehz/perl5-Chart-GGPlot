package Chart::GGPlot::Backend::Plotly::Geom;

# ABSTRACT: Role for geom-specific details with the Plotly backend

use Chart::GGPlot::Role;

# VERSION

use List::AllUtils qw(pairmap);
use Types::Standard qw(ArrayRef);

use Chart::GGPlot::Backend::Plotly::Util qw(br);

=method use_webgl

    use_webgl($df)

Returns a boolean value for whether or not to use webgl, like for scatter
plots where Plotly is very slow to generate SVG when the data count is large.
Now it decides by comparing the data count in C<$df> against variable
C<$Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD>.
The variable can be adjusted by like,

    $Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD = 2000;

=cut 

method use_webgl ($df) {
    my $threshold = $Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD;
    return 0 if ( $threshold < 0 );
    return ( $df->nrow > $threshold );
}

=method to_traces

    to_traces($df, $params, $plot)

This shall be implemented by consumers of this role.
It should return an arrayref of Chart::Plotly::Trace::X objects.  

=cut

requires 'to_traces';

=method make_hovertext

    make_hovertext($df, ArrayRef $hover_labels)

This method is called by L<Chart::GGPlot::Backend::Plotly> for preparing
Plotly hovertext.
C<$hover_labels> is an associative arrayref that maps aes names to hover
text labels.
   
=cut

classmethod make_hovertext ($df, ArrayRef $hover_labels) {
    my %seen_hover_aes;
    my @hover_assoc = pairmap {
        my ( $aes, $var ) = ( $a, $b );
        if ( !ref($var) and $seen_hover_aes{$var}++ ) {
            ();
        }
        else {
            if ( $var->$_DOES('Eval::Quosure') ) {
                $var = $var->expr;
            }
            my $data = $class->_hovertext_data_for_aes( $df, $aes );
            return ( defined $data ? ( $var => $data->as_pdlsv ) : () );
        }
    }
    @$hover_labels;

    return [ 0 .. $df->nrow - 1 ]->map(
        sub {
            join( br(), pairmap { "$a: " . $b->at($_) } @hover_assoc );
        }
    );
}

classmethod _hovertext_data_for_aes ($df, $aes) {
    return (
          $df->exists("${aes}_raw") ? $df->at("${aes}_raw")
        : $df->exists($aes)         ? $df->at($aes)
        :                             undef
    );
}

classmethod to_basic($data, $prestats_data, $layout, $params, $plot) {
    return $data;
}

classmethod _adjust_trace_for_flip ($trace, $plot) {
    if ( $plot->coordinates->DOES('Chart::GGPlot::Coord::Flip') ) {
        my ( $x, $y ) = ( $trace->x, $trace->y );
        $trace->x($y);
        $trace->y($x);
        $trace->$_call_if_can( 'orientation', 'h' );

        my $error_x = $trace->$_call_if_can('error_x');
        my $error_y = $trace->$_call_if_can('error_y');
        $trace->error_x($error_y) if $error_y;
        $trace->error_y($error_x) if $error_x;
    }
    return $trace;
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly>

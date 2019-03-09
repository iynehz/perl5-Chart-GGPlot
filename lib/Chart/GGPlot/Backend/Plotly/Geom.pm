package Chart::GGPlot::Backend::Plotly::Geom;

# ABSTRACT: Role for geom-specific details with the Plotly backend

use Chart::GGPlot::Role;

# VERSION

use List::AllUtils qw(pairmap);

use Chart::GGPlot::Backend::Plotly::Util qw(br);

=method use_webgl

    use_webgl($df)

Returns a boolean value for whether or not to use webgl, like for scatter plots.
Now it decides by comparing the data count in C<$df> against module variable
C<$WEBGL_THRESHOLD>. The variable can be adjusted by like,

    $Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD = 2000;

=cut 

method use_webgl ($df) {
    my $threshold = $Chart::GGPlot::Backend::Plotly::WEBGL_THRESHOLD;
    return 0 if ( $threshold < 0 );
    return ( $df->nrow > $threshold );
}

=method to_trace

    to_trace($df, %rest)

This shall be implemented by consumers of this role.

=cut

requires 'to_trace';

=method make_hovertext

    make_hovertext($df, $aes_names)
   
=cut

classmethod make_hovertext ($df, $hover_labels) {
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

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly>

package Chart::GGPlot::Backend::Plotly::Geom::Rect;

# ABSTRACT: Chart::GGPlot's Plotly implementation for Geom::Rect

use Chart::GGPlot::Class;

# VERSION

extends qw(Chart::GGPlot::Backend::Plotly::Geom::Polygon);

use List::AllUtils qw(reduce);

classmethod prepare_data ($data, @rest) {
    $data->set( 'group', PDL->sequence( $data->nrow ) );
    my ( $xmin, $xmax, $ymin, $ymax ) =
      map { $data->at($_) } qw(xmin xmax ymin ymax);
    my $data1 = $data->copy;
    $data1->set( 'x', $xmin );
    $data1->set( 'y', $ymin );
    my $data2 = $data->copy;
    $data2->set( 'x', $xmin );
    $data2->set( 'y', $ymax );
    my $data3 = $data->copy;
    $data3->set( 'x', $xmax );
    $data3->set( 'y', $ymax );
    my $data4 = $data->copy;
    $data4->set( 'x', $xmax );
    $data4->set( 'y', $ymin );

    return ( reduce { $a->rbind($b); } ( $data1, $data2, $data3, $data4 ) );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Backend::Plotly::Geom>,
L<Chart::GGPlot::Geom::Rect>


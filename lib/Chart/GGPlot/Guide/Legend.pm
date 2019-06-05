package Chart::GGPlot::Guide::Legend;

# ABSTRACT: Legend guide

use Chart::GGPlot::Setup;

# VERSION

use parent qw(Chart::GGPlot::Guide);

use Data::Frame;

sub BUILD {
    my ($self, $args) = @_;

    $self->set( 'key', {} );
}   

method train ($scale, $aesthetic=undef) {
    my $breaks = $scale->get_breaks();
    if ($breaks->length == 0 or $breaks->ngood == 0) {
        return;
    }

    my $aes_column_name = $aesthetic // $scale->aesthetics->[0];
    my $key = Data::Frame->new(
        columns => [
            $aes_column_name => $scale->map_to_limits($breaks),
            label            => $scale->get_labels($breaks),
        ]
    );

    if ( $self->reverse ) { 
        $key = $self->_reverse_df($key);
    }   

    $self->set('key', $key);

    return $self;
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Guide>


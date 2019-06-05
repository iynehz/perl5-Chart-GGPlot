package Chart::GGPlot::Guide::Colorbar;

# ABSTRACT: Colorbar guide

use Chart::GGPlot::Setup;
use Class::Method::Modifiers;

# VERSION

use Data::Frame;

use Chart::GGPlot::Util qw(seq_n);

use parent qw(Chart::GGPlot::Guide);

=attr bar

=attr nbin

=attr available_aes

=cut

for my $attr (qw(bar nbin available_aes)) {
    no strict 'refs';
    *{$attr} = sub { $_[0]->at($attr) };
}

sub BUILD {
    my ($self, $args) = @_;

    $self->set( 'nbin', 20 );
    $self->set( 'available_aes', [qw(colour color fill)] );
};

method train ($scale, $aesthetic=undef) {
    if ( @{ $scale->aesthetics->intersect( $self->available_aes ) } == 0 ) {
        warn sprintf( "colorbar guide needs appropriate scales: %s",
            join( ', ', @{ $self->available_aes } ) );
        return;
    }
    if ( $scale->$_DOES('Chart::GGPlot::Scale::Discrete') ) {
        warn "colorbar guide needs continuous scales.";
        return;
    }

    my $breaks = $scale->get_breaks();
    if ( $breaks->length == 0 or $breaks->ngood == 0 ) {
        return;
    }

    my $aes_column_name = $aesthetic // $scale->aesthetics->[0];
    my $ticks           = Data::Frame->new(
        columns => [
            $aes_column_name => $scale->map_to_limits($breaks),
            value            => $breaks,
            label            => $scale->get_labels($breaks),
        ]
    );

    my $limits = $scale->get_limits();
    my $bar    = seq_n( $limits->at(0), $limits->at(1), $self->nbin );
    if ( $bar->length == 0 ) {
        $bar = $limits->uniq;
    }
    $bar = Data::Frame->new(
        columns => [
            color => $scale->map_to_limits($bar),
            value => $bar,
        ]
    );

    if ( $self->reverse ) {
        $ticks = $self->_reverse_df($ticks);
        $bar   = $self->_reverse_df($bar);
    }
    $self->set( 'key', $ticks );
    $self->set( 'bar', $bar );

    return $self;
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Guide>


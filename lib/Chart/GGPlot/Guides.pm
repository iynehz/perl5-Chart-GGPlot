package Chart::GGPlot::Guides;

# ABSTRACT: The container of guides

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use Data::Munge qw(elem);
use Module::Load;

has _guides => (is => 'ro', default => sub { {} });

=method build

=cut

my $defined_or = sub {
    my ( $obj, $attr, $or ) = @_;

    # Have to make $or a coderef. Too bad Perl 5 does not support macros.
    unless ( defined $obj->{$attr} ) {
        $obj->{$attr} = $or->();
    }
};

# Train each scale in scales and generate the definition of guide.
method build ($scales, :$labels, %rest) {
    for my $scale ($scales->scales->flatten) {
        for my $output ( $scale->aesthetics->flatten ) {
            my $guide = $self->get_guide($output) // $scale->guide;

            next unless (defined $guide and $guide ne 'none');

            # Check the validity of guide.
            # If guide is a string, then find the guide object.
            $guide = $self->_validate_guide($guide);

            # Check the consistency of the guide and scale.
            my $guide_available_aes = $guide->available_aes;
            if ( defined $guide_available_aes
                and !elem( $scale->aesthetics, $guide_available_aes ) )
            {
                die sprintf( "Guide %s cannot be used for %s.",
                    $guide, $scale->aesthetics );
            }

            unless (defined $guide->title) {
                $guide->set('title', $scale->make_title( $scale->name // $labels->at($output) ));
            }
            $self->set($output, $guide);
        }
    }
}

method set($key, $guide) { $self->_guides->{$key} = $guide; }
method get_guide($key) { $self->_guides->{$key}; }

method guides() {
    my $guides = $self->_guides;
    return [ map { $guides->{$_} } sort keys %$guides ];
}

classmethod _validate_guide ($guide) {
    if ($guide->$_DOES('Chart::GGPlot::Guide')) {
        return $guide;
    } else {
        my $class_guide = 'Chart::GGPlot::Guide::' . ucfirst($guide);
        load $class_guide;
        return $class_guide->new;
    }
}

1;

__END__

=pod


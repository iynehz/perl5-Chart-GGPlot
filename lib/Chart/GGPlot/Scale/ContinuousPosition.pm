package Chart::GGPlot::Scale::ContinuousPosition;

# ABSTRACT: Continuous position scale

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use Types::PDL qw(Piddle PiddleFromAny);
use Types::Standard qw(InstanceOf Maybe);

use Chart::GGPlot::Util qw(:all);

extends qw(
  Chart::GGPlot::Scale::Continuous
);

has secondary_axis => (
    is      => 'ro',
    isa     => Maybe [ InstanceOf ['Chart::GGPlot::AxisSecondary'] ],
    default => undef,
);

with qw(
    Chart::GGPlot::Scale::Positional
);

has '+limits' => (
    isa     => Piddle->plus_coercions(PiddleFromAny),
    coerce  => 1,
);

method map_to_limits ( $p, $limits = $self->get_limits ) {
    my $scaled = $self->oob->( $p, $limits );
    $scaled->setbadtoval($self->na_value);
    return $scaled;
}

method break_info ($range = pdl->null) {
    my $breaks = $self->SUPER::break_info($range);
    if ( defined $self->secondary_axis
        and not $self->secondary_axis->empty() )
    {
        $self->secondary_axis->init($self);
        $breaks = [
            $breaks->flatten,
            $self->secondary_axis->break_info( $breaks->range, $self )->flatten
        ];
    }
    return $breaks;
}

method sec_name () {
    return unless ( defined $self->secondary_axis );
    return $self->secondary_axis->name;
}

method make_sec_title ($title) {
    unless ( defined $self->secondary_axis ) {
        return $self->SUPER::make_sec_title($title);
    }
    return $self->secondary_axis->make_title($title);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

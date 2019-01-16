package Chart::GGPlot::Scale::SupportsSecondaryAxis;

# ABSTRACT: Role for scales that support secondary axis

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(InstanceOf Maybe);

has secondary_axis => (
    is      => 'ro',
    isa     => Maybe [ InstanceOf ['Chart::GGPlot::AxisSecondary'] ],
);

method sec_name () {
    return $self->secondary_axis->$_call_if_can('name');
}

method make_sec_title ($title) {
    if ( defined $self->secondary_axis ) {
        return $self->secondary_axis->make_title($title);
    } else {
        return $self->SUPER::make_sec_title($title);
    }
}

1;

__END__

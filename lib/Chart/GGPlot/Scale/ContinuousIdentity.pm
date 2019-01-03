package Chart::GGPlot::Scale::ContinuousIdentity;

# ABSTRACT: Continuous identity scale

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use Chart::GGPlot::Util qw(:all);

extends qw(
  Chart::GGPlot::Scale::Continuous
);

method map_to_limits ( $p, $limits = $self->get_limits ) {
    if (is_factor($p)) {
        return as_character($p);
    } else {
        return $p;
    }
}

around train ($p) {
    return if $self->guide eq 'none';
    return $self->$orig($p);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

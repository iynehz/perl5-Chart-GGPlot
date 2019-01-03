package Chart::GGPlot::Scale::DiscreteIdentity;

# ABSTRACT: Discrete identity scale

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

# VERSION

use Chart::GGPlot::Util qw(:all);

extends qw(
  Chart::GGPlot::Scale::Discrete
);

method map_to_limits ( $p, $limits = $self->get_limits ) {
    if (is_factor($p)) {
        return as_character($p);
    } else {
        return $p;
    }
}

method train ($p) {
    return if $self->guide eq 'none';
    $self->SUPER::train($p);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

package Chart::GGPlot::Theme::Element::Rel;

# ABSTRACT: To specify sizes relative to the parent

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);

# VERSION

use overload '*' => fun( $self, $other, $swap ) { $self->value * $other },
  fallback       => 1;

# do not use Moose as this class is too simple.
classmethod new ($x) {
    return ( bless \$x, $class );
}

method value () {
    return $$self;
}

1;

__END__

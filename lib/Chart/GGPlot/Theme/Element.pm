package Chart::GGPlot::Theme::Element;

# ABSTRACT: The role for theme elements

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(Bool);

has debug => ( is => 'rw', default => sub { false } );

with qw(MooseX::Clone);

=classmethod parameters()

=method grob()

Generate grid grob from theme element.

=method as_hashref()

=method string()

=cut

classmethod parameters () {
    return [qw(debug)];
}

method grob () { ... }

method as_hashref () {
    return {
        (
            map {
                my $value = $self->$_;
                my $attr = $self->meta->get_attribute($_);
                if ( $attr->type_constraint->$_call_if_can('equals', Bool) ) {
                    $value = $value ? true : false;
                } elsif (my $href = $value->$_call_if_can('as_hashref')) {
                    $value = $href;
                }
                $_ => $value;
            } @{$self->parameters}
        )
    };
}

method string () {
    return Dumper($self);
}

1;

__END__

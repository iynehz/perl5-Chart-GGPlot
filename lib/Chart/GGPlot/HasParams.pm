package Chart::GGPlot::HasParams;

# ABSTRACT: The role for the 'extra_params' thing

use Chart::GGPlot::Role;

# VERSION

use Types::Standard qw(ArrayRef);

=classmethod extra_params

    my $extra_params_names = $obj->extra_params();

Array ref for additional parameters that may be needed.
Default is C<['na_rm']>.

=cut

# used by parameters()
has _parameters => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] }
);

classmethod extra_params() { [qw(na_rm)] }

# R ggplot2's Geom parameters() function automatically gets params from
# draw_panel and draw_group methods via introspection on the method
# arguments. Although Perl Function::Parameters supports introspection,
# I would try it in future and for now do it in a "dumb" way.
method parameters( $extra = false ) {
    my $args = $self->_parameters;
    if ($extra) {
        $args = $args->union( $self->extra_params );
    }
    return $args;
}

1;

__END__

=head1 DESCRIPTION


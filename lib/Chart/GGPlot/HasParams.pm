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

=classmethod _parameters

This method is called internally by the C<parameters> method of this role.
This is for consumers of the role to override the result of C<parameters>
if necessary. Default is C<[]>. 

=cut

# used by parameters()
classmethod _parameters() { [] }

classmethod extra_params() { [qw(na_rm)] }

=classmethod parameters

    parameters($extra=false)

If C<$extra> is true, returns a union of C<extra_params()> and
C<_parameters()>. If C<$extra> is false, returns C<_parameters()>.

=cut

# R ggplot2's Geom parameters() function automatically gets params from
# draw_panel and draw_group methods via introspection on the method
# arguments. Although Perl Function::Parameters supports introspection,
# I would now do it in a "dumb" way.
classmethod parameters( $extra = false ) {
    my $args = $class->_parameters;
    if ($extra) {
        $args = $args->union( $class->extra_params );
    }
    return $args;
}

1;

__END__

=head1 DESCRIPTION


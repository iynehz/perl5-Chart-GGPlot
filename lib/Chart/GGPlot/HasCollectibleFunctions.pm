package Chart::GGPlot::HasCollectibleFunctions;

# ABSTRACT: The role for the 'ggplot_functions' classmethod

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

=classmethod ggplot_functions

    ggplot_functions()

Returns an arrayref like below,

    [
        {
            name => $func_name,
            code => $func_coderef,
            pod  => $pod,           # function doc
        },
        ...
    ]

=cut

requires 'ggplot_functions';

1;

__END__

=head1 DESCRIPTION


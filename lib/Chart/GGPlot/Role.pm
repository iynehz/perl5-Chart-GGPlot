package Chart::GGPlot::Role;

# ABSTRACT: For creating roles in Chart::GGPlot

use strict;
use warnings;

# VERSION

use Chart::GGPlot::Setup ();

sub import {
    my ( $class, @tags ) = @_;
    Chart::GGPlot::Setup->_import( scalar(caller), qw(:role), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Chart::GGPlot::Role;

=head1 DESCRIPTION

C<use Chart::GGPlot::Role ...;> is equivalent of

    use Chart::GGPlot::Setup qw(:role), ...;

=head1 SEE ALSO

L<Chart::GGPlot::Setup>


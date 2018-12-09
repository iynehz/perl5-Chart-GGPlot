package Chart::GGPlot::Class;

# ABSTRACT: For creating classes in Chart::GGPlot

use strict;
use warnings;

# VERSION

use Chart::GGPlot::Setup ();

sub import {
    my ( $class, @tags ) = @_;
    Chart::GGPlot::Setup->_import( scalar(caller), qw(:class), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Chart::GGPlot::Class;

=head1 DESCRIPTION

C<use Chart::GGPlot::Class ...;> is equivalent of 

    use Chart::GGPlot::Setup qw(:class), ...;

=head1 SEE ALSO

L<Chart::GGPlot::Setup>


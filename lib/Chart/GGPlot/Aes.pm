package Chart::GGPlot::Aes;

# ABSTRACT: Aesthetic mappings

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);

# VERSION

use parent qw(Chart::GGPlot::Params);

use List::AllUtils qw(pairmap);
use namespace::autoclean;

my @all_aesthetics = (
    "adj",    "alpha",    "angle",      "bg",
    "cex",    "col",      "color",      "colour",
    "fg",     "fill",     "group",      "hjust",
    "label",  "linetype", "lower",      "lty",
    "lwd",    "max",      "middle",     "min",
    "pch",    "radius",   "sample",     "shape",
    "size",   "srt",      "upper",      "vjust",
    "weight", "width",    "x",          "xend",
    "xmax",   "xmin",     "xintercept", "y",
    "yend",   "ymax",     "ymin",       "yintercept",
    "z"
);

my %base_to_ggplot = (
    "col"    => "color",
    "colour" => "color",
    "pch"    => "shape",
    "cex"    => "size",
    "lty"    => "linetype",
    "lwd"    => "size",
    "srt"    => "angle",
    "adj"    => "hjust",
    "bg"     => "fill",
    "fg"     => "color",
    "min"    => "ymin",
    "max"    => "ymax"
);

# Overrides the same method in Chart::GGPlot::Params.
classmethod transform_key ($key) {
    return ( $base_to_ggplot{$key} // $key );
}

classmethod all_aesthetics () { \@all_aesthetics; }

method keys () { [ sort( @{ $self->SUPER::keys() } ) ]; }

method make_labels () {
    my %labels = List::AllUtils::pairmap {
        $a => ( $b->$_DOES('Eval::Quosure') ? $b->expr : $b . '' )
    }
    $self->flatten;
    return \%labels;
}

=classmethod check_aesthetics
    
    check_aesthetics($aes, $n=undef)

Checks if all values in the C<$aes> object are of length C<$n> or C<1>.
Dies on check failure. C<$aes> can be either a L<Chart::GGPlot::Aes> object
or a data frame object. If C<$n> is not specified, it defaults to the max
length of values (or columns) of C<$aes>. 

=cut

classmethod check_aesthetics ($aes, $n=undef) {
    unless ( defined $n ) {
        $n = List::AllUtils::max(
            @{ $aes->names->map( sub { $aes->at($_)->length } ) } );
    }

    my @bad_keys = grep {
        my $length = $aes->at($_)->length();
        !( $length == 1 or $length == $n )
    } @{ $aes->names };

    return unless @bad_keys;

    die(
        sprintf(
"Aesthetics must be either length 1 or the same as the data (%s): %s.",
            $n, join( ', ', map { qq{"$_"} } @bad_keys )
        )
    );
}

1;

__END__

=head1 DESCRIPTION

This class is used for holding aesthetics data. 
It inherits L<Chart::GGPlot::Params> to accept various names of same
concept, like color/colour/fg, fill/bg, etc.

Unlike L<Chart::GGPlot::Params>, this class has its object keys
alphabetically sorted.

=head1 SEE ALSO

L<Chart::GGPlot::Aes::Functions>,
L<Chart::GGPlot::Params>

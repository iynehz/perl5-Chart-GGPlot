package Chart::GGPlot::Guide;

# ABSTRACT: Role for guide

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);
use namespace::autoclean;

# VERSION

use parent qw(Chart::GGPlot::Params);

use Types::Standard qw(Str);

use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

=attr title

A string indicating a title of the guide. If an empty string, the
title is not show. By default (C<undef>) the name of the scale
object or the name specified in C<labs()> is used for the title.

=attr key

=attr reverse

=cut

for my $attr (qw(title key reverse)) {
    no strict 'refs';
    *{$attr} = sub { $_[0]->at($attr); }
}

# undef means "any"
classmethod available_aes () { undef; }

method train ($scale, $aesthetics=undef) {
    return $self;
}

classmethod _reverse_df ($df) {
    return $df->select_rows( [ reverse( 0 .. $df->nrow - 1 ) ] );
}

1;

__END__


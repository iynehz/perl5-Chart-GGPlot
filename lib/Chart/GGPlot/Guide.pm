package Chart::GGPlot::Guide;

# ABSTRACT: Role for guide

use Chart::GGPlot::Setup;
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

=cut

method title() {
    return $self->at('title');
}

method available_aes() { undef; }

1;

__END__


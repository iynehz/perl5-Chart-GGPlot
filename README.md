[![Build Status](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot)

# NAME

Chart::GGPlot - ggplot2 port in Perl

# VERSION

version 0.0001

# STATUS

At this moment this library is experimental and still under active
development (at my after-work time). It's still quite incomplete compared
to R's ggplot2 library, but the core features are working.

Besides, it heavily depends on my [Alt::Data::Frame::ButMore](https://metacpan.org/pod/Alt::Data::Frame::ButMore) library,
which is also experimental.

# SYNOPSIS

```perl
use Chart::GGPlot qw(:all);
use Data::Frame::Examples qw(mtcars);

my $plot = ggplot(
    data => mtcars(),
    mapping => aes( x => 'wt', y => 'mpg' )
)->geom_point();

# show in browser
$plot->show;

# export to image file
$plot->save('mtcars.png');

# see "examples" dir of this library's distribution for more examples.
```

# DESCRIPTION

This Chart-GGPlot library is an implementation of
[ggplot2](https://en.wikipedia.org/wiki/Ggplot2) in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses [Chart::Plotly](https://metacpan.org/pod/Chart::Plotly).

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

Example exported image files:

<div>
    <p float="left">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/position_stack_02_02.png" alt="proportional stacked bar" width="45%">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/geom_line_02_01.png" alt="line chart" width="45%">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/scale_viridis_02_01.png" alt="viridis color scale" width="45%">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/theme_01_06.png" alt="theme 'minimal'" width="45%">
    </p>
</div>

See the `examples` dir in the library's distribution for more examples.

# FUNCTIONS

## ggplot

```
ggplot(:$data, :$mapping, %rest)
```

This is same as `Chart::GGPlot::Plot->new(...)`.
See [Chart::GGPlot::Plot](https://metacpan.org/pod/Chart::GGPlot::Plot) for details.

## qplot

```
qplot(Piddle1D :$x, Piddle1D :$y, Str :$geom='auto',
    :$xlim=undef, :$ylim=undef,
    :$log='', :$title=undef, :$xlab='x', :$ylab='y',
    %rest)
```

# ENVIRONMENT VARIABLES

## CHART\_GGPLOT\_TRACE

A positive integer would enable debug messages.

# SEE ALSO

[ggplot2](https://en.wikipedia.org/wiki/Ggplot2)

[Chart::GGPlot::Plot](https://metacpan.org/pod/Chart::GGPlot::Plot)

[Alt::Data::Frame::ButMore](https://metacpan.org/pod/Alt::Data::Frame::ButMore)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

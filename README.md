[![Build Status](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot)

# NAME

Chart::GGPlot - ggplot2 port in Perl

# VERSION

version 0.0000\_01

# STATUS

At this moment this library is still under active development (at my
after-work time) and is highly incomplete. Basically only what's in the
`examples` directory is able to work now. And its API can change
without notice.

# DESCRIPTION

This Chart-GGPlot library is an implementation of
[ggplot](https://en.wikipedia.org/wiki/Ggplot) in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses [Chart::Plotly](https://metacpan.org/pod/Chart::Plotly).

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

Example exported image files:

<div>
    <p align="center">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/position_stack_02_02.png" alt="proportional stacked bar" width="45%">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/scale_viridis_02_01.png" alt="viridis color scale" width="45%">
    <img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/theme_01_06.png" alt="theme 'minimal'" width="45%">
    </p>
</div>

# FUNCTIONS

## ggplot

```
ggplot(:$data, :$mapping, %rest)
```

This is same as `Chart::GGPlot::Plot->new(...)`.

## qplot

```
qplot(:$x, :$y,
      Str :$geom='auto',
      :$xlim=undef, :$ylim=undef,
      :$title=undef, :$xlab='x', :$ylab='y',
      %rest)
```

# ENVIRONMENT VARIABLES

## CHART\_GGPLOT\_TRACE

A positive integer would enable debug messages.

# SEE ALSO

[ggplot](https://en.wikipedia.org/wiki/Ggplot)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

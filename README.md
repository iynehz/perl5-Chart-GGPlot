[![Actions Status](https://github.com/iynehz/perl5-Chart-GGPlot/actions/workflows/ci.yml/badge.svg)](https://github.com/iynehz/perl5-Chart-GGPlot/actions)

# NAME

Chart::GGPlot - ggplot2 port in Perl

# VERSION

version 0.002003

# STATUS

At this moment this library is experimental and still under active
development (at my after-work time). It's still quite incomplete compared
to R's ggplot2 library, but the core features are working.

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
backend which uses [Chart::Plotly](https://metacpan.org/pod/Chart%3A%3APlotly).

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

Example exported image files:

<div>
    <p float="left">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/position_stack_02_02.png" alt="proportional stacked bar" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_line_02_01.png" alt="line chart" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_boxplot_01_02.png" alt="boxplot" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_smooth_01_01.png" alt="smooth" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/scale_viridis_02_01.png" alt="viridis color scale" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_polygon_01_01.png" alt="polygon" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_raster_02_01.png" alt="heatmap" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_text_01_05.png" alt="text" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/geom_bar_01_05.png" alt="bar" width="40%">
    <img src="https://raw.githubusercontent.com/iynehz/perl5-Chart-GGPlot/master/examples/theme_01_06.png" alt="theme 'minimal'" width="40%">
    </p>
</div>

See the `examples` dir in the library's distribution for more examples.

## Document Conventions

Function signatures in docs of this library follow the
[Function::Parameters](https://metacpan.org/pod/Function%3A%3AParameters) conventions, for example,

```perl
myfunc(Type1 $positional_parameter, Type2 :$named_parameter)
```

# FUNCTIONS

## ggplot

```
ggplot(:$data, :$mapping, %rest)
```

This is same as `Chart::GGPlot::Plot->new(...)`.
See [Chart::GGPlot::Plot](https://metacpan.org/pod/Chart%3A%3AGGPlot%3A%3APlot) for details.

## qplot

```
qplot((Piddle1D|ArrayRef) :$x, (Piddle1D|ArrayRef) :$y,
    Str :$geom='auto',
    :$xlim=undef, :$ylim=undef,
    Str :$log='',
    Maybe[Str] :$title=undef, Str :$xlab='x', Str :$ylab='y',
    %rest)
```

Arguments:

- $x, $y

    Data. Supports either 1D piddles or arrayrefs. When arrayref is specified, it
    would be converted to either a numeric piddle or a PDL::SV piddle, guessing by
    its contents.

- $geom

    Geom type. `"auto"` is treated as `'point'`.
    It would internally call a `geom_${geom}` function.

- $xlim, $ylim

    Axes limits.

- $log

    Which axis use logarithmic scale?
    One of `''`, `'x'`, `'y'`, `'xy'`.

- $title

    Plot title. Default is `undef`, for no title.

- $xlabel, $ylabel

    Axes labels.

# ENVIRONMENT VARIABLES

## CHART\_GGPLOT\_TRACE

A positive integer would enable debug messages.

# SEE ALSO

[ggplot2](https://en.wikipedia.org/wiki/Ggplot2)

[Chart::GGPlot::Plot](https://metacpan.org/pod/Chart%3A%3AGGPlot%3A%3APlot)

[Data::Frame](https://metacpan.org/pod/Data%3A%3AFrame)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# CONTRIBUTOR

Pablo Rodríguez (pablrod)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019-2023 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

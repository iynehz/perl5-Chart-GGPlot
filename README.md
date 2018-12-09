[![Build Status](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot)

# NAME

Chart::GGPlot - ggplot port for Perl

# VERSION

version 0.0000\_01

# STATUS

At this moment this library is still under active development (at my
after-work time) and is highly incomplete. Basically only what's in the
`examples` directory is able to work now. And its API can change
without notice.

Before this library be released to CPAN, if you would like to try it out
you can get the source from [https://github.com/stphnlyd/perl5-Chart-GGPlot/](https://github.com/stphnlyd/perl5-Chart-GGPlot/).
Also note that at this moment you will also need my forked version of the
"Data-Frame" package at [https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv](https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv). In my fork I improved PDL::SV and will still work on PDL::Factor.

# DESCRIPTION

This Chart-GGPlot library is an implementation of
[ggplot](https://en.wikipedia.org/wiki/Ggplot) in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses [Chart::Plotly](https://metacpan.org/pod/Chart::Plotly).

This Chart::GGPlot module itself just represents the ggplot class.
Instead of this module you would usually want to look at
[Chart::GGPlot::Functions](https://metacpan.org/pod/Chart::GGPlot::Functions), which is a function interface of this library
and is closer to R ggplot2's API.

# METHODS

## show

```
$ggplot->show(HashRef $opts={})
```

Show the plot.
Implementation depends on the plotting backend.

## save

```
$ggplot->save($filename, HashRef $opts={})
```

Save the plot to file.
Implementation depends on the plotting backend.

## summary()

Get a useful description of a ggplot object.

# SEE ALSO

[ggplot](https://en.wikipedia.org/wiki/Ggplot)

[Chart::GGPlot::Functions](https://metacpan.org/pod/Chart::GGPlot::Functions)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

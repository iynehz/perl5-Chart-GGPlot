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

Before this library be released to CPAN, if you would like to try it out
you can get the source from [https://github.com/stphnlyd/perl5-Chart-GGPlot/](https://github.com/stphnlyd/perl5-Chart-GGPlot/).
Also note that at this moment you will also need my forked version of the
"Data-Frame" package at [https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv](https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv).
In my fork I improved PDL::SV and will still work on PDL::Factor.

# DESCRIPTION

This Chart-GGPlot library is an implementation of
[ggplot](https://en.wikipedia.org/wiki/Ggplot) in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses [Chart::Plotly](https://metacpan.org/pod/Chart::Plotly).

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

# FUNCTIONS

## ggplot

```perl
my $ggplot = ggplot(:$data, :$mapping, %rest);
```

This is same as [Chart::GGPlot::Plot->new(...)](https://metacpan.org/pod/Chart::GGPlot::Plot->new\(...\)).

## qplot

# SEE ALSO

[ggplot](https://en.wikipedia.org/wiki/Ggplot)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

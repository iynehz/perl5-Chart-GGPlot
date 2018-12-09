[![Build Status](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Chart-GGPlot)

# NAME

Chart::GGPlot - ggplot port for Perl

# VERSION

version 0.0000\_01

# DESCRIPTION

This library is an implementation of [https://en.wikipedia.org/wiki/Ggplot2|"ggplot"](https://en.wikipedia.org/wiki/Ggplot2|&#x22;ggplot&#x22;)
in Perl. Instead of this module, which represents the ggplot class, you
would usually want to look at [Chart::GGPlot::Functions](https://metacpan.org/pod/Chart::GGPlot::Functions), which is a
function interface of this library and is easier to use than this class.

# METHODS

## labels

## show

```
show(HashRef $opts={})
```

## save

```
save($filename, HashRef $opts={})
```

## summary()

Get a useful description of a ggplot object.

# STATUS

At this moment this library is still under active development (at my
after-work time) and is highly incomplete. Basically only what's in the
`examples` directory is able to work now. And its API can change
without notice.

Before this library be released to CPAN, if you would like to try it out
you can get the source from [https://github.com/stphnlyd/perl5-Chart-GGPlot/](https://github.com/stphnlyd/perl5-Chart-GGPlot/).
Also note that at this moment you will also need my forked version of the
"Data-Frame" package at [https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv](https://github.com/stphnlyd/p5-Data-Frame/tree/alt-pdlsv). In my fork I improved PDL::SV and will still work on PDL::Factor.

# SEE ALSO

[https://en.wikipedia.org/wiki/Ggplot2|ggplot2](https://en.wikipedia.org/wiki/Ggplot2|ggplot2)

[Chart::GGPlot::Functions](https://metacpan.org/pod/Chart::GGPlot::Functions)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

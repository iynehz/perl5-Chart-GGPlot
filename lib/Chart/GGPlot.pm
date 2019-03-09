package Chart::GGPlot;

# ABSTRACT: ggplot2 port in Perl

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Data::Munge qw(elem);
use Data::Frame::Types qw(DataFrame);
use Data::Frame::Util qw(guess_and_convert_to_pdl);
use Module::Load;
use Types::Standard qw(Maybe Str);

use Chart::GGPlot::Plot;
use Chart::GGPlot::Aes;
use Chart::GGPlot::Util qw(factor);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(ggplot qplot);

# PodWeaver would move the HTML/markdown block to after FUNCTION.
# So we have to move our DESCRIPTION part to the top and explicitly have
# a "=head1 FUNCTIONS" header, and not use =func directive.
=pod
=encoding utf8

=head1 DESCRIPTION

This Chart-GGPlot library is an implementation of
L<ggplot|https://en.wikipedia.org/wiki/Ggplot> in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses L<Chart::Plotly>.

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

Example exported image files:

=begin html

<p float="left">
<img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/position_stack_02_02.png" alt="proportional stacked bar" width="45%">
<img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/geom_line_02_01.png" alt="line chart" width="45%">
<img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/scale_viridis_02_01.png" alt="viridis color scale" width="45%">
<img src="https://raw.githubusercontent.com/stphnlyd/perl5-Chart-GGPlot/master/examples/theme_01_06.png" alt="theme 'minimal'" width="45%">
</p>

=end html

=cut

=head1 FUNCTIONS

=cut

for my $package (
    qw(
    Chart::GGPlot::Aes::Functions
    Chart::GGPlot::Position::Functions
    )
  )
{
    load $package, ':ggplot';
    no strict 'refs';
    push @EXPORT_OK, @{ ${"${package}::EXPORT_TAGS"}{ggplot} };
}
push @EXPORT_OK, qw(factor);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

=head2 ggplot

    ggplot(:$data, :$mapping, %rest)

This is same as C<Chart::GGPlot::Plot-E<gt>new(...)>.

=cut

sub ggplot {
    return Chart::GGPlot::Plot->new(@_);
}

=head2 qplot

    qplot(:$x, :$y,
          Str :$geom='auto',
          :$xlim=undef, :$ylim=undef,
          :$title=undef, :$xlab='x', :$ylab='y',
          %rest)

=cut

fun qplot (
    :$x, :$y, 
    :$facets = undef,
    Str :$geom = "auto",
    :$xlim = undef, :$ylim = undef,
    :$title = undef, :$xlab = 'x', :$ylab = 'y',
#    : $log     = "",
#    : $asp     = undef,
    %rest
  ) {

    my $all_aesthetics = Chart::GGPlot::Aes->all_aesthetics;

    $x = guess_and_convert_to_pdl($x);
    $y = guess_and_convert_to_pdl($y);

    unless ( $x->length == $y->length ) {
        die "x and y must have same length";
    }

    my $mapping = aes( x => 'x', y => 'y' );
    for my $aes ( grep { elem( $_, $all_aesthetics ) } keys %rest ) {
        $mapping->set( $aes, $aes );
    }

    $log->debug('qplot() $mapping = ' . Dumper($mapping));

    my $data = Data::Frame->new(
        columns => [
            x => guess_and_convert_to_pdl($x),
            y => guess_and_convert_to_pdl($y),

            $mapping->keys->grep( sub { $_ ne 'x' and $_ ne 'y' } )->map(
                sub {
                    my $d = guess_and_convert_to_pdl( $rest{$_} );
                    $_ => $d->repeat_to_length( $x->length );
                }
            )->flatten
        ]
    );

    my $p = ggplot( data => $data, mapping => $mapping );

    if ( not defined $facets ) {
        $p->facet_null();
    }
    else {
        die "'facets' is not yet supported.";
    }

    $p->ggtitle($title) if ( defined $title );
    $p->xlab($xlab)     if ( defined $xlab );
    $p->ylab($ylab)     if ( defined $ylab );

    my $geom_func;
    if ( $geom eq 'auto' ) {
        $geom_func = 'geom_point';
    }
    else {
        $geom_func = "geom_${geom}";
    }

    $p->$geom_func();

    #    my $logv = fun($var) { index( $log, $var ) >= 0 };
    #
    #    if ( $logv->('x') ) { $p = $p + scale_x_log10(); }
    #    if ( $logv->('y') ) { $p = $p + scale_y_log10(); }
    #
    #    if ( defined $asp ) { $p = $p + theme( aspect_ratio = $asp ); }
    #    if ( defined $xlab ) { $p = $p + xlim($xlab); }
    #    if ( defined $ylab ) { $p = $p + ylim($ylab); }
    #    if ( defined $xlim ) { $p = $p + xlim($xlim); }
    #    if ( defined $ylim ) { $p = $p + ylim($ylim); }

    return $p;
}

1;

__END__

=head1 STATUS

At this moment this library is still under active development (at my
after-work time) and is highly incomplete. Basically only what's in the
C<examples> directory is able to work now. And its API can change
without notice.

=head1 ENVIRONMENT VARIABLES

=head2 CHART_GGPLOT_TRACE

A positive integer would enable debug messages.

=head1 SEE ALSO

L<ggplot|https://en.wikipedia.org/wiki/Ggplot>


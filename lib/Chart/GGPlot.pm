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

=func ggplot

    my $ggplot = ggplot(:$data, :$mapping, %rest);

This is same as C<Chart::GGPlot::Plot-E<gt>new(...)>.

=cut

sub ggplot {
    return Chart::GGPlot::Plot->new(@_);
}

=func qplot

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

=pod
=encoding utf8

=head1 STATUS

At this moment this library is still under active development (at my
after-work time) and is highly incomplete. Basically only what's in the
C<examples> directory is able to work now. And its API can change
without notice.

=head1 DESCRIPTION

This Chart-GGPlot library is an implementation of
L<ggplot|https://en.wikipedia.org/wiki/Ggplot> in Perl. It's designed to
be possible to support multiple plotting backends. And it ships a default
backend which uses L<Chart::Plotly>.

This Chart::GGPlot module is the function interface of the Perl Chart-GGPlot
library.

=head1 ENVIRONMENT VARIABLES

=head2 CHART_GGPLOT_TRACE

A positive value would enable debug messages.

=head1 SEE ALSO

L<ggplot|https://en.wikipedia.org/wiki/Ggplot>


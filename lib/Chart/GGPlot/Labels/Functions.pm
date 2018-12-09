package Chart::GGPlot::Labels::Functions;

# ABSTRACT: Function interface for Chart::GGPlot::Labels

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Labels;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  labs xlab ylab ggtitle
);
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => [qw(labs xlab ylab ggtitle)]
);

=func labs

This is same as C<Chart::GGPlot::Labels-E<gt>new>.

=cut

sub labs {
    return Chart::GGPlot::Labels->new(@_);
}

=func xlab($label)

This is a shortcut of C<labs(x =E<gt> $label)>.

=func ylab($label)

This is a shortcut of C<labs(y =E<gt> $label)>.

=cut

fun xlab($label) {
    return Chart::GGPlot::Labels->new( x => $label );
}

fun ylab($label) {
    return Chart::GGPlot::Labels->new( y => $label );
}

=func ggtitle($title, $subtitle=undef)

This is a shortcut of
C<labs(title =E<gt> $title, subtitle =E<gt> $subtitle)>.

=cut

fun ggtitle( $title, $subtitle = undef ) {
    return Chart::GGPlot::Labels->new(
        title          => $title,
        maybe subtitle => $subtitle,
    );
}

1;

=head1 SEE ALSO

L<Chart::GGPlot::Labels>

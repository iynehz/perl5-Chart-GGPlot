package Chart::GGPlot::Guide::Functions;

# ABSTRACT: Function interface for guides

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Guide::Legend;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  guide_legend 
);
our %EXPORT_TAGS = (
    'all'    => \@EXPORT_OK,
    'ggplot' => [qw(guide_legend)],
);

=func guide_legend

    guide_legend(:$title=undef, %rest)

=cut

sub guide_legend {
    return Chart::GGPlot::Guide::Legend->new(@_);   
}


1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Guide>


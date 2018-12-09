package Chart::GGPlot::Guide::Functions;

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

sub guide_legend {
    return Chart::GGPlot::Guide::Legend->new(@_);   
}


1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Guide>

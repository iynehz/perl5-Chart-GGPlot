package Chart::GGPlot::Position::Functions;

# ABSTRACT: Functions for Chart::GGPlot::Position

use Chart::GGPlot::Setup qw(:pdl);

# VERSION

use Chart::GGPlot::Aes::Functions qw(:all);

use parent qw(Exporter::Tiny);

my @position_types = qw(identity);

our @EXPORT_OK = (qw(
  transform_position
), (map { "position_${_}" } @position_types));

my @export_ggplot = @EXPORT_OK;
our %EXPORT_TAGS = ( all => \@EXPORT_OK, ggplot => @export_ggplot );

fun transform_position ($df, $trans_x = undef, $trans_y = undef, @rest) {
    my $scales = aes_to_scale($df->keys);
    
    if (defined $trans_x) {
        df[$scales eq "x"] <- lapply(df[scales == "x"], trans_x, ...)
    }
    if (defined $trans_y) {
        df[$scales eq "y"] <- lapply(df[scales == "y"], trans_y, ...)
    }

    return $df;
}

1;

__END__

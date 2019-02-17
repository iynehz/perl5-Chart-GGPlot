package Chart::GGPlot::Position::Functions;

# ABSTRACT: Functions for Chart::GGPlot::Position

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Module::Load;

use Chart::GGPlot::Aes::Functions qw(:all);

use parent qw(Exporter::Tiny);

my @position_types = qw(identity dodge dodge2 stack fill);

our @EXPORT_OK = (map { "position_${_}" } @position_types);

my @export_ggplot = @EXPORT_OK;
our %EXPORT_TAGS = ( all => \@EXPORT_OK, ggplot => \@export_ggplot );

for my $type (@position_types) {
    my $class = 'Chart::GGPlot::Position::' . ucfirst($type);
    load $class;

    no strict 'refs';
    *{"position_${type}"} = sub { $class->new(@_); };
}

1;

__END__

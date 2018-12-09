package Chart::GGPlot::Theme::Element::Functions;

# ABSTRACT: 

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Theme::Element::Blank;
use Chart::GGPlot::Theme::Element::Rect;
use Chart::GGPlot::Theme::Element::Line;
use Chart::GGPlot::Theme::Element::Text;
use Chart::GGPlot::Theme::Element::Rel;

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  element_blank element_rect element_line element_text
  rel
);
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => [qw(
        element_blank element_rect element_line element_text
        rel)]
);

=func element_blank()

=func element_rect(:$fill=undef, :$color=undef, :$size=undef,
:$linetype=undef, :$inherit_blank=false) 

=func element_line(:$color=undef, :$linetype=undef, :$lineend=undef,
:$arrow=undef, :$inherit_blank=false)

=func element_text(:$family=undef, :$face=undef, :$color=undef,
:$size=undef, :$hjust=undef, :$vjust=undef, :$angle=undef,
:$lineheight=undef, :$margin=undef, :$debug=undef, :$inherit_blank=false)

=cut

for my $x (qw(blank rect line text)) {
    my $class = 'Chart::GGPlot::Theme::Element::' . ucfirst($x);

    no strict 'refs';
    *{"element_${x}"} = sub { $class->new(@_); }
}

=func rel($x)

Used to specify sizes relative to the parent.

=cut

fun rel($x) {
    return Chart::GGPlot::Theme::Element::Rel->new($x);
}


1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

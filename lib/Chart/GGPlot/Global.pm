package Chart::GGPlot::Global;

# ABSTRACT: Various global variables and settings

use Chart::GGPlot::Class;
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

use Module::Load;
use Types::Standard qw(InstanceOf);

#=attr theme_current
#
#The current theme.
#
#=cut
#
#has theme_current => (
#    is      => 'rw',
#    isa     => InstanceOf ['Chart::GGPlot::Theme'],
#    lazy    => 1,
#    builder => '_build_theme_current'
#);
#
#method _build_theme_current () {
#    load Chart::GGPlot::Theme::Defaults, qw(theme_grey);
#    return theme_grey();
#}

#=attr element_tree
#
#Element tree for the theme elements.
#
#=cut
#
#has element_tree => (
#    is      => 'rw',
#    isa     => InstanceOf ['Chart::GGPlot::Theme::ElementTree'],
#    lazy    => 1,
#    builder => '_build_element_tree',
#);
#
#method _build_element_tree () {
#    load Chart::GGPlot::Theme::ElementTree;
#    return Chart::GGPlot::Theme::ElementTree->default_element_tree();
#}

1;

__END__

=head1 SYNOPSIS

    use Chart::GGPlot::Global;

    my $theme = Chart::GGPlot::Global->theme_current;
    my $ggplot_global = Chart::GGPlot::Global->instance;

=head1 DESCRIPTION

This is a singleton class that holds various global variables and settings
for ggplot.


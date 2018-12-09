package Chart::GGPlot::Theme::Functions;

# ABSTRACT: Function interface of Chart::GGPlot::Theme

use Chart::GGPlot::Setup;

# VERSION

use Chart::GGPlot::Theme;
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(theme update_theme);

sub theme {
    return Chart::GGPlot::Theme->new(@_);
}

fun update_theme(Theme $old_theme, Theme $new_theme) {
    # If newtheme is a "complete" theme, then it is meant to replace
    # oldtheme; this function just returns newtheme.
    return $new_theme if ($new_theme->complete);

    # These are elements in newtheme that aren't already set in oldtheme.
    # They will be pulled from the default theme.
    my $new_items = aref_diff($old_theme->names, $new_theme->names);
    for my $name (@$new_items) {
        $old_theme->set($name, $ggplot_global->theme_current->at($name));
    }

    my $old_validate = $old_theme->validate;
    my $new_validate = $new_theme->validate;
    $old_theme->validate = ($old_validate and $new_validate);

    return $old_theme->add_theme($new_theme);
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme>

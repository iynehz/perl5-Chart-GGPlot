package Chart::GGPlot::Theme::ElementTree;

# ABSTRACT: Definitions of theme elements

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);

# VERSION

use parent qw(Chart::GGPlot::Params);

use Types::Standard qw(Any ArrayRef Bool HashRef InstanceOf Num Str);

use Chart::GGPlot::Params;
use Chart::GGPlot::Theme::Defaults qw(theme_grey);
use Chart::GGPlot::Theme::Element::Functions qw(:all);
use Chart::GGPlot::Theme::ElementTree;

# support both "foo.bar" and "foo_bar" as element name.
classmethod transform_key ($key) {
    return ( $key =~ s/\./_/gr );
}

classmethod el_def ( $type, $inherit = [], $description = '' ) {
    $inherit = Ref::Util::is_arrayref($inherit) ? $inherit : [ $inherit // () ];
    return {
        type        => $type,
        inherit     => $inherit,
        description => $description,
    };
}

classmethod default_element_tree () {
    my $ElementLine = InstanceOf ["Chart::GGPlot::Theme::Element::Line"];
    my $ElementRect = InstanceOf ["Chart::GGPlot::Theme::Element::Rect"];
    my $ElementText = InstanceOf ["Chart::GGPlot::Theme::Element::Text"];
    my $Margin      = InstanceOf ["Chart::GGPlot::Margin"];
    my $Character =
      ( ArrayRef [ ( Str | Num ) ] )->plus_coercions( Any, sub { [ $_, $_ ] } );

    my $TagPosition = (
        (
            Enum [
                qw(topleft top topright left right bottomleft bottom bottomright)
            ]
        ) | ( ArrayRef [Num] )->where(sub { @$_ == 2 })
    )->plus_coercions(
        Str,
        sub {
            state $mapping;
            unless ($mapping) {
                $mapping = {};
                my @setup = (
                    [qw(bottom left)],  [qw(top left)],
                    [qw(bottom right)], [qw(top right)],
                );
                for my $item (@setup) {
                    my ( $a, $b ) = @$item;
                    my $just = "$a$b";
                    $mapping->{"$b$a"} =
                      $mapping->{"${a}_$b"} = $mapping->{"${b}_$a"} = $just;
                }
            }
            return ( $mapping->{$_} // $_ );
        }
    );

    return $class->new(
        line             => $class->el_def($ElementLine),
        rect             => $class->el_def($ElementRect),
        text             => $class->el_def($ElementText),
        title            => $class->el_def( $ElementText, "text" ),
        axis_line        => $class->el_def( $ElementLine, "line" ),
        axis_text        => $class->el_def( $ElementText, "text" ),
        axis_title       => $class->el_def( $ElementText, "title" ),
        axis_ticks       => $class->el_def( $ElementLine, "line" ),
        legend_key_size  => $class->el_def(Unit),
        panel_grid       => $class->el_def( $ElementLine, "line" ),
        panel_grid_major => $class->el_def( $ElementLine, "panel_grid" ),
        panel_grid_minor => $class->el_def( $ElementLine, "panel_grid" ),
        strip_text       => $class->el_def( $ElementText, "text" ),

        axis_line_x         => $class->el_def( $ElementLine, "axis_line" ),
        axis_line_x_top     => $class->el_def( $ElementLine, "axis_line_x" ),
        axis_line_x_bottom  => $class->el_def( $ElementLine, "axis_line_x" ),
        axis_line_y         => $class->el_def( $ElementLine, "axis_line" ),
        axis_line_y_left    => $class->el_def( $ElementLine, "axis_line_y" ),
        axis_line_y_right   => $class->el_def( $ElementLine, "axis_line_y" ),
        axis_text_x         => $class->el_def( $ElementText, "axis_text" ),
        axis_text_x_top     => $class->el_def( $ElementText, "axis_text_x" ),
        axis_text_x_bottom  => $class->el_def( $ElementText, "axis_text_x" ),
        axis_text_y         => $class->el_def( $ElementText, "axis_text" ),
        axis_text_y_left    => $class->el_def( $ElementText, "axis_text_y" ),
        axis_text_y_right   => $class->el_def( $ElementText, "axis_text_y" ),
        axis_ticks_length   => $class->el_def(Unit),
        axis_ticks_x        => $class->el_def( $ElementLine, "axis_ticks" ),
        axis_ticks_x_top    => $class->el_def( $ElementLine, "axis_ticks_x" ),
        axis_ticks_x_bottom => $class->el_def( $ElementLine, "axis_ticks_x" ),
        axis_ticks_y        => $class->el_def( $ElementLine, "axis_ticks" ),
        axis_ticks_y_left   => $class->el_def( $ElementLine, "axis_ticks_y" ),
        axis_ticks_y_right  => $class->el_def( $ElementLine, "axis_ticks_y" ),
        axis_title_x        => $class->el_def( $ElementText, "axis_title" ),
        axis_title_x_top    => $class->el_def( $ElementText, "axis_title_x" ),
        axis_title_x_bottom => $class->el_def( $ElementText, "axis_title_x" ),
        axis_title_y        => $class->el_def( $ElementText, "axis_title" ),
        axis_title_y_left   => $class->el_def( $ElementText, "axis_title_y" ),
        axis_title_y_right  => $class->el_def( $ElementText, "axis_title_y" ),

        legend_background  => $class->el_def( $ElementRect, "rect" ),
        legend_margin      => $class->el_def($Margin),
        legend_spacing     => $class->el_def(Unit),
        legend_spacing_x   => $class->el_def( Unit, "legend_spacing" ),
        legend_spacing_y   => $class->el_def( Unit, "legend_spacing" ),
        legend_key         => $class->el_def( $ElementRect, "rect" ),
        legend_key_height  => $class->el_def( Unit, "legend_key_size" ),
        legend_key_width   => $class->el_def( Unit, "legend_key_size" ),
        legend_text        => $class->el_def( $ElementText, "text" ),
        legend_text_align  => $class->el_def($Character),
        legend_title       => $class->el_def( $ElementText, "title" ),
        legend_title_align => $class->el_def($Character),
        legend_position    => $class->el_def($Character)
        ,    # Need to also accept numbers
        legend_direction      => $class->el_def($Character),
        legend_justification  => $class->el_def($Character),
        legend_box            => $class->el_def($Character),
        legend_box_just       => $class->el_def($Character),
        legend_box_margin     => $class->el_def($Margin),
        legend_box_background => $class->el_def( $ElementRect, "rect" ),
        legend_box_spacing    => $class->el_def(Unit),

        panel_background => $class->el_def( $ElementRect, "rect" ),
        panel_border     => $class->el_def( $ElementRect, "rect" ),
        panel_spacing    => $class->el_def(Unit),
        panel_spacing_x  => $class->el_def( Unit,         "panel_spacing" ),
        panel_spacing_y  => $class->el_def( Unit,         "panel_spacing" ),
        panel_grid_major_x =>
          $class->el_def( $ElementLine, "panel_grid_major" ),
        panel_grid_major_y =>
          $class->el_def( $ElementLine, "panel_grid_major" ),
        panel_grid_minor_x =>
          $class->el_def( $ElementLine, "panel_grid_minor" ),
        panel_grid_minor_y =>
          $class->el_def( $ElementLine, "panel_grid_minor" ),
        panel_ontop => $class->el_def(Any),

        strip_background => $class->el_def( $ElementRect, "rect" ),
        strip_background_x =>
          $class->el_def( $ElementRect, "strip_background" ),
        strip_background_y =>
          $class->el_def( $ElementRect, "strip_background" ),
        strip_text_x      => $class->el_def( $ElementText, "strip_text" ),
        strip_text_y      => $class->el_def( $ElementText, "strip_text" ),
        strip_placement   => $class->el_def($Character),
        strip_placement_x => $class->el_def( $Character,   "strip_placement" ),
        strip_placement_y => $class->el_def( $Character,   "strip_placement" ),
        strip_switch_pad_grid => $class->el_def(Unit),
        strip_switch_pad_wrap => $class->el_def(Unit),

        plot_background   => $class->el_def( $ElementRect, "rect" ),
        plot_title        => $class->el_def( $ElementText, "title" ),
        plot_subtitle     => $class->el_def( $ElementText, "title" ),
        plot_caption      => $class->el_def( $ElementText, "title" ),
        plot_tag          => $class->el_def( $ElementText, "title" ),
        plot_tag_position => $class->el_def($TagPosition),
        plot_margin       => $class->el_def($Margin),

        aspect_ratio => $class->el_def($Character),
    );
}

1;

__END__

package Chart::GGPlot::Theme::Element;

# ABSTRACT: Basic types for theme elements

use strict;
use warnings;

# VERSION

package Chart::GGPlot::Theme::Element {
    use Chart::GGPlot::Setup;
    use Function::Parameters qw(classmethod);
    use namespace::autoclean;

    use parent qw(Chart::GGPlot::Params);

    sub transform_key {
        my ( $class, $key ) = @_;
        return 'color' if $key eq 'colour';
        return $key;
    }

    sub parameters { [] } 

    sub is_blank { false }

    method string () {
        return Dumper($self);
    }

}

package Chart::GGPlot::Theme::Element::Blank {
    use Chart::GGPlot::Setup;
    use Function::Parameters qw(classmethod);
    use namespace::autoclean;

    use parent qw(Chart::GGPlot::Theme::Element);

    classmethod parameters () { [] }

    sub is_blank { true }
}

package Chart::GGPlot::Theme::Element::Line {
    use Chart::GGPlot::Setup;
    use Function::Parameters qw(classmethod);
    use Class::Method::Modifiers;
    use namespace::autoclean;

    use parent qw(Chart::GGPlot::Theme::Element);

    use Types::Standard;

    around parameters => sub {
        my $orig  = shift;
        my $class = shift;
        return [
            qw(color size linetype lineend inherit_blank),
            @{ $class->$orig() }
        ];
    };
}

package Chart::GGPlot::Theme::Element::Rect {
    use Chart::GGPlot::Setup;
    use Function::Parameters qw(classmethod);
    use Class::Method::Modifiers;
    use namespace::autoclean;

    use parent qw(Chart::GGPlot::Theme::Element);

    use Types::Standard;

    use Chart::GGPlot::Util qw(pt);

    around parameters => sub {
        my $orig  = shift;
        my $class = shift;
        return [ qw(fill color size linetype inherit_blank),
            @{ $class->$orig() } ];
    }
}

package Chart::GGPlot::Theme::Element::Text {

    use Chart::GGPlot::Setup;
    use Function::Parameters qw(classmethod);
    use Class::Method::Modifiers;
    use namespace::autoclean;

    # VERSION

    use parent qw(Chart::GGPlot::Theme::Element);

    around parameters => sub {
        my $orig  = shift;
        my $class = shift;
        return [
            qw(
              family face color size hjust vjust
              angle lineheight inherit_blank
              ),
            @{ $class->$orig() }
        ];
    };
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Theme::Element>

1;

__END__

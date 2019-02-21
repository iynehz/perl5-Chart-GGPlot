package Chart::GGPlot::Plot;

# ABSTRACT: ggplot class

use Chart::GGPlot::Class;
use namespace::autoclean;

# VERSION

use Autoload::AUTOCAN;
use List::AllUtils qw(pairgrep pairmap firstres);
use Module::Load;
use Package::Stash;
use Scalar::Util qw(looks_like_number);
use String::Util qw(trim);
use Types::Standard qw(ArrayRef ConsumerOf HashRef InstanceOf);

use Chart::GGPlot::Aes;
use Chart::GGPlot::Coord::Functions ();
use Chart::GGPlot::Guides;
use Chart::GGPlot::Layout;
use Chart::GGPlot::Params;
use Chart::GGPlot::ScalesList;
use Chart::GGPlot::Types qw(:all);

method AUTOCAN ($method) {
    state $known_methods;   # mapping method name to coderef
    unless ($known_methods) {
        my @namespaces = qw(
          Chart::GGPlot::Coord::Functions
          Chart::GGPlot::Facet::Functions
          Chart::GGPlot::Geom::Functions
          Chart::GGPlot::Guide::Functions
          Chart::GGPlot::Labels::Functions
          Chart::GGPlot::Scale::Functions
          Chart::GGPlot::Limits
          Chart::GGPlot::Theme::Defaults
        );

        for (@namespaces) {
            load $_;
        }
        $known_methods = {
            map {
                my $ns = $_;
                no strict 'refs';
                my @funcs = @{ ${"${ns}::EXPORT_TAGS"}{ggplot} };
                map { $_ => \&{"${ns}::$_"}; } @funcs;
            } @namespaces
        };
    }
    my $f = $known_methods->{$method};

    unless ( defined $f ) {

        # For several kinds of methods, fallback to look for them in the
        # caller pacakge.
        if ( $method =~ /^(?:geom|scale)_/ ) {
            my $p = Package::Stash->new( ( caller() )[0] );
            $f = $p->get_symbol("&$method");
        }
    }
    return undef unless ($f);

    state $type_to_method = [
        [ ( ConsumerOf ['Chart::GGPlot::Facet'] ),  'facet' ],
        [ ( ConsumerOf ['Chart::GGPlot::Layer'] ),  'add_layer' ],
        [ ( ConsumerOf ['Chart::GGPlot::Labels'] ), 'add_labels' ],
        [ ( ConsumerOf ['Chart::GGPlot::Guide'] ),  'add_guide' ],
        [ ( ConsumerOf ['Chart::GGPlot::Scale'] ),  'add_scale' ],
        [ ( ConsumerOf ['Chart::GGPlot::Theme'] ),  '_set__theme' ],
    ];

    return method(@rest) {
        my $x = $f->(@rest);

        for my $item (@$type_to_method) {
            my ( $type, $add_method ) = @$item;
            if ( $type->check($x) ) {
                $self->$add_method($x);
                return $self;
            }
        }
        die "Invalid data $x got from method $method";
    };
}

my $DEFAULT_BACKEND = 'Plotly';

has backend => (
    is      => 'ro',
    isa     => ConsumerOf ['Chart::GGPlot::Backend'],
    default => sub {
        my $backend_class = "Chart::GGPlot::Backend::$DEFAULT_BACKEND";
        load $backend_class;
        return $backend_class->new();
    },
);

has data   => ( is => 'ro' );
has layers => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
    traits  => ['Array'],
);
has scales => (
    is      => 'ro',
    default => sub { Chart::GGPlot::ScalesList->new() }
);
has mapping => (
    is      => 'ro',
    default => sub { Chart::GGPlot::Aes->new() }
);
has _theme   => ( is => 'rwp', isa => InstanceOf['Chart::GGPlot::Theme'] );
has coordinates => (
    is      => 'rw',
    isa     => Coord,
    default => sub {
        Chart::GGPlot::Coord::Functions::coord_cartesian( default => true );
    },
);
has facet => (
    is      => 'rw',
    isa     => Facet,
    default => sub { Chart::GGPlot::Facet::Functions::facet_null() },
);

has _labels => (
    is      => 'rw',
    default => sub { Chart::GGPlot::Params->new(); },
);

has guides => ( is => 'ro', default => sub { Chart::GGPlot::Guides->new() } );

with qw(MooseX::Clone);

method labels () {
    return $self->make_labels( $self->mapping )
      ->merge( $self->_labels->as_hashref );
}

=method show

    $ggplot->show(HashRef $opts={});

Show the plot (like in web browser).
Implementation depends on the plotting backend.

=method save

    $ggplot->save($filename, HashRef $opts={});

Export the plot to a static image file.
Implementation depends on the plotting backend.

=cut

method show (HashRef $opts={}) {
    $self->backend->show( $self, $opts );
}

method save ($filename, HashRef $opts={}) {
    $self->backend->save( $self, $filename, $opts );
}

=method summary()

Get a useful description of a ggplot object.

=cut

method summary () {
    my $s     = '';
    my $label = fun($l) { sprintf( "%-9s", $l ); };

    #TODO: use Text::Wrap for better format
    if ( $self->data ) {
        $s .=
            &$label("data:")
          . $self->data->names->join(", ")
          . sprintf( " [%sx%s] ", $self->data->nrow, $self->data->ncol ) . "\n";
    }
    if ( $self->mapping->length > 0 ) {
        $s .= &$label("mapping:") . $self->mapping . "\n";
    }
    if ( $self->scales->length() > 0 ) {
        $s .=
          &$label("scales:") . $self->scales->input()->join(", ") . "\n";
    }
    $s .= &$label("faceting: ") . $self->facet . "\n";
    $s .= "-----------------------------------";
    return $s;
}

method add_layer ($layer) {
    push @{ $self->layers }, $layer;

    # Add any new labels
    my $mapping = $self->make_labels($layer->mapping);
    my $defaults = $self->make_labels($layer->stat->default_aes);
    map { $mapping->{$_} //= $defaults->{$_} } keys %$defaults;
    $self->add_labels($mapping);

    return $self;
}

method add_labels ($labels) {
    $self->_labels( $self->_labels->merge($labels) );
    return $self;
}

method add_scale ($scale) {
    $self->scales->add($scale);
    return $self;
}

classmethod make_labels($mapping) {
    state $strip = sub {    # strip_dots() in R ggplot2
        my ($aesthetic, $expr) = @_; 
        unless ($expr->$_DOES('Eval::Quosure')) {
            return $expr;
        }   

        $expr = $expr->expr;

        # TODO: Need PPR here.
        if (looks_like_number($expr)) {
            return $aesthetic;
        }
        elsif ($expr =~ /^\s*stat\s*\((.*)\)/) {
            return trim($1);
        }
        return $expr;
    };  

    my %labels = pairmap { $a => $strip->($a, $b) } $mapping->flatten;
    return \%labels;
}

method theme() {
    use Chart::GGPlot::Global;

    my $default = Chart::GGPlot::Global->theme_current();
    if (my $theme = $self->_theme) {
        if ($theme->is_complete) {
            return $theme;
        }
        else {
            return $theme->defaults($default);
        }
    } else {
        return $default;
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This class represents the ggplot class.
Instead of this class you would usually want to look at L<Chart::GGPlot>,
which is a function interface of this library and is closer to R ggplot2's API.

=head1 SEE ALSO

L<Chart::GGPlot>

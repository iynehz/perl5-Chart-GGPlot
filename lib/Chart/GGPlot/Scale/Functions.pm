package Chart::GGPlot::Scale::Functions;

# ABSTRACT: Scale functions

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use List::AllUtils qw(pairgrep);
use Module::Load;
use Types::Standard qw(CodeRef Str);

use Chart::GGPlot::Aes::Functions qw(:all);
use Chart::GGPlot::Range::Functions qw(:all);
use Chart::GGPlot::Scale::Continuous;
use Chart::GGPlot::Scale::ContinuousPosition;
use Chart::GGPlot::Scale::DiscretePosition;
use Chart::GGPlot::Scale::ContinuousIdentity;
use Chart::GGPlot::Scale::DiscreteIdentity;
use Chart::GGPlot::Trans::Functions qw(as_trans);
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

use parent qw(Exporter::Tiny);

my @export_ggplot = (
    alias_color_functions(
        __PACKAGE__,
        qw(
          continuous_scale discrete_scale
          scale_x_continuous scale_y_continuous
          scale_x_log10 scale_y_log10
          scale_x_reverse scale_y_reverse
          scale_x_sqrt scale_y_sqrt
          scale_x_discrete scale_y_discrete
          scale_x_datetime scale_y_datetime
          scale_color_hue scale_color_discrete
          scale_color_continuous scale_fill_continuous
          scale_color_brewer scale_fill_brewer
          scale_color_distiller scale_fill_distiller
          scale_color_gradient scale_fill_gradient
          scale_color_gradient2 scale_fill_gradient2
          scale_color_gradientn scale_fill_gradientn
          scale_size_continuous
          scale_alpha_continuous scale_alpha
          scale_color_identity scale_shape_identity scale_linetype_identity
          scale_alpha_identity scale_size_identity
          )
    ),
    qw(
      register_scale find_scale
      )
);

our @EXPORT_OK =
  map { $_ =~ /color/ ? ( $_, $_ =~ s/color/color/r ) : $_ } @export_ggplot;
our %EXPORT_TAGS = (
    all    => \@EXPORT_OK,
    ggplot => \@export_ggplot,
);

my %scale_funcs;

=func register_scale($name, $func)

=func find_scale($aes, $x)

Find scale function by aes name and data type. The scale function is in the
form of C<scale_${aes}_${type}>.

=cut

fun register_scale (Str $name, CodeRef $func) {
    $scale_funcs{$name} = $func;
}

fun find_scale ($aes, $x) {
    my $type      = scale_type($x);
    my $func_name = join( '_', "scale", $aes, $type );
    my $f         = $scale_funcs{$func_name};
    return ( wantarray ? ( $f, $func_name ) : $f );
}

# TODO support various kind of types
fun scale_type ($x) {
    if ( $x->$_DOES('PDL::Factor') ) {
        return 'discrete';
    }
    elsif ( $x->$_DOES('PDL::SV') ) {
        return 'discrete';
    }
    elsif ( $x->$_DOES('PDL::DateTime') ) {
        return 'datetime';
    }
    elsif ( $x->$_DOES('PDL') ) {
        if ( $x->type eq 'byte' ) {
            return 'discrete';
        }
        else {
            return 'continuous';
        }
    }
    return 'identity';
}

fun _check_breaks_labels ( $breaks, $labels ) {
    return true if is_null($breaks);
    return true if is_null($labels);

    # In R code there is check for is.atomic(breaks) && is.atomic(labels).
    # List or function is not atomic in R.
    if (   $breaks->$_isa('PDL')
        && $labels->$_isa('PDL')
        && ( $breaks->length != $labels->length ) )
    {
        die("`breaks` and `labels` must have the same length");
    }

    return true;
}

fun continuous_scale (
    : $aesthetics,
    : $scale_name,
    : $palette,
    : $name         = undef,
    : $breaks       = null(),
    : $minor_breaks = undef,
    : $labels       = undef,
    : $limits       = null(),
    : $rescaler     = \&rescale,
    : $oob          = \&censor,
    : $expand       = undef,
    : $na_value     = 'nan',
    : $trans        = "identity",
    : $guide        = "legend",
    PositionEnum : $position = "left",
    : $super        = 'Chart::GGPlot::Scale::Continuous',
    %rest
  ) {
    _check_breaks_labels( $breaks, $labels );

    if (    (  $breaks and $breaks->isempty )
        and !is_position_aes($aesthetics)
        and $guide ne "none" )
    {
        $guide = "none";
    }

    $trans = as_trans($trans);
    if ( defined $limits ) {
        $limits = $trans->transform->( pdl($limits) );
    }

    load $super;
    return $super->new(
        pairgrep { defined $b } 
        (
            aesthetics => $aesthetics,
            scale_name => $scale_name,
            palette    => $palette,
            range      => continuous_range(),
            limits     => $limits,
            trans      => $trans,
            na_value   => $na_value,
            expand     => $expand,
            rescaler   => $rescaler,     # Used by diverging and n color gradients
            oob          => $oob,
            name         => $name,
            breaks       => $breaks,
            minor_breaks => $minor_breaks,
            labels       => $labels,
            guide        => $guide,
            position     => $position,
            %rest
        )
    );
}

fun discrete_scale (
    : $aesthetics,
    : $scale_name,
    : $palette,
    : $name         = undef,
    : $breaks       = undef,
    : $labels       = undef,
    : $limits       = PDL::SV->new([]),
    : $expand       = undef,
    : $na_translate = true,
    : $na_value     = undef,
    : $drop         = true,
    : $guide        = "legend",
    PositionEnum : $position = "left",
    : $super = 'Chart::GGPlot::Scale::Discrete',
    %rest
  ) {

    _check_breaks_labels( $breaks, $labels );

    if (    ( defined $breaks and $breaks->isempty )
        and !is_position_aes($aesthetics)
        and $guide ne "none" )
    {
        $guide = "none";
    }
    return $super->new(
        pairgrep { defined $b }
        (
            aesthetics   => $aesthetics,
            scale_name   => $scale_name,
            palette      => $palette,
            range        => discrete_range(),
            limits       => $limits,
            na_value     => $na_value,
            na_translate => $na_translate,
            expand       => $expand,
            name         => $name,
            breaks       => $breaks,
            labels       => $labels,
            drop         => $drop,
            guide        => $guide,
            position     => $position,
            %rest
        )
    );
}

# In place modification of a scale to change the primary axis
fun scale_flip_position ($scale) {
    state $switch = {
        top    => "bottom",
        bottom => "top",
        left   => "right",
        right  => "left",
    };
    $scale->position( $switch->{ $scale->position } );
}

fun _scale_hue ($aes) {
    return fun(
        : $h         = pdl( [ 0, 360 ] ) + 15,
        : $c         = 100,
        : $l         = 65,
        : $h_start   = 0,
        : $direction = 1,
        : $na_value  = 'grey50', %rest
      )
    {
        return discrete_scale(
            aesthetics => $aes,
            scale_name => 'hue',
            palette    => hue_pal(
                h         => $h,
                c         => $c,
                l         => $l,
                h_start   => $h_start,
                direction => $direction
            ),
            na_value => _na_value_color($na_value),
            %rest
        );
    };
}

*scale_color_hue      = _scale_hue('color');
*scale_color_discrete = \&scale_color_hue;
*scale_fill_hue       = _scale_brewer('hue');

fun _scale_brewer ($aes) {
    return fun(
          ColorBrewerTypeEnum : $type = "seq",
        : $palette   = 0,
        : $direction = 1, %rest
      )
    {
        return discrete_scale(
            aesthetics => $aes,
            scale_name => "brewer",
            palette    => brewer_pal( $type, $palette, $direction ),
            %rest
        );
    };
}

*scale_color_brewer = _scale_brewer('color');
*scale_fill_brewer  = _scale_brewer('fill');

fun _scale_distiller ($aes) {
    return fun(
          ColorBrewerTypeEnum : $type = "seq",
        : $palette   = 1,
        : $direction = -1,
        : $values    = [],
        : $na_value  = "grey50",
        : $guide     = "colorbar",
        %rest
      )
    {
        if ( $type eq "qual" ) {
            warn(   "Using a discrete color palette in a continuous scale.\n"
                  . "  Consider using type = \"seq\" or type = \"div\" instead"
            );
        }
        return continuous_scale(
            aesthetics => $aes,
            scale_name => 'distiller',
            palette    => gradient_n_pal(
                brewer_pal( $type, $palette, $direction )->[6], $values,
            ),
            na_value => _na_value_color($na_value),
            guide    => $guide,
            %rest
        );
    };
}

*scale_color_distiller = _scale_distiller('color');
*scale_fill_distiller  = _scale_distiller('fill');

fun _scale_gradient ($aes) {
    return fun(
        : $low      = "#132B43",
        : $high     = "#56B1F7",
        : $na_value = "grey50",
        : $guide    = "colorbar", %rest
      )
    {
        return continuous_scale(
            aesthetics => $aes,
            scale_name => "gradient",
            palette    => seq_gradient_pal( $low, $high ),
            na_value   => _na_value_color($na_value),
            guide      => $guide,
            %rest
        );
    };
}

*scale_color_gradient = _scale_gradient('color');
*scale_fill_gradient  = _scale_gradient('fill');

fun _mid_rescaler ($mid) {
    return fun( $v, $to = [ 0, 1 ], $from = range( $v, true ) ) {
        rescale_mid( $v, $to, $from, $mid );
    };
}

fun _scale_gradient2 ($aes) {
    return fun(
        : $low      = muted("red"),
        : $mid      = "white",
        : $high     = muted("blue"),
        : $midpoint = 0,
        : $na_value = "grey50",
        : $guide    = "colorbar", %rest
      )
    {
        return continuous_scale(
            aesthetics => $aes,
            scale_name => "gradient2",
            palette    => div_gradient_pal( $low, $mid, $high ),
            na_value   => _na_value_color($na_value),
            guide      => $guide,
            rescaler   => _mid_rescaler($midpoint),
            %rest
        );
    };
}

*scale_color_gradient2 = _scale_gradient2('color');
*scale_fill_gradient2  = _scale_gradient2('fill');

fun _scale_gradientn ($aes) {
    return fun(
        : $values   = [],
        : $na_value = "grey50",
        : $guide    = "colorbar", %rest
      )
    {
        my $colors = ( delete $rest{colors} ) // ( delete $rest{colors} );
        continuous_scale(
            aesthetics => $aes,
            scale_name => "gradientn",
            palette    => gradient_n_pal( $colors, $values ),
            na_value   => _na_value_color($na_value),
            guide      => $guide,
            %rest
        );
    };
}

*scale_color_gradientn = _scale_gradientn('color');
*scale_fill_gradientn  = _scale_gradientn('fill');

fun scale_color_continuous ( : $type = "gradient", %rest ) {

    # TODO: viridis is not available until we port R's viridis package
    state $switch = {
        gradient => \&scale_color_gradient,

        #viridis  => \&scale_color_viridis_c,
    };
    if ( my $func = $switch->{$type} ) {
        return $func->(%rest);
    }
    die("Unknown scale type");
}

fun scale_fill_continuous ( : $type = "gradient", %rest ) {

    # TODO: viridis is not available until we port R's viridis package
    state $switch = {
        gradient => \&scale_fill_gradient,

        #viridis  => \&scale_fill_viridis_c,
    };
    if ( my $func = $switch->{$type} ) {
        return $func->(%rest);
    }
    die("Unknown scale type");
}

fun _scale_position_continuous ($aes) {
    return fun(
        : $name         = undef,
        : $breaks       = undef,
        : $minor_breaks = undef,
        : $labels       = undef,
        : $limits       = [],
        : $expand       = undef,
        : $oob          = \&censor,
        : $na_value     = 'nan',
        : $trans        = 'identity',
        : $position     = "bottom",
        : $sec_axis     = undef,
        %rest,
      )
    {
        if ( defined $sec_axis ) {
            if ( is_formula($sec_axis) ) {
                $sec_axis = sec_axis($sec_axis);
            }
            if ( $sec_axis->$_isa('Chart::GGPlot::AxisSecondary') ) {
                die(
"Secondary axes must be specified using a Chart::GGPlot::AxisSecondary object"
                );
            }
        }

        return continuous_scale(
            aesthetics   => $aes,
            scale_name   => 'position_c',
            palette      => \&identity,
            name         => $name,
            breaks       => $breaks,
            minor_breaks => $minor_breaks,
            labels       => $labels,
            limits       => $limits,
            expand       => $expand,
            oob          => $oob,
            na_value     => $na_value,
            trans        => $trans,
            guide        => "none",
            position     => $position,
            ( $sec_axis ? ( secondary_axis => $sec_axis ) : () ),
            super => 'Chart::GGPlot::Scale::ContinuousPosition',
            %rest
        );
    };
}

*scale_x_continuous = _scale_position_continuous(
    [
        qw(x xmin xmax xend xintercept xmin_final xmax_final xlower xmiddle xupper)
    ]
);
*scale_y_continuous = _scale_position_continuous(
    [qw(y ymin ymax yend yintercept ymin_final ymax_final lower middle upper)]
);

fun scale_size_continuous (:$name=undef, :$breaks=undef, :$labels=undef,
                          :$limits=[], :$range=[1, 6],
                          :$trans='identity', :$guide='legend') {
    return continuous_scale(
        aesthetics => 'size',
        scale_name => 'area',
        palette    => area_pal($range),
        name       => $name,
        breaks     => $breaks,
        labels     => $labels,
        limits     => $limits,
        trans      => $trans,
        guide      => "none",
    );
}

fun scale_alpha_continuous (:$range=[0, 1], %rest) {
    return continuous_scale(
        aesthetics => "alpha",
        scale_name => "alpha_c",
        palette    => rescale_pal($range),
        %rest
    );
}
*scale_alpha = \&scale_alpha_continuous;

for my $trans (qw(log10 reverse sqrt)) {
    for my $aes (qw(x y)) {
        my $scale_func      = "scale_${aes}_${trans}";
        my $continuous_func = "scale_${aes}_continuous";
        no strict 'refs';
        *{$scale_func} = sub { $continuous_func->( @_, trans => $trans ) }
    }
}

fun _scale_discrete ($aes) {
    return fun( : $expand = undef, : $position = "bottom", %rest ) {
        return discrete_scale(
            aesthetics => $aes,
            scale_name => 'position_c',
            palette    => \&identity,
            expand     => $expand,
            guide      => "none",
            position   => $position,
            range_c    => continuous_range(),
            super      => 'Chart::GGPlot::Scale::DiscretePosition',
            %rest
        );
    };
}

*scale_x_discrete = _scale_discrete( [qw(x xmin xmax xend)] );
*scale_y_discrete = _scale_discrete( [qw(y ymin ymax yend)] );

fun scale_continuous_identity ( :$aesthetics, :$guide='none', %rest ) {
    return continuous_scale(
        aesthetics => $aesthetics,
        scale_name => 'identity',
        palette    => identity_pal(),
        guide      => $guide,
        super      => 'Chart::GGPlot::Scale::ContinuousIdentity',
        %rest,
    );
}

fun scale_discrete_identity ( :$aesthetics, :$guide='none', %rest ) {
    return discrete_scale(
        aesthetics => $aesthetics,
        scale_name => 'identity',
        palette    => identity_pal(),
        guide      => $guide,
        super      => 'Chart::GGPlot::Scale::DiscreteIdentity',
        %rest,
    );
}

for my $aes (qw(fill shape linetype color)) {
    my $scale_func = "scale_${aes}_identity";
    no strict 'refs';
    *{$scale_func} = fun(%rest) {
        scale_discrete_identity( %rest, aesthetics => $aes )
    };
}

for my $aes (qw(alpha size)) {
    my $scale_func = "scale_${aes}_identity";
    no strict 'refs';
    *{$scale_func} = fun(%rest) {
        scale_continuous_identity( %rest, aesthetics => $aes )
    };
}

fun datetime_scale (:$aesthetics, :$trans, :$palette,
                    :$breaks = pretty_breaks(), :$minor_breaks = undef,
                    :$labels = undef, :$date_breaks = undef,
                    :$date_labels = undef,
                    :$date_minor_breaks = undef, :$timezone = undef,
                    :$guide = 'legend',
                    %rest) {

    # TODO: handle timezone

    if ( defined $date_breaks ) {
        $breaks = date_breaks($date_breaks);
    }
    if ( defined $date_minor_breaks ) {
        $minor_breaks = date_breaks($date_minor_breaks);
    }
    if ( defined $date_labels ) {
        $labels = sub {
            my ($x) = @_;
            return $x->as_pdlsv;
        };
    }

    my $name = 'datetime';

    state $positional_aes =
      { map { $_ => 1 } qw(x xmin xmax xend y ymin ymax yend) };
    my $scale_class;
    if ( List::AllUtils::all { $positional_aes->exists($_) }
        $aesthetics->flatten )
    {
        if ($name eq 'datetime') {
            $scale_class = 'Chart::GGPlot::Scale::ContinuousDateTime';
        }
    }
    else {
        $scale_class = 'Chart::GGPlot::Scale::Continuous';
    }

    my $sc = continuous_scale(
        aesthetics   => $aesthetics,
        scale_name   => $name,
        palette      => $palette,
        breaks       => $breaks,
        minor_breaks => $minor_breaks,
        labels       => $labels,
        guide        => $guide,
        trans        => $trans,
        super        => $scale_class,
        %rest,
    );

    #$sc->timezone($timezone);
    return $sc;
}

fun _scale_datetime ($aes) {
    return fun(:$name = undef, :$breaks = undef, :$date_breaks = undef,
               :$labels = undef, :$date_labels = undef, 
               :$minor_breaks = undef, :$date_minor_breaks = undef,
               :$timezone = undef,
               :$limits = undef, :$expand = undef,
               PositionEnum :$position = "bottom",
               :$sec_axis = undef) {
        my $sc = datetime_scale(
            aesthetics        => $aes,
            trans             => 'time',
            name              => $name,
            palette           => \&identify,
            breaks            => $breaks,
            date_breaks       => $date_breaks,
            labels            => $labels,
            date_labels       => $date_labels,
            minor_breaks      => $minor_breaks,
            date_minor_breaks => $date_minor_breaks,
            timezone          => $timezone,
            guide             => 'none',
            limits            => $limits,
            expand            => $expand,
            position          => $position,
        );
        return $sc;
    };
}

*scale_x_datetime = _scale_datetime([qw(x xmin xmax xend)]);
*scale_y_datetime = _scale_datetime([qw(y ymin ymax yend)]);

# TODO: remove this
sub _na_value_color { $_[0] }

INIT {
    # register scale functions within this pacakge
    use Package::Stash;

    my $stash   = Package::Stash->new(__PACKAGE__);
    my $symbols = $stash->get_all_symbols('CODE');
    for my $key ( grep { /^scale_/ } keys %$symbols ) {
        register_scale( $key, $symbols->{$key} );
    }
}

1;

__END__

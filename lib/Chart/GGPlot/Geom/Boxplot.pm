package Chart::GGPlot::Geom::Boxplot;

# ABSTRACT: Class for boxplot geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;
use MooseX::Singleton;

extends qw(Chart::GGPlot::Geom::Rect);

# VERSION

use Chart::GGPlot::Aes;
use Chart::GGPlot::Layer::Functions qw(layer);
use Chart::GGPlot::Position::Functions qw(position_dodge2);
use Chart::GGPlot::Util qw(:all);

has '+default_aes' => (
    default => sub {
        Chart::GGPlot::Aes->new(
            weight   => pdl(1),
            color    => PDL::SV->new( ['grey20'] ),
            fill     => PDL::SV->new( ['white'] ),
            size     => pdl(0.5),
            alpha    => NA(),
            shape    => pdl(19),
            linetype => PDL::SV->new( ['solid'] ),
        );
    }
);

classmethod required_aes() { [qw(x lower upper middle ymin ymax)] }
classmethod extra_params () {
    [
        qw(
          fatten
          outlier_color outlier_fill outlier_shape outlier_size
          outlier_stroke outlier_alpha
          notch notchwidth varwidth na_rm width
          )
    ]
}

classmethod ggplot_function() {
    return fun(
            :$data=undef, :$mapping=undef, 
            :$stat='boxplot', :$position='dodge2',
            :$outlier_color=undef, :$outlier_colour=undef,
            :$outlier_fill=undef, :$outlier_shape=undef,
            :$outlier_size=1.5, :$outlier_stroke=undef,
            :$outlier_alpha=undef,
            :$notch=false, :$notchwidth=0.5,
            :$varwidth=false, :$na_rm=false,
            :$show_legend='auto', :$inherit_aes=true,
            %rest)
    {
        if ( not Ref::Util::is_ref($position) ) {
            if ($varwidth) {
                $position = position_dodge2( preserve => 'single' );
            }
        }
        else {
            if ( $position->preserve eq 'total' and $varwidth ) {
                warn "Can't preserve total widths when varwidth is true.";
                $position->preserve('single');
            }
        }

        return layer(
            data        => $data,
            mapping     => $mapping,
            stat        => $stat,
            geom        => 'boxplot',
            position    => $position,
            show_legend => $show_legend,
            inherit_aes => $inherit_aes,
            params      => {
                outlier_color  => ( $outlier_color // $outlier_colour ),
                outlier_fill   => $outlier_fill,
                outlier_shape  => $outlier_shape,
                outlier_size   => $outlier_size,
                outlier_stroke => $outlier_stroke,
                outlier_alpha  => $outlier_alpha,
                notch          => $notch,
                notchwidth     => $notchwidth,
                varwidth       => $varwidth,
                na_rm          => $na_rm,
                %rest
            },
        );
    };
}

method setup_data ($data, $params) {
    unless ( $data->exists('width') ) {
        $data->set( 'width',
            $params->at('width')
              // pdl( resolution( $data->at('x'), false ) * 0.9 ) );
    }

    if ( $data->exists('outliers') ) {
        my $outliers = $data->at('outliers')->unpdl;
        my ( $out_min, $out_max ) = map { pdl( $outliers->map($_) ) } (
            sub { $_->isempty ? "inf"  : $_->min },
            sub { $_->isempty ? "-inf" : $_->max }
        );
        $data->set( 'ymin_final', pmin( $out_min, $data->at('ymin') ) );
        $data->set( 'ymax_final', pmax( $out_max, $data->at('ymax') ) );
    }

    # if 'varwidth' not requested or not available, don't use it
    if (   $params->length == 0
        or !$params->at('varwidth')
        or !$params->at('relvarwidth') )
    {
        $data->set( 'xmin', $data->at('x') - $data->at('width') / 2 );
        $data->set( 'xmax', $data->at('x') + $data->at('width') / 2 );
    }
    else {
        # make 'relvarwidth' relative to the size of the largest group
        my $relvarwidth = $data->at('relvarwidth');
        my $width = $data->at('width');
        $data->set( 'relvarwidth', $relvarwidth / $relvarwidth->max );
        $data->set( 'xmin', $data->at('x') - $relvarwidth * $width / 2 );
        $data->set( 'xmax', $data->at('x') + $relvarwidth * $width / 2 );
    }

    $data->delete('width');
    if ($data->exists('relvarwidth')) {
        $data->delete('relvarwidth');
    }

    return $data;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>

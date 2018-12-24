package Chart::GGPlot::Backend::Plotly;

# ABSTRACT: Plotly backend for Chart::GGPlot

use Chart::GGPlot::Class;

# VERSION

with qw(Chart::GGPlot::Backend);

use Chart::Plotly qw(show_plot);
use Chart::Plotly::Plot;
use Data::Munge qw(elem);
use JSON;
use List::AllUtils qw(pairmap pairwise);
use Module::Load;
use Types::Standard qw(HashRef Int);

use Chart::GGPlot::Aes;
use Chart::GGPlot::Util qw(:all);
use Chart::GGPlot::Backend::Plotly::Geom;
use Chart::GGPlot::Backend::Plotly::Util qw(br);

#TODO: To test and see which value is proper.
our $WEBGL_THRESHOLD = 2000;

method layer_to_traces ($layer, $data, $layout, $plot) {
    return if ( $data->isempty );

    my $geom            = $layer->geom;
    my $class_geom      = ( ref($geom) || $geom );
    my $short           = $class_geom =~ s/^Chart::GGPlot::Geom:://r;
    my $class_geom_impl = "Chart::GGPlot::Backend::Plotly::Geom::$short";

    my $params = $layer->geom_params->hslice( $class_geom->parameters );
    my $coord  = $layout->coord;

    my %discrete_scales = map {
        my $scale = $_;
        if ( $scale->$_DOES('Chart::GGPlot::Scale::Discrete') ) {
            map { $_ => $scale } @{ $scale->aesthetics };
        }
        else {
            ();
        }
    } @{ $plot->scales->non_position_scales->scales };

    my @split_legend = map { "${_}_raw" } ( sort keys %discrete_scales );

    my $panel_to_traces = fun( $d, $panel_params ) {

        my $all_aesthetics = Chart::GGPlot::Aes->all_aesthetics;

        my $labels = $plot->labels;
        # put x and y at first in plotly hover text
        my @hover_aes = (
            qw(x y),
            (
                sort grep {
                    $_ ne 'x' and $_ ne 'y' and elem( $_, $all_aesthetics )
                } @{ $labels->keys }
            )
        );

        my @hover_data = map {
            my $var = $labels->at($_);
            if ( $var->$_DOES('Eval::Quosure') ) {
                $var = $var->expr;
            }
            my $col =
                $d->exists("${_}_raw") ? $d->at("${_}_raw")
              : $d->exists($_)         ? $d->at($_)
              :                          undef;
            if (defined $col) {
                if ( $col->$_DOES('PDL::Factor') ) {
                    my $levels = $col->levels;
                    $col = $col->unpdl->map( sub { $levels->at($_); } );
                }
                ( $var => $col );
            } else {
                ();
            }
        } @hover_aes;
        my $hover_text = [ 0 .. $d->nrow - 1 ]->map(
            sub { join( br(), pairmap { "$a: " . $b->at($_) } @hover_data ); }
        );

        $d->set( 'hovertext', PDL::SV->new($hover_text) );

        #my $na_rm = $params->at('na_rm') // false;
        my $show_legend =
          @split_legend->intersect( $data->names )->length;

        my $splitted = $d->split( $d->at('group') );
        my @group_ids = sort { $a <=> $b } keys %$splitted;

        return @group_ids->map(
            sub {
                my $d = $splitted->{$_};

                my $trace = $class_geom_impl->to_trace($d);

                # If we need a legend, set legend info.
                if ($show_legend) {
                    my $legend_key = join(
                        ', ',
                        map {
                            if ( $d->exists($_) ) {
                                my $col_data = $d->at($_);
                                if ( $col_data->$_DOES('PDL::Factor') ) {
                                    $col_data->levels->at( $col_data->at(0) );
                                }
                                else {
                                    $col_data->at(0);
                                }
                            }
                            else {
                                ();
                            }
                        } @split_legend
                    );
                    $trace->{showlegend} = JSON::true;
                    $trace->{name}       = $legend_key;
                }
                return $trace;
            }
        );
    };

    my $splitted = $data->split( $data->at('PANEL') );
    return [
        pairmap {
            my ( $panel_idx, $data ) = ( $a, $b );

            my $panel_params = $layout->panel_params->at($panel_idx);
            $panel_to_traces->( $data, $panel_params );
        }
        %$splitted
    ];
}

=method to_plotly

Returns a Chart::GPlotly object.

=cut

method to_plotly ($plot_built) {
    my $plot   = $plot_built->plot;
    my $layers = $plot->layers;
    my $layout = $plot_built->layout;

    my $plotly = Chart::Plotly::Plot->new();

    my $scales       = $layout->get_scales(0);
    my $panel_params = $layout->panel_params->at(0);

    my %plotly_layout = ();
    my $labels        = $plot->labels;
    if ( exists $labels->{title} ) {
        $plotly_layout{title} = $labels->{title};
    }
    for my $xy (qw(x y)) {

        #my $sc;
        #if ( $plot->coordinates->DOES('Chart::GGPlot::Coord::Flip') ) {
        #    $sc = $scales->{ ( $xy eq 'x' ? 'y' : 'x' ) };
        #}
        #else {
        #    $sc = $scales->{$xy};
        #}

        my $axis_title = $labels->at($xy) // '';

        my $labels       = $panel_params->{"$xy.labels"}->unpdl;
        my $major_source = $panel_params->{"$xy.major_source"}->unpdl;
        my %ticks = pairwise { $a => $b } @$major_source, @$labels;

        # There is not necessarily minor ticks for an axis.
        my $minor_source = $panel_params->{"$xy.minor_source"};
        my $tickvals =
          defined $minor_source ? $minor_source->unpdl : $major_source;
        my $ticktext = [ map { $ticks{$_} // '' } @$tickvals ];

        $plotly_layout{"${xy}axis"} = {
            title    => $axis_title,
            ticktext => $ticktext,
            tickvals => $tickvals,
        };
    }

    for my $i ( 0 .. $#$layers ) {
        my $layer = $layers->[$i];
        my $data  = $plot_built->data->[$i];

        $log->debug( "data at layer $i:\n" . $data->string ) if $log->is_debug;

        my $panels_traces =
          $self->layer_to_traces( $layer, $data, $layout, $plot );
        for my $panel (@$panels_traces) {
            for my $trace (@$panel) {
                $plotly->add_trace($trace);
            }

            if ( List::AllUtils::any { $_->showlegend } @$panel ) {
                $plotly_layout{showlegend} = JSON::true;

                # legend title
                #
                # TODO: See if plotly will officially support legend title
                #  https://github.com/plotly/plotly.js/issues/276
                my $legend_titles =
                  join( "\n", map { $_->title } @{ $plot->guides->guides } );

                my $annotations = $plotly_layout{annotations} //= [];
                push @$annotations,
                  {
                    x         => 1.02,
                    y         => 1,
                    xanchor   => 'left',
                    yanchor   => 'bottom',
                    text      => $legend_titles,
                    showarrow => JSON::false,
                    xref      => 'paper',
                    yref      => 'paper',
                  };

                # Default right margin is too small for legend title.
                #
                # TODO: How to automatically calc the margin?
                #  May need to use libraries like Cairo for text width?
                #  Best if plotly can natively support legend title.
                $plotly_layout{margin} = { r => 150 };
            }
        }
    }

    $log->debug( "plotly layout : " . Dumper( \%plotly_layout ) )
      if $log->is_debug;

    $plotly->layout( \%plotly_layout );

    #$log->trace( "plotly html:\n" . $plotly->html ) if $log->is_trace;

    return $plotly;
}

=method show

Show the plot in browser. 

=method save

Not implemented yet.

=cut

method show ($ggplot, HashRef $opts={}) {
    my $plot_built = $self->build($ggplot);
    my $plotly     = $self->to_plotly($plot_built);
    show_plot($plotly);
}

method save ($ggplot, $filename, HashRef $opts={}) {
    # TODO: https://github.com/pablrod/p5-Chart-Plotly/issues/8
    ...;
}

1;

__END__

=head1 DESCRIPTION

The Plotly backend for Chart::GGPlot.

=head1 SEE ALSO

L<https://plot.ly/|Plotly>

L<Chart::GGPlot::Backend>, L<Chart::Plotly>


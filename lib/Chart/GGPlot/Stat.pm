package Chart::GGPlot::Stat;

# ABSTRACT: The stat role

use Chart::GGPlot::Role qw(:pdl);
use namespace::autoclean;

# VERSION

use List::AllUtils qw(reduce pairmap);
use Types::Standard qw(ArrayRef CodeRef Str InstanceOf Bool);
use Types::PDL -types;

use Data::Frame;
use Chart::GGPlot::Trans;
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(remove_missing stat);

has retransform => ( is => 'ro' );

with qw(
  Chart::GGPlot::HasRequiredAes
  Chart::GGPlot::HasDefaultAes
  Chart::GGPlot::HasNonMissingAes
  Chart::GGPlot::HasParams
  Chart::GGPlot::HasCollectibleFunctions
);

method setup_data ( $data, $params ) { $data }

method setup_params ( $data, $params ) { $params }

method compute_layer ( $data, $params, $layout ) {
    $self->check_required_aes(
        [ @{ $data->names }, @{ $params->names } ] );

    $data = remove_missing(
        $data,
        na_rm  => $params->at('na_rm'),
        vars   => [ @{ $self->required_aes }, @{ $self->non_missing_aes } ],
        name   => ref($self),
        finite => true,
    );

    # Trim off extra parameters
    my $params =
      $params->slice( $params->names->intersect($self->parameters) );

    my $splitted = $data->split( $data->at('PANEL') );
    return (
        reduce { $a->cbind($b) } $splitted->keys->map(
            sub {
                my ($panel_id) = @_;
                my $d = $splitted->{$panel_id};

                my $scales = $layout->get_scales( $d->at('PANEL')->at(0) );

                try {
                    return $self->compute_panel( $d, $scales, $params );
                }
                catch {
                    warn
                      sprintf( "Computation failed in '%s': $@", ref($self) );
                    return;
                }
            }
        )->flatten
    );
}

method compute_panel ( $data, $scales, $params ) {
    return Data::Frame->new() if ( $data->isempty );

    my $groups = $data->split( $data->at('group') );
    my $stats = {
        pairmap { $a => $self->compute_group( $b, $scales, $params ); }
        %$groups
    };

    # cbind the result of compute_group() with splitted df,
    #  and also rbind to form one df that corresponds to the $data.
    $stats = [
        map {   # $_ is group id
            my $new_df  = $stats->{$_};
            my $old_df  = $groups->{$_};
            my $missing = $old_df->names->setdiff($new_df->names);
            for my $colname (@$missing) {
                $new_df->set( $colname,
                    $old_df->at($colname)->slice( pdl( [0] ) ) );
            }
            $new_df;
        } sort { $a <=> $b } @{ $stats->keys }
    ];

    return reduce { $a->rbind($b) } @$stats;
}

method compute_group ( $data, $scales ) { ... }

method finish_layer ( $data, $param ) { $data }

method aesthetics () {
    my @names = List::AllUtils::uniq( @{ $self->required_aes },
        @{ $self->default_aes->names }, 'group' );
    return \@names;
}

1;

__END__

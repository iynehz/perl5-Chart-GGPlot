package Chart::GGPlot::Stat;

# ABSTRACT: The stat role

use Chart::GGPlot::Role qw(:pdl);

# VERSION

use Types::Standard qw(ArrayRef CodeRef Str InstanceOf Bool);
use Types::PDL -types;

use Data::Frame::More;
use Chart::GGPlot::Trans;
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

has retransform => ( is => 'ro' );

with qw(
  Chart::GGPlot::HasRequiredAes
  Chart::GGPlot::HasDefaultAes
  Chart::GGPlot::HasNonMissingAes
  Chart::GGPlot::HasParams
);

method setup_data ( $data, $params ) { $data }

method setup_params ( $data, $params ) { $params }

method compute_layer ( $data, $params, $layout ) {
    $self->check_required_aes(
        [ @{ $data->keys }, @{ $params->keys } ] );

    $data = remove_missing(
        $data,
        $params->at('na_rm'),
        [ @{ $self->required_aes }, @{ $self->non_missing_aes } ],
        ref($self), true
    );

    # Trim off extra parameters
    my $params =
      $params->hslice( $params->keys->intersect($self->parameters) );

    my $scales = $layout->get_scales( $data->at('PANEL') );
    my @args = ( $data, $scales, $params );
    return $data;
}

method compute_panel ( $data, $scales, @rest ) {
    if ( $data->isempty ) {
        return Data::Frame::More->new();
    }
    my $groups = $data->split( $data->at('group') );
    my $stats =
      $groups->map( sub { $_ => $self->compute_group( $_, $scales, @rest ) } );

    # TODO I don't very understand the logic in R here

    #stats <- mapply(function(new, old) {
    #  if (empty(new)) return(data.frame())
    #  unique <- uniquecols(old)
    #  missing <- !(names(unique) %in% names(new))
    #  cbind(
    #    new,
    #    unique[rep(1, nrow(new)), missing,drop = FALSE]
    #  )
    #}, stats, groups, SIMPLIFY = FALSE)
    #
    #do.call(plyr::rbind.fill, stats)

    return $stats;
}

method compute_group ( $data, $scales ) { ... }

method finish_layer ( $data, $param ) { $data }

method aesthetics () {
    my @names = List::AllUtils::uniq( @{ $self->required_aes },
        @{ $self->default_aes->keys }, 'group' );
    return \@names;
}

1;

__END__

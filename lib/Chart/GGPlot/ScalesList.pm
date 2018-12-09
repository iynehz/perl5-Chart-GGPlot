package Chart::GGPlot::ScalesList;

# ABSTRACT: Encapsulation multiple scale objects

use Chart::GGPlot::Class qw(:pdl);

# VERSION

use List::AllUtils qw(pairmap pairkeys);
use Types::Standard qw(Any ArrayRef Object);
use Type::Params;
use PDL::Primitive qw(which);

use Chart::GGPlot::Scale::Functions qw(find_scale);
use Chart::GGPlot::Types qw(:all);
use Chart::GGPlot::Util qw(:all);

=attr scales

Returns an arrayref of scales object with the ScalesList object.

=cut

has scales => ( is => 'rw', isa => ArrayRef, default => sub { [] } );

=method find($aesthetic)

Returns an arrayref of indexes. 

=cut

sub find {
    state $check = Type::Params::compile( Object,
        ArrayRef->plus_coercions(ArrayRefFromAny) );
    my ( $self, $aesthetic ) = $check->(@_);

    return PDL->pdl(
        map { $_->aesthetics->intersect($aesthetic)->length > 0 }
          @{ $self->scales } );
}

=method has_scale($aesthetic)

=cut

method has_scale ($aesthetic) {
    return !!( $self->find($aesthetic)->any );
}

method add ($scale) {
    return unless $scale;

    my $prev_aes = $self->find( $scale->aesthetics );
    if ( $prev_aes->any ) {
        my $aes_name =
          $self->scales->slice( $prev_aes->flatten )->aesthetics->[0];
        my $message =
          sprintf( "Scale for '%s' is already present. "
              . "Adding another scale for '%s', which will replace the existing scale.",
            $aes_name, $aes_name );
        warn($message);

        # Remove old scale for this aesthetic (if it exists)
        $self->scales = $self->scales->slice( !$prev_aes );
    }
    $self->scales->push($scale);
}

method length () { $self->scales->length; }

method input () {
    return $self->scales->map( sub { @{ $_->aesthetics } } );
}

method non_position_scales () {
    my $class   = ref($self);
    my @indices = which( !$self->find('x') & !$self->find('y') )->flatten;
    return $class->new( scales => $self->scales->slice( \@indices ) );
}

=method get_scales($output)

Returns the first scale object found.

=cut

method get_scales ($output) {
    my $indexes = which( $self->find($output) );
    return undef if ( $indexes->isempty );
    return $self->scales->at( $indexes->at(0) );
}

method isempty () { $self->scales->isempty }

=method train_df($df)

Train scales from a dataframe.

=cut

method train_df ($df, $drop=false) {
    return [] if ( $df->isempty or $self->isempty );

    return $self->scales->map( sub { $_->train_df($df) } );
}

=method map_df($df)

Map values from a dataframe.
Returns a dataframe whose columns processed to map to the scales' limits.

=cut

method map_df ($df) {
    return $df if ( $df->isempty or $self->isempty );

    my $mapped = $self->scales->map(
        sub {
            my $href = $_->map_df($df);
            map { $_ => $href->{$_} } sort keys %$href;
        }
    );
    return Data::Frame::More->new(
        columns => [
            @$mapped,
            $df->names->setdiff( [ pairkeys @$mapped ] )
              ->map( sub { $_ => $df->at($_) } )->flatten
        ]
    );
}

# Transform values to cardinal representation
method transform_df ($df) {
    return $df if ( $df->isempty or $self->isempty );

    my $transformed = $self->scales->map( sub { $_->transform_df($df) } );
    return Data::Frame::More->new(
        columns => [
            @$transformed,
            aref_diff( $df->names, [ pairkeys @$transformed ] )
              ->map( sub { $_ => $df->at($_) } )->flatten
        ]
    );
}

# aesthetics: a list of aesthetic-variable mappings. The name of each
#  item is the aesthetic, and the value of each item is the valiable in data.
method add_defaults ($data, $aesthetics) {
    return if ( $aesthetics->isempty );

    my $new_aesthetics = $aesthetics->names->setdiff( $self->input );

    # No new aesthetics, so no new scales to add
    return if ( $new_aesthetics->isempty );

    my %datacols = pairmap { $a => $data->eval_tidy($b) }
    ( $aesthetics->hslice($new_aesthetics)->flatten );
    for my $aes ( sort keys %datacols ) {
        my ( $scale_f, $func_name ) = find_scale( $aes, $datacols{$aes} );
        unless ( defined $scale_f ) {
            die sprintf(
                "Cannot find scale for aes %s. Missing a function of name %s",
                $aes, $func_name );
        }
        $log->debugf(
            "ScalesList::add_defaults : Got scale function %s for aes %s",
            $func_name, $aes );
        $self->add( $scale_f->() );
    }
}

# Add missing but required scales. $aes_names is typically [qw(x y)].
method add_missing ($aes_names) {
    state $check =
      Type::Params::compile( ArrayRef->plus_coercions(ArrayRefFromAny) );
    ($aes_names) = $check->($aes_names);

    for my $aes ( @{ $aes_names->setdiff( $self->input ) } ) {
        my $scale_name = "scale_${aes}_continuous";
        no strict 'refs';
        my $scale_f = \&{"Chart::GGPlot::Scale::Functions::$scale_name"};
        $self->add( $scale_f->() );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__


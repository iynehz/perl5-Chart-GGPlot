package Chart::GGPlot::Geom::Path;

# ABSTRACT: Class for path geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

use List::AllUtils qw(reduce);
use PDL::Primitive qw(which);

use Chart::GGPlot::Aes;
use Chart::GGPlot::Util qw(:all);

with qw(Chart::GGPlot::Geom);

has '+non_missing_aes' => ( default => sub { [qw(size shape color)] } );
has '+default_aes'     => (
    default => sub {
        Chart::GGPlot::Aes->new(
            color    => PDL::SV->new( ['black'] ),
            size     => pdl(0.5),
            linetype => PDL::SV->new( ['solid'] ),
            alpha    => NA(),
        );
    }
);

classmethod required_aes () { [qw(x y)] }

method handle_na ($data, $params) {

    # Drop missing values at the start or end of a line - can't drop in the
    # middle since you expect those to be shown by a break in the line

    # are each row all good or not?
    state $complete_cases = sub {
        my @piddles = @_;

        my @isgood = map { $_->badflag ? $_->isgood : () } @piddles;
        if ( @isgood == 0 ) {
            return PDL::Core::ones( $piddles[0]->length );
        }
        else {
            return ( reduce { $a & $b } ( shift @isgood ), @isgood );
        }
    };

    # group by $grouping and average by $fun
    state $ave = sub {
        my ( $x, $grouping, $fun ) = @_;
        my $new = $x->copy;
        for my $g ( $grouping->uniq->flatten ) {
            my $sliced   = $new->slice( which( $x == $g ) );
            my $averaged = $fun->($sliced);
            $sliced .= $averaged;
        }
        return $new;
    };

    my $complete =
      $complete_cases->( map { $data->at($_) } qw(x y size color linetype) );
    my $kept = $ave->( $complete, $data->at('group'),
        sub { $self->_keep_mid_true(@_) } );

    if ( not $kept->all and not $params->{na_rm} ) {
        warn sprintf( "Removed %s rows containing missing values (geom_path).",
            ( !$kept )->sum );
    }

    return ( $kept->all ? $data : $data->select_rows( which($kept) ) );
}

# Trim false values from left and right: keep all values from
# first TRUE to last TRUE
classmethod _keep_mid_true ($x) {
    my $is_true = which($x);
    unless ( $is_true->length ) {
        return PDL::Core::zeros( $x->length );
    }
    my $first = $is_true->at(0);
    my $last  = $is_true->at(-1);

    return pdl(
        ( (0) x $first ),
        ( (1) x ( $last - $first ) ),
        ( (0) x ( $x->length - $last ) )
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

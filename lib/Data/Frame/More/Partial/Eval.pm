package Data::Frame::More::Partial::Eval;

# ABSTRACT: Partial class for data frame's eval method

use Data::Frame::More::Role;
use namespace::autoclean;

# VERSION

use Eval::Quosure;
use Types::Standard;

use Data::Frame::More::Indexer qw(loc);

=method eval_tidy

    eval_tidy($x)

=cut

method eval_tidy ($x) {
    my $is_quosure = $x->$_DOES('Eval::Quosure');
    if (ref($x) and not $is_quosure) {
        return $x;
    }

    my $expr = $is_quosure ? $x->expr : $x;
    if ( $self->exists($expr) ) {
        return $self->at( loc($expr) );
    }

    my $quosure = $is_quosure ? $x : Eval::Quosure->new( $expr, 1 );

    # If expr matches a column name in the data frame, return the column.
    my $column_vars = {
        $self->names->map(
            sub {
                my $var = '$' . ( $_ =~ s/\W/_/gr );
                $var => $self->at($_);
            }
        )->flatten
    };

    return $quosure->eval($column_vars);
}

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

L<Data::Frame::More>, L<Eval::Quosure>


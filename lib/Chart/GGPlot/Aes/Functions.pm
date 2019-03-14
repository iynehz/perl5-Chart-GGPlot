package Chart::GGPlot::Aes::Functions;

# ABSTRACT: Function interface for aesthetics mappings

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use Eval::Quosure;
use List::AllUtils qw(pairmap);
use Scalar::Util qw(looks_like_number);
use Type::Params;
use Types::Standard qw(ArrayRef);

use Chart::GGPlot::Aes;
use Chart::GGPlot::Types qw(:all);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  aes aes_all aes_to_scale is_position_aes
);
our %EXPORT_TAGS = (
    'all'    => \@EXPORT_OK,
    'ggplot' => [qw(aes aes_all)],
);

=func aes

    aes(%aesthetics_mapping);

This function is not exactly same as C<Chart::GGPlot::Aes-E<gt>new()>. This
function is specifically for creating aesthetics mapping which specifies
the mapping from data to aesthetics. Returned aes object from this function
is usually used for the C<mapping> attr of C<Chart::GGPlot::Plot> objects or
C<Chart::GGPlot::Geom> objects.

Values of C<%aesthetics_mapping> need to be one of the following:

=for :list
* An C<Eval::Quosure> object.
* Anything else would be stringified and converted to an C<Eval::Quosure>
object with enviroment be caller of the C<aes()> function.

=cut

fun aes (%mapping) { _aes( \%mapping ); }

my $aes_level_default = 3;

fun _aes ($mapping, $level=$aes_level_default) {
    my %params = pairmap {
        my $val;

        # TODO: Shall we also support coderef sub { my ($df) = @_; } ?
        #  Thing is, is that really needed?

        if ( $b->$_DOES('Eval::Quosure') ) {
            $val = $b;
        }
        else {
            $val = Eval::Quosure->new( $b . '', $level );
        }
        $a => $val;
    }
    %$mapping;
    return Chart::GGPlot::Aes->new(%params);
}

# Look up the scale that should be used for a given aesthetic
sub aes_to_scale {
    state $check =
      Type::Params::compile( ArrayRef->plus_coercions(ArrayRefFromAny) );
    my ($aes_names) = $check->(@_);

    my $rename = fun($n) {
        if ( grep { $n eq $_ } qw(x xmin xmax xend xintercept) ) {
            return 'x';
        }
        if ( grep { $n eq $_ } qw(y ymin ymax yend yintercept) ) {
            return 'y';
        }
        return $n;
    };
    my @new_names =
      map { &$rename($_) }
      map { Chart::GGPlot::Aes->transform_key($_) } @$aes_names;
    return \@new_names;
}

# Figure out if an aesthetic is a position aesthetic or not
fun is_position_aes ($aes_names) {
    my $new_names = aes_to_scale($aes_names);
    return ( List::AllUtils::all { $_ eq 'x' or $_ eq 'y' } @$new_names );
}

=method aes_all

    aes_all(@aes_names)

Given a array of aes names, create a set of identity mappings, that is
like C<aes(x =E<gt> 'x', y =E<gt> 'y', ...)>.

=cut

fun aes_all (@names) {
    return _aes( { map { $_ => $_ } @names }, $aes_level_default );
}

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Aes>, L<Eval::Quosure>

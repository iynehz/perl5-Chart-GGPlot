package Data::Frame::More::Indexer;

# ABSTRACT: Function interface for indexer

use Data::Frame::More::Setup;

# VERSION

use Types::PDL qw(Piddle1D);

use Data::Frame::More::Indexer::ByIndex;
use Data::Frame::More::Indexer::ByLabel;
use Data::Frame::More::Types qw(:all);

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(loc iloc);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

=func loc($x)

Returns either undef or an indexer object, by trying below rules,

=for :list
* If called with no arguments or if the argument is undef, return undef.
* If the argument is an indexer object, just return it.
* If the argument is a PDL of numeric types, create an indexer object
of L<Data::Frame::More::Indexer::ByIndex> 
* Fallbacks to create an indexer object of
L<Data::Frame::More::Indexer::ByLabel>.

=func iloc($x)

Similar to C<loc> but would fallback to an indexer object of
L<Data::Frame::More::Indexer::ByIndex>.

=cut

my $NumericPiddle1D =
  Piddle1D->where( sub { $_->type ne 'byte' and not $_->$_isa('PDL::SV') } );

fun _as_indexer ($fallback_indexer_class) {
    return sub {
        my $x = @_ > 1 ? \@_ : $_[0];
        return undef if ( not defined $x );

        unless ( Ref::Util::is_ref($x) ) {
            $x = [$x];
        }
        return $x if ( Indexer->check($x) );

        if ( $NumericPiddle1D->check($x) ) {
            return Data::Frame::More::Indexer::ByIndex->new(
                indexer => $x->unpdl );
        }
        $fallback_indexer_class->new( indexer => $x );
    };
}

*loc  = _as_indexer('Data::Frame::More::Indexer::ByLabel');
*iloc = _as_indexer('Data::Frame::More::Indexer::ByIndex');

1;

__END__

=head1 DESCRIPTION

A basic feature needed in a data frame library is the ability of subsetting
a data frame by either numeric indices or string labels of columns and rows.
Because of the ambiguity of number and string in Perl, there needs a way to 
allow user to explicitly specify whether their indexer is by numeric
indices or string labels. This modules provides functions that serves this
purpose. 
 

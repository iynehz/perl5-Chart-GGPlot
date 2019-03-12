package Chart::GGPlot::Params;

# ABSTRACT: Collection of key-value pairs used in Chart::GGPlot

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);

# VERSION

use List::AllUtils qw(pairgrep pairmap);
use Storable qw(dclone);
use Type::Params;
use Types::Standard qw(HashRef);
use namespace::autoclean;

use Chart::GGPlot::Types qw(GGParams);

classmethod new (@rest) {
    my %params = ( @rest == 1 ? %{ $rest[0] } : @rest );
    my $self = bless {
        _hash => %params->rename( sub { $class->transform_key( $_[0] ) } )
      },
      $class;
    return $self;
}

sub _hash { $_[0]->{_hash} }

=classmethod transform_key

    transform_key($key)

Derived classes can override this classmethod to have their own way
of renaming the keys.

=cut

classmethod transform_key ($key) { $key }

=method length

    length()

Returns the count of keys.

=cut

method length () { scalar(@{$self->keys}); }

=method exists

    exists($key)

Tests if a key exists.

=cut

method exists ($key) { exists $self->_hash->{ $self->transform_key($key) }; }

=method keys

    keys()

Return an array ref of keys. 

=method names

    names()

This is an alias of the C<keys()> method.

=cut

method keys () { [ CORE::keys %{ $self->_hash } ]; }
sub names { $_[0]->keys }

=method values

    values()

Return an array ref of values. 

=cut

method values () {
    [ map { $self->at($_) } @{ $self->keys } ];
}

=method isempty

    isempty()

Return a boolean value if length is 0.

=cut

method isempty () { $self->length == 0; }

=method delete

    delete($key)

=cut

method delete ($key) {
    delete $self->_hash->{ $self->transform_key($key) };
}

=method set

    set($key, $value)

Associate a value with a key and return the value.

=cut

method set ( $key, $value ) {
    $self->_hash->{ $self->transform_key($key) } = $value;
}

=method at

    at($key)

Get associated value of the given key.

=cut

method _at ($key) { $self->_hash->{$key}; }

method at ($key) { $self->_hash->{ $self->transform_key($key) }; }

=method flatten

    flatten()

Returns an array.

=cut

method flatten () {
    map { $_ => $self->_at($_) } @{ $self->keys };
}

=method hslice

    hslice($keys)

=method slice

    slice($keys)

This is an alias of C<hslice>.

=cut

method hslice ($keys) {
    my $class = ref($self);
    return bless( { _hash => { map { $_ => $self->at($_) } @$keys } }, $class );
}
*slice = \&hslice;

=method kv

    kv()

Return a list of a value with a key and return the value.

=cut

method kv () {
    return [ map { [ $_ => $self->_at($_) ] } @{ $self->keys } ];
}

=method merge

    merge($other, $skip_undef=false)

Returns a new object with right precedence shallow merging.
If C<$skip_undef> is true, kv with C<undef> value in C<$other>
would be skipped. 

    my $merged = $params->merge($other);

=cut

method merge ($other, $skip_undef=false) {
    ($other) = Type::Params::validate( [$other],
        GGParams->plus_coercions( HashRef, sub { ref($self)->new($_) } ) );

    my @other_data = $other->flatten;
    if ($skip_undef) {
        @other_data = pairgrep { defined $b } @other_data;
    }
    my $class = ref($self);
    return bless( { _hash => { $self->flatten, @other_data } }, $class );
}

=method defaults

    defaults($other)

Using data from C<$other> as defaults.
If C<$other> is C<undef>, returns a clone of C<$self>.

=cut

method defaults ($other) {
    return $self->clone unless defined $other;
    return $other->merge( $self, true );
}

=method rename

    rename($href_or_coderef)

Returns a new object.

    my $p2 = $p1->rename( { $from_key => $to_key, ... } );
    
=cut

method rename ($href_or_coderef) {
    my $class = ref($self);

    my $new_hash;
    if ( Ref::Util::is_coderef($href_or_coderef) ) {
        my $f = sub { $href_or_coderef->( $self->transform_key( $_[0] ) ) };
        $new_hash = $self->_hash->rename($f);
    }
    else {
        my $mapping = {
            pairmap { $self->transform_key($a) => $self->transform_key($b) }
            $href_or_coderef->flatten
        };
        $new_hash = $self->_hash->rename($mapping);
    }
    return bless( { _hash => $new_hash }, $class );
}

=method as_hashref

    as_hashref()

Returns a hashref.

=cut

method as_hashref () { $self->_hash; }

=method copy

    copy()

=method clone

    clone()

This is same as the C<copy()> method.

=cut

method copy () {
    return dclone($self);
}

*clone = \&copy;

1;

__END__

=head1 DESCRIPTION

This class provides a duck typing interface similar as
L<Data::Frame::Autobox::HashRef>, and adds a mechanism to its
derived classes to customize aliasing of hash keys by overriding
the C<transform_key> classmethod.

=head1 SEE ALSO

L<Data::Frame::Autobox::HashRef>


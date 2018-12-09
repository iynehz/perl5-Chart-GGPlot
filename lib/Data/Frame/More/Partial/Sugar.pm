package Data::Frame::More::Partial::Sugar;

# ABSTRACT: Partial class for data frame syntax sugar

use Data::Frame::More::Role;

# VERSION

use Types::Standard;

package Tie::Data::Frame::More {
    sub new {
        my ($class, $object) = @_;
        return bless( { _object => $object }, $class);
    }

    sub TIEHASH {
        my $class = shift;
        return $class->new(@_);
    }

    sub object { $_[0]->{_object} }

    sub STORE {
        my ( $self, $key, $val ) = @_;
        if ( Ref::Util::is_ref($key) ) {
            $self->object->slice($key) .= $val;
        } else {
            $self->object->set($key, $val);
        }
    }

    sub FETCH {
        my ( $self, $key ) = @_;
        if ( Ref::Util::is_ref($key) ) {
            return $self->object->slice($key);
        } else {
            return $self->object->at($key);
        }
    }

    sub FIRSTKEY {
        my ($self) = @_;
        return shift @{$self->{_list}};
    }

    sub NEXTKEY {
        my ($self) = @_;
        return shift @{$self->{_list}};
    }
}

use overload (
    '%{}' => sub {    # for working with Tie::Data::Frame::More
        my ($self)   = @_;
        my ($caller) = caller();
        if ( $caller =~ /^Method::Generate::Accessor::/ ) {
            return $self;
        }
        return ( $self->_tie_hash // $self );
    },
    fallback => 1
);

has _tie_hash => ( is => 'rw' );

method _initialize_sugar() {
    my %hash;
    tie %hash, qw(Tie::Data::Frame::More), $self;
    $self->_tie_hash( \%hash );
}

1;

__END__

=head1 SYNOPSIS

    use Data::Frame::More::Examples qw(mtcars);
    
    # A key of string type does at() or set()
    my $col1 = $mtcars->{mpg};                  # $mtcars->at('mpg');
    $mtcars->{kpg} = $mtcars->{mpg} * 1.609;    # $mtcars->set('kpg', ...);

    # A key of reference does slice() 
    my $col2 = $mtcars->{ ['mpg'] };            # $mtcars->slice(['mpg']);
    my $subset = $mtcars->{ [qw(mpg cyl)] };    # $mtcars->slice([qw(mpg cyl]);

=head1 DESCRIPTION

=head1 SEE ALSO

L<Data::Frame::More>


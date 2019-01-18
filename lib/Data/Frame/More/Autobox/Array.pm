package Data::Frame::More::Autobox::Array;

# ABSTRACT: Addtitional Array role for Moose::Autobox

use 5.016;
use Moose::Role;
use Function::Parameters;

use List::AllUtils;
use POSIX qw(ceil);

# VERSION

use namespace::autoclean;

=method isempty() 

Returns a boolean value for if the array ref is empty.

=method uniq()

=method set($idx, $value)

This is same as the C<put> method of Moose::Autobox::Array.

=cut

method isempty() { @{$self} == 0 }

method uniq() { [ List::AllUtils::uniq(@{$self}) ] }

method set($index, $value) { 
    $self->[$index] = $value;
}

method repeat($n) {
    return [ (@$self) x $n ];
}

method repeat_to_length($length) {
    return $self if @$self == 0;
    my $x = repeat($self, ceil($length / @$self));
    return [ @$x[0 .. $length-1] ];
}

method clone() { [ @{$self} ] }

=method intersect($other)

=method union($other)

=method setdiff($other)

=cut

method intersect ( $other ) { 
    my %hash = map { $_ => 1 } @$self;
    return [ grep { exists $hash{$_} } @$other ];
}

method union ($other) {
    return [ List::AllUtils::uniq( @$self, @$other ) ];
}

method setdiff ($other) {
    my %hash = map { $_ => 1 } @$other;
    return [ grep { not exists( $hash{$_} ) } @$self ];
}

1;

__END__

=head1 SYNOPSIS

    use Moose::Autobox;
    
    Moose::Autobox->mixin_additional_role(
        ARRAY => "Data::Frame::More::Array"
    );

    [ 1 .. 5 ]->isempty;            # false

=head1 DESCRIPTION

This is an additional Array role for Moose::Autobox.

=head1 SEE ALSO

L<Moose::Autobox>

L<Moose::Autobox::Array>


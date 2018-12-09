package Data::Frame::More::Class;

# ABSTRACT: For creating classes in Data::Frame::More

use Data::Frame::More::Setup ();

# VERSION

sub import {
    my ( $class, @tags ) = @_;
    Data::Frame::More::Setup->_import( scalar(caller), qw(:class), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Data::Frame::More::Class;

=head1 DESCRIPTION

C<use Data::Frame::More::Class ...;> is equivalent of 

    use Data::Frame::More::Setup qw(:class), ...;

=head1 SEE ALSO

L<Data::Frame::More::Setup>


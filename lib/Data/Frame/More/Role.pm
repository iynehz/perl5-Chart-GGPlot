package Data::Frame::More::Role;

# ABSTRACT: For creating roles in Data::Frame::More

use Data::Frame::More::Setup ();

# VERSION

sub import {
    my ( $class, @tags ) = @_;
    Data::Frame::More::Setup->_import( scalar(caller), qw(:role), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Data::Frame::More::Role;

=head1 DESCRIPTION

C<use Data::Frame::More::Role ...;> is equivalent of 

    use Data::Frame::More::Setup qw(:role), ...;

=head1 SEE ALSO

L<Data::Frame::More::Setup>


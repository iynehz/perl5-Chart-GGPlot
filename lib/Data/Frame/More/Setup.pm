package Data::Frame::More::Setup;

# ABSTRACT: Import stuffs into Data::Frame::More classes

use strict;
use warnings;

# VERSION

use utf8;
use feature ':5.14';

use Import::Into;

use Carp;
use Data::Dumper ();
use Function::Parameters 2.0;
use PerlX::Maybe ();
use Ref::Util    ();
use Safe::Isa    ();
use boolean      ();

use Moo 2.0 ();
use Moo::Role  ();
use namespace::autoclean 0.28 ();

use List::AllUtils qw(uniq);

use Moose::Autobox;
for my $type (qw(Hash Array)) {
    Moose::Autobox->mixin_additional_role(
        uc($type) => "Data::Frame::More::Autobox::$type" );
}

use PDL::Lite;
use Role::Tiny ();
Role::Tiny->apply_roles_to_package( 'PDL', 'Data::Frame::More::PDL' );

sub import {
    my ( $class, @tags ) = @_;

    unless (@tags) {
        @tags = qw(:base);
    }
    $class->_import( scalar(caller), @tags );
}

sub _import {
    my ( $class, $target, @tags ) = @_;

    for my $tag ( uniq @tags ) {
        $class->_import_tag( $target, $tag );
    }
}

sub _import_tag {
    my ( $class, $target, $tag ) = @_;

    if ( $tag eq ':base' ) {
        strict->import::into($target);
        warnings->import::into($target);
        utf8->import::into($target);
        feature->import::into( $target, ':5.14' );

        Carp->import::into($target);
        Data::Dumper->import::into($target);
        Function::Parameters->import::into($target);
        Ref::Util->import::into($target);
        Safe::Isa->import::into($target);
        boolean->import::into($target);

        Moose::Autobox->import::into($target);
    }
    elsif ( $tag eq ':class' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moo->import::into($target);
        namespace::autoclean->import::into($target);
    }
    elsif ( $tag eq ':role' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moo::Role->import::into($target);
        namespace::autoclean->import::into($target);
    }
    else {
        croak qq["$tag" is not exported by the $class module\n];
    }
}

1;

__END__

=head1 SYNOPSIS

    use Data::Frame::More::Setup;

=head1 DESCRIPTION

This module is a building block of classes in the Data::Frame::More project.
It uses L<Import::Into> to import stuffs into classes, thus largely removing 
the annoyance of writing a lot "use" statements in each class.

=head1 SEE ALSO

L<Import::Into>


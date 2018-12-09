package Data::Frame::More::Patch;

# ABSTRACT: Monkey-patch on packages like PDL::SV

use 5.014;
use warnings;

# VERSION

use PDL::SV;

# TODO: to reimplenent PDL::Factor like I did for PDL::SV
package    # hide from PAUSE
  PDL::Factor {
    use PDL::Bad ();
    use PDL::Core qw(pdl);
    use PDL::Slices ();
    use Storable qw(dclone);

    sub append {
        my ( $a, $b ) = @_;
        return PDL::SV->new( [ ( @{ $a->unpdl }, @{ $b->unpdl } ) ] );
    }

    sub copy {
        my ($self) = @_;
        my $class = ref($self);

        my $p = bless(PDL::Core::null, 'PDL::SV');
        $p .= $self;
        $p->_internal(dclone($self->_internal));
        return $p;
    }

    sub match {
        my ( $self, $pattern ) = @_;
        $pattern //= '';

        my @matches =
          ref($pattern) eq 'Regexp'
          ? ( map { $_ =~ $pattern ? 1 : 0 } @{ $self->unpdl } )
          : ( map { $_ eq $pattern ? 1 : 0 } @{ $self->unpdl } );
        return pdl( \@matches );
    }

    no warnings 'redefine';
    no warnings 'prototype';

#    sub at {
#        my ($self) = @_;
#
#        my $data = PDL::Core::at(@_);
#        return 'BAD' if ( $data eq 'BAD' );
#        return $self->_data->[$data];
#    }

    sub slice : lvalue {
        my ($self) = @_;

        my $ret = PDL::Slices::slice(@_);
        $ret->_levels( $self->_levels );
        $ret;
    }

    sub _call_pdl {
        my ($method) = @_;

        return sub {
            my $self = shift;
            my $p = PDL::Core::null;
            $p .= $self;
            return $p->$method(@_);
        };
    }

    for my $method (qw(isbad isgood nbad ngood)) {
        no strict 'refs';
        *{$method} = _call_pdl($method);
    }

    sub setbadif {
        my $self = shift;

        my $p = PDL::Core::null;
        $p .= $self;
        $p = $p->setbadif(@_);

        if ($self->is_inplace) {
            $self->set_inplace(0);
            $self .= $p;
            return $self;
        } else {
            my $class = ref($self);
            bless($p, $class);
            $p->_levels(dclone($self->_levels));
            return $p;
        }
    };
}

1;

__END__

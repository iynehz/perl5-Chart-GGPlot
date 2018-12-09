package Eval::Quosure;

# ABSTRACT: Evaluate within an arbitrary caller environment

use 5.010;
use strict;
use warnings;

# VERSION

use List::Util qw(pairmap);
use PadWalker qw(peek_my peek_our);
use Safe::Isa;
use Sub::Quote qw(quote_sub);
use Types::Standard qw(Str Int HashRef);

sub new {
    state $check = Type::Params::compile(Str, Int);

    my $class = shift;
    my ($expr, $level) = $check->(@_);
    $level //= 0;

    my $captures = {
        pairmap { $a => $b }
        ( %{ peek_our( $level + 1 ) }, %{ peek_my( $level + 1 ) } )
    };

    my $self = bless {
        expr     => $expr,
        captures => $captures,
        caller   => [ caller($level) ],
    }, $class;
    return $self;
}

=method expr

Get the expression stored in the object.

=method captures

Get the captured variables stored in the object. Returns a hashref with
keys being variables names including sigil and values being references
to the variables.

=method caller

Get the caller info stored in the object.
Returns an arrayref of same structure as what the C<caller()> returns.

=cut

sub expr     { $_[0]->{expr} }
sub captures { $_[0]->{captures} }
sub caller   { $_->[0]->{caller} }

=method eval

    eval(HashRef $additional_captures={})

Evaluate the quosure's expression in its own environment, with captured
variables from what's obtained when the quosure's created plus specified
by C<$additional_captures>, which is a hashref with keys be the full name
of the variable including sigil.

=cut

sub eval {
    state $check = Type::Params::compile(HashRef);

    my $self = shift;
    my ($additional_captures) = $check->(@_);
    $additional_captures //= {};

    my $captures = 
      { %{ $self->captures }, pairmap { $a => \$b } %$additional_captures };
    my $caller = $self->{caller};

    my $coderef = quote_sub(
        __PACKAGE__ . "::_Temp::foo",
        $self->expr,
        $captures,
        {
            no_install => 1,    # do not install the function
            package    => $caller->[0],
            file       => $caller->[1],
            line       => $caller->[2],

# Without below it could get error with Function::Parameters
#  Function::Parameters: internal error: $^H{'Function::Parameters/config'} not a hashref
            hintshash => undef,
        }
    );
    return $coderef->();
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Eval::Quosure;

    sub foo {
        my $a = 2;
        my $b = 3;
        return Eval::Quosure->new('bar($a, $b, $c)');
    }

    sub bar {
        my ($a, $b, $c) = @_;
        $a * $b * $c;
    }

    my $q = foo();

    my $a = 0;  # This is not used when evaluating the quosure.
    say $q->eval({ '$c' => 7 });

=head1 DESCRIPTION

This class acts similar to R's quosure. A "quosure" is an object
that combines an expression and an environment in which the expression
can be evaluated. 

Note that as this is string eval so is not safe. Use it with caution.

=head1 CONSTRUCTION

    new(Str $expr, $level=0)

C<$expr> is a string. C<$level> is used like the argument of C<caller> and
PadWalker's C<peek_my>, C<0> is for the current scope that creates the
quosure, C<1> is for the upper scope of the scope that creates the quosure,
and so on. 

=head1 SEE ALSO

L<https://cran.r-project.org/web/packages/rlang|R's "rlang" package> which
provides quosure.

L<Eval::Closure>, L<Binding>


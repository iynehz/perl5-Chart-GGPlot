package Test2::Tools::DataFrame;

# ABSTRACT: Tools for verifying Data::Frame::More data frames

use 5.010;
use strict;
use warnings;

# VERSION

use Safe::Isa;
use Test2::API qw/context/;
use Test2::Util::Table qw/table/;
use Test2::Util::Ref qw/render_ref/;

use parent qw/Exporter/;
our @EXPORT = qw(dataframe_ok dataframe_is);

=func dataframe_ok($thing, $name)

Checks that the given C<$thing> is a L<Data::Frame::More> object.

=cut

sub dataframe_ok ($;$) {
    my ( $thing, $name ) = @_;
    my $ctx = context();

    unless ( $thing->$_DOES('Data::Frame::More') ) {
        my $thingname = render_ref($thing);
        $ctx->ok( 0, $name, ["'$thingname' is not a data frame object."] );
        $ctx->release;
        return 0;
    }

    $ctx->ok( 1, $name );
    $ctx->release;
    return 1;
}

=func dataframe_is($got, $exp, $name);

Checks that data frame C<$got> is same as C<$exp>.

=cut

sub dataframe_is ($$;$@) {
    my ( $got, $exp, $name, @diag ) = @_;
    my $ctx = context();

    # TODO: Make this a package variable.
    local $Data::Frame::More::TOLERANCE_REL = 1e-9;

    unless ( $got->$_DOES('Data::Frame::More') ) {
        my $gotname = render_ref($got);
        $ctx->ok( 0, $name,
            ["First argument '$gotname' is not a data frame object."] );
        $ctx->release;
        return 0;
    }
    unless ( $exp->$_DOES('Data::Frame::More') ) {
        my $expname = render_ref($exp);
        $ctx->ok( 0, $name,
            ["Second argument '$expname' is not a data frame object."] );
        $ctx->release;
        return 0;
    }

    my $diff;
    eval { $diff = ( $got != $exp ); };
    if ($@) {
        my $gotname = render_ref($got);
        $ctx->ok( 0, $name, [ "'$gotname' is different from expected.", $@ ],
            @diag );
        $ctx->release;
        return 0;
    }
    my $diff_which = $diff->which( bad_to_val => 1 );
    unless ( $diff_which->isempty ) {
        my $gotname      = render_ref($got);
        my $column_names = $exp->column_names;
        my @table        = table(
            sanitize  => 1,
            max_width => 80,
            collapse  => 1,
            header    => [qw(ROWIDX COLUMN GOT CHECK)],
            rows      => [
                map {
                    my ( $ridx, $cidx ) = @$_;
                    [
                        $ridx, $column_names->[$cidx],
                        $got->at( $ridx, $cidx ), $exp->at( $ridx, $cidx )
                    ]
                } @{ $diff_which->unpdl }
            ]
        );
        $ctx->ok( 0, $name,
            [ "'$gotname' is different from expected.", @table ], @diag );
        $ctx->release;
        return 0;
    }

    $ctx->ok( 1, $name );
    $ctx->release;
    return 1;
}

1;

__END__

=head1 SYNOPSIS

    use Test2::Tools::DataFrame;

    # Functions are exported by default.
    
    # Ensure something is a data frame.
    dataframe_ok($df);

    # Compare two data frames.
    dataframe_is($got, $expected, 'Same data frame.');
    
=head1 DESCRIPTION 

This module contains tools for verifying L<Data::Frame::More> data frame
objects.

=head1 SEE ALSO

L<Data::Frame::More>, L<Test2::Suite> 


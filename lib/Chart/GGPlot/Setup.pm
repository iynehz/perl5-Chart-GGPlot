package Chart::GGPlot::Setup;

# ABSTRACT: Import stuffs into Chart::GGPlot classes

use strict;
use warnings;

# VERSION

use utf8;
use feature ':5.14';

use Import::Into;

use Carp;
use Data::Dumper      ();
use Data::Frame::More ();
use Function::Parameters 2.0;
use Log::Any qw($log);
use Log::Any::Adapter;
use Safe::Isa            ();
use PerlX::Maybe         ();
use Syntax::Keyword::Try ();
use Module::Load;
use Moose 2.1400;
use Moose::Role               ();
use Moose::Autobox            ();
use MooseX::Aliases           ();
use MooseX::MungeHas          ();
use MooseX::LazyRequire       ();
use MooseX::StrictConstructor ();
use MooseX::Traits            ();
use boolean                   ();
use namespace::autoclean 0.20;

use List::AllUtils qw(uniq);

# Add additional method to Moose::Autobox roles.
# In this way we have similar interfaces between,
# * arrayref and piddle
# * hashref and aes, dataframe, etc
for my $type (qw(Hash Array)) {
    Moose::Autobox->mixin_additional_role(
        uc($type) => "Data::Frame::More::Autobox::$type" );
}

# for debug
if (my $trace_level = $ENV{CHART_GGPLOT_TRACE} ) {
    load Log::Dispatch;
    load POSIX, qw(strftime);
    my $logger = Log::Dispatch->new(
        outputs => [
            [
                'Screen',
                min_level => 'debug',
                newline   => 1,
                stderr    => 1,
            ]
        ],
        callbacks => sub {
            my %params = @_;
            my $msg = $params{message};
            my $level = uc($params{level});
            return sprintf("%s [Chart::GGPlot $level] %s", strftime('%Y-%m-%d %H:%M:%S', localtime(time)), $msg);
        },
    );
    Log::Any::Adapter->set( { category => qr/^Chart::GGPlot/ },
        'Dispatch', dispatcher => $logger, );
}

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
        Log::Any->import::into( $target, '$log' );
        Safe::Isa->import::into($target);
        PerlX::Maybe->import::into($target);
        Syntax::Keyword::Try->import::into($target);
        boolean->import::into($target);

        Moose::Autobox->import::into($target);

        Data::Frame::More->import::into($target);
    }
    elsif ( $tag eq ':class' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moose->import::into($target);
        MooseX::Aliases->import::into($target);
        MooseX::LazyRequire->import::into($target);
        MooseX::MungeHas->import::into($target);
        MooseX::StrictConstructor->import::into($target);

        MooseX::Traits->import::into($target);

        namespace::autoclean->import::into($target);
    }
    elsif ( $tag eq ':role' ) {
        $class->_import_tag( $target, ':base' );

        Function::Parameters->import::into( $target,
            qw(classmethod :modifiers) );

        Moose::Role->import::into($target);
        MooseX::Aliases->import::into($target);
        MooseX::LazyRequire->import::into($target);
        MooseX::MungeHas->import::into($target);

        namespace::autoclean->import::into($target);
    }
    elsif ( $tag eq ':pdl' ) {
        require PDL::Lite;
        require PDL::Core;
        require PDL::IO::Dumper;
        require Role::Tiny;

        PDL::Lite->import::into($target);
        PDL::Core->import::into( $target, qw(pdl null) );
        PDL::IO::Dumper->import::into($target);

        Role::Tiny->apply_roles_to_package( 'PDL', 'Data::Frame::More::PDL' );

        # TODO: use PDL::Factor (or PDL::SV) would import names like float,
        # and cause a warning with Test::V0.
        # Import::Into cannot do "use PDL::Factor ();"

        #require PDL::Factor;
        #require PDL::SV;
        #PDL::Factor->import::into($target);
        #PDL::SV->import::into($target);
    }
    else {
        croak qq["$tag" is not exported by the $class module\n];
    }
}

# this is similar to what the "aliased" module does, but "aliased"
#  does not work with Import::Into.
sub _alias {
    my ( $class, $target, $from, $to ) = @_;

    $from->import::into($target);
    no strict 'refs';
    *{"${target}::${to}"} = sub { $from };
}

1;

__END__

=head1 SYNOPSIS

    use Chart::GGPlot::Setup;

=head1 DESCRIPTION

This module is a building block of classes in the Chart::GGPlot project.
It uses L<Import::Into> to import stuffs into classes, thus largely removing
the annoyance of writing a lot "use" statements in each class.

=head1 SEE ALSO

L<Import::Into>


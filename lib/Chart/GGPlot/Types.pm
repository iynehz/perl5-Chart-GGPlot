package Chart::GGPlot::Types;

# ABSTRACT: Custom types and coercions

use Chart::GGPlot::Setup qw(:base :pdl); 

# VERSION

use Ref::Util qw(is_plain_arrayref);
use Type::Library -base, -declare => qw(
  GGParams AesMapping
  ColorBrewerTypeEnum PositionEnum
  Theme Margin Labeller
  Coord Facet Scale
  HJust VJust
);

use Type::Utils -all;
use Types::Standard -types;
use Types::PDL -types;
use Data::Frame::Types qw(:all);

declare GGParams, as ConsumerOf ["Chart::GGPlot::Params"];
coerce GGParams, from HashRef,
    via { 'Chart::GGPlot::Params'->new($_->flatten); };

declare AesMapping, as InstanceOf ["Chart::GGPlot::Aes"];
coerce AesMapping, from HashRef,
    via { 'Chart::GGPlot::Aes'->new($_->flatten); };

declare ColorBrewerTypeEnum, as Enum [qw(seq dev qual)];
declare PositionEnum,        as Enum [qw(left right top bottom)];

declare Theme, as InstanceOf["Chart::GGPlot::Theme"];

declare Margin, as InstanceOf["Chart::GGPlot::Margin"];

declare Labeller, as InstanceOf["Chart::GGPlot::Labeller"];
coerce Labeller, from Any,
    via { 'Chart::GGPlot::Labeller'->as_labeller($_); };

declare Coord, as ConsumerOf["Chart::GGPlot::Coord"];
declare Facet, as ConsumerOf["Chart::GGPlot::Facet"];
declare Scale, as ConsumerOf["Chart::GGPlot::Scale"];

declare_coercion "ArrayRefFromAny", to_type ArrayRef, from Any, via { [$_] };

declare HJust, as(
    Num->where( sub { $_ > -1e-10 and $_ < 1.0 + 1e-10 } ) | Piddle0D |
      Enum [qw(left right center middle)] | ( ConsumerOf ["PDL::SV"] )->where(
        sub {
            ( ( $_ == "left" ) | ( $_ == "right" ) | ( $_ == "center" ) |
                  ( $_ == "middle" ) )->all;
        }
      ) | Piddle1D->where(
        sub {
            not $_->$_DOES('PDL::SV')
              and ( ( $_ > -1e-10 ) & ( $_ < 1.0 + 1e-10 ) )->all;
        }
      )
);
declare VJust, as(
    Num->where( sub { $_ > -1e-10 and $_ < 1.0 + 1e-10 } ) | Piddle0D |
      Enum [qw(top bottom center middle)] | ( ConsumerOf ["PDL::SV"] )->where(
        sub {
            ( ( $_ == "top" ) | ( $_ == "bottom" ) | ( $_ == "center" ) |
                  ( $_ == "middle" ) )->all;
        }
      ) | Piddle1D->where(
        sub {
            not $_->$_DOES('PDL::SV')
              and ( ( $_ > -1e-10 ) & ( $_ < 1.0 + 1e-10 ) )->all;
        }
      )
);

1;

__END__

=head1 SYNOPSYS

    use Chart::GGPlot::Types qw(:all);

=head1 DESCRIPTION

This modules defines custom L<Type::Tiny> types and coercions used
by the library.

=head1 SEE ALSO

L<Type::Tiny>


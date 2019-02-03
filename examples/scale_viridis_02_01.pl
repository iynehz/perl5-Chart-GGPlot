#!/usr/bin/env perl

# Use viridis_d with discrete data

use 5.016;
use warnings;

use Getopt::Long;
use Chart::GGPlot::Functions qw(:all);
use Data::Munge qw(elem);
use Data::Frame::More::Examples qw(txhousing);
use List::AllUtils qw(indexes);

my $save_as;
GetOptions( 'o=s' => \$save_as );

my $txhousing = txhousing();

# TODO: implement as method in PDL::Factor and PDL::SV
my $city = $txhousing->at('city');
my @selected_cities =
  ( 'Houston', 'Fort Worth', 'San Antonio', 'Dallas', 'Austin' );
my @selected_rindices =
  indexes { elem( $_, \@selected_cities ) } @{ $city->unpdl };

my $txsamp = $txhousing->select_rows( \@selected_rindices );

my $p = ggplot(
    data    => $txsamp,
    mapping => aes( x => 'sales', y => 'median' )
)->geom_point( mapping => aes( color => 'city' ) )
 ->scale_color_viridis_d();

if ( defined $save_as ) {
    $p->save($save_as);
}
else {
    $p->show();
}


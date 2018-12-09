package t::lib;

use strict;
use warnings;

use Chart::GGPlot::Setup;

use Exporter::Tiny;

our @EXPORT_OK = qw(str);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

fun str($x) {
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Terse = 1;
    my $s = Dumper($x);
    chomp($s);
    return $s;
}

1;

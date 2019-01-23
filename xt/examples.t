#!perl

use FindBin;
use Path::Tiny;
use Chart::Plotly::Image::Orca;

use Test2::V0;

eval { Chart::Plotly::Image::Orca::orca_available(); };
plan skip_all("needs plotly-orca to run") if $@;

my $script = "$FindBin::RealBin/../utils/run_all_examples.pl";

my $tempdir = Path::Tiny->tempdir;

my @cmd = ($^X, $script, "--save-to-dir=$tempdir");
my $rc = system(@cmd);

ok($rc == 0, "run_all_examples.pl has no errors");

done_testing;

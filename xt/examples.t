#!perl

use FindBin;
use Path::Tiny;

use Test2::V0;

my $script = "$FindBin::RealBin/../utils/run_all_examples.pl";

my $tempdir = Path::Tiny->tempdir;

my @cmd = ($^X, $script, "--save-to-dir=$tempdir");
my $rc = system(@cmd);

ok($rc == 0, "run_all_examples.pl has no errors");

done_testing;

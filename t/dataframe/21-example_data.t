#!perl

use Data::Frame::More::Setup;

use PDL::Core qw(pdl);
use Path::Tiny;

use Test2::V0;
use Test2::Tools::Warnings qw(no_warnings);
use Test2::Tools::DataFrame;
use Test2::Tools::PDL;

use Data::Frame::More::Examples qw(:all);

subtest simple => sub {     # just test if the data is loadable
    for my $name (qw(airquality mtcars diamonds)) {
        no strict 'refs';
        ok( $name->(), $name );
    }
};

subtest airquality => sub {
    my $airquality;
    ok(no_warnings {
        $airquality = airquality();
    }, "read_csv() shall not warn about NA");
    is($airquality->at('Ozone')->nbad, 37, 'airquality');

    my $tempfile = Path::Tiny->tempfile;
    $airquality->to_csv($tempfile, row_names => false, na => 'MYNA');
    my $df = Data::Frame::More->from_csv($tempfile, na => 'MYNA');
    dataframe_is($df, $airquality, '$df->to_csv()');
};

subtest diamonds => sub {
    my $diamonds = diamonds();
    is( $diamonds->names, [qw(carat cut color clarity depth table price x y z)],
        '$diamonds->names' );
    is( $diamonds->nrow, 53940, '$diamonds->nrow' );
};

done_testing;

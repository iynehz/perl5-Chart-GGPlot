package Data::Frame::More::Examples;

# ABSTRACT: Example data sets

use Data::Frame::More::Setup;

use File::ShareDir qw(dist_dir);
use Module::Runtime qw(module_notional_filename);
use Path::Tiny;

use Data::Frame::More;

# VERSION

use parent qw(Exporter::Tiny);

my %data_setup = (
    diamonds   => {},
    mtcars     => {},
    airquality => {},
);
my @data_names = keys %data_setup;

our @EXPORT_OK = (@data_names);
our %EXPORT_TAGS = ( all => \@EXPORT_OK, );

my $data_raw_dir;

#TODO: Change this dist name when merging this to Data::Frame or moving
# into a new dist.
eval { $data_raw_dir = dist_dir('Chart-GGPlot'); };
if ($@) {    # for dev env only
    my $path = path( $INC{ module_notional_filename(__PACKAGE__) } );
    $data_raw_dir =
      path( $path->parent( ( () = __PACKAGE__ =~ /(::)/g ) + 2 ), 'data-raw' )
      . '';
}

fun _make_data ( $name, %rest ) {
    return sub {
        state $df;
        unless ($df) {
            $df = Data::Frame::More->from_csv(
                "$data_raw_dir/$name.csv",
                header => true,
                %rest
            );
        }
        return $df;
    };
}

for my $name ( keys %data_setup ) {
    no strict 'refs';
    *{$name} = _make_data( $name, %{ $data_setup{$name} } );
}

1;

__END__

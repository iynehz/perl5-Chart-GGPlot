package Data::Frame::More::Examples;

# ABSTRACT: Example data sets

use Data::Frame::More::Setup;

use File::ShareDir qw(module_dir);
use Module::Runtime qw(module_notional_filename);
use Path::Tiny;
use aliased 'Data::Frame::More' => 'DataFrame';
use boolean;

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

# TODO: replace this with File::ShareDir
my $data_raw_dir;
eval { $data_raw_dir = module_dir(__PACKAGE__); };
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
            $df = DataFrame->from_csv(
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

package Data::Frame::More::Examples;

# ABSTRACT: Example data sets

use Data::Frame::More::Setup;

use File::ShareDir qw(dist_dir);
use Module::Runtime qw(module_notional_filename);
use Path::Tiny;

use Data::Frame::More;
use Data::Frame::More::Util qw(factor);

# VERSION

use parent qw(Exporter::Tiny);

my %data_setup = (
    airquality => {},
    diamonds   => {
        postprocess => sub {
            my ($df) = @_;
            my $clarity = $df->at('clarity');
            $df->set(
                'clarity',
                factor(
                    $clarity,
                    levels  => [qw(I1 SI2 SI1 VS2 VS1 VVS2 VVS1 IF)],
                    ordered => true
                )
            );
            return $df;
        }
    },
    mpg       => {},
    mtcars    => {},
    economics => { params => { col_types => { date => 'PDL::DateTime' } } },
    economics_long =>
      { params => { col_types => { date => 'PDL::DateTime' } } },
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

fun _make_data ( $name, $setup ) {
    return sub {
        state $df;
        unless (defined $df) {
            $df = Data::Frame::More->from_csv(
                "$data_raw_dir/$name.csv",
                header => true,
                %{$setup->{params}}
            );
        }
        if (my $postprocess = $setup->{postprocess}) {
            return $postprocess->($df);
        } else {
            return $df;
        }
    };
}

for my $name ( keys %data_setup ) {
    no strict 'refs';
    *{$name} = _make_data( $name, $data_setup{$name} );
}

1;

__END__

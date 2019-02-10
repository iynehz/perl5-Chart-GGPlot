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

            my $factorize = sub {
                my ( $var, $levels ) = @_;

                $df->set(
                    $var,
                    factor(
                        $df->at($var),
                        levels  => $levels,
                        ordered => true
                    )
                );
            };

            $factorize->(
                'cut', [ 'Fair', 'Good', 'Very Good', 'Premium', 'Ideal' ]
            );
            $factorize->( 'color',   [ 'D' .. 'J' ] );
            $factorize->( 'clarity', [qw(I1 SI2 SI1 VS2 VS1 VVS2 VVS1 IF)] );
            return $df;
          }
    },
    economics => { params => { col_types => { date => 'PDL::DateTime' } } },
    economics_long =>
      { params => { col_types => { date => 'PDL::DateTime' } } },
    mpg       => {},
    mtcars    => {},
    txhousing => {},
);
my @data_names = sort keys %data_setup;

our @EXPORT_OK = (@data_names, 'dataset_names');
our %EXPORT_TAGS = (
    datasets => \@data_names,
    all      => \@EXPORT_OK,
);

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

for my $name ( @data_names ) {
    no strict 'refs';
    *{$name} = _make_data( $name, $data_setup{$name} );
}

=func dataset_names

Returns an array of names of the datasets in this module. 

=cut

sub dataset_names { @data_names; }

1;

__END__

=head1 SYNOPSIS

    use Data::Frame::More::Examples qw(:datasets dataset_names);

    say dataset_names();    # names of all example datasets

    my $mtcars = mtcars();

=head1 SEE ALSO

L<Data::Frame::More>

package Data::Frame::More::Partial::CSV;

# ABSTRACT: Partial class for data frame's conversion from/to CSV

use Data::Frame::More::Role;
use namespace::autoclean;

# VERSION

use PDL::Lite;
use PDL::Core qw(pdl null);
use PDL::Primitive ();
use PDL::Factor    ();
use PDL::SV        ();
use PDL::DateTime  ();
use PDL::Types     ();

use Data::Munge qw(elem);
use Package::Stash;
use Ref::Util qw(is_plain_arrayref is_plain_hashref);
use Scalar::Util qw(openhandle looks_like_number);
use Type::Params;
use Types::Standard qw(Any ArrayRef CodeRef HashRef Maybe Str);
use Types::PDL qw(Piddle);
use Text::CSV;

use Data::Frame::More::Util qw(guess_and_convert_to_pdl);

=method from_csv

    from_csv($file, :$header=true, :$sep=',', :$quote='"',
             :$na=[qw(NA BAD)], :$col_names=undef, :$row_names=undef, 
             HashRef :$col_types={},
             :$strings_as_factors=true)

Create a data frame object from a CSV file. For example, 

    my $df = Data::Frame::More->from_csv("foo.csv");

Some of the parameters are explained below,

=for :list
* C<$file> can be a file name string, a Path::Tiny object, or an opened file
handle.
* C<$col_types> is a hashref associating column names to their types. Types
can be the PDL type names like C<"long">, C<"double">, or names of some PDL's
derived class like C<"PDL::SV">, C<"PDL::Factor">, C<"PDL::DateTime">. If a
column is not specified in C<$col_types>, its type would be automatically
decided.

=cut

classmethod from_csv ($file, :$header=true, :$sep=",", :$quote='"',
                      :$na=[qw(NA BAD)], :$col_names=undef, :$row_names=undef,
                      HashRef :$col_types={},
                      :$strings_as_factors=true
  ) {
    state $check = Type::Params::compile(
        ( ArrayRef [Str] )->plus_coercions( Any, sub { [$_] } ) );
    ($na) = $check->($na);

    # TODO
    my $check_name = sub {
        my ($name) = @_;
        return $name;
    };

    my $csv = Text::CSV->new(
        {
            binary    => 1,
            auto_diag => 1,
            sep       => $sep,
            quote     => $quote
        }
    );

    my $fh = openhandle($file);
    unless ($fh) {
        open $fh, "<:encoding(utf8)", "$file" or die "$file: $!";
    }
    my @col_names;
    if ( defined $col_names ) {
        @col_names = $col_names->flatten;
    }
    else {
        if ($header) {
            eval {
                # suppress possible warning message on parsing header
                $csv->auto_diag(0);
                $csv->header( $fh, { munge_column_names => 'none' } );
                @col_names = $csv->column_names;
            };
            $csv->auto_diag(1);    # restore auto_diag
            if ($@) {

                # rewind as first line read by $csv->header
                seek( $fh, 0, 0 );
                my $first_row = $csv->getline($fh);
                @col_names = @$first_row;
            }
        }
    }

    # if first column has no header, we take this first column as row names.
    my $row_names_from_first_column = ( length( $col_names[0] ) == 0 );
    if ($row_names_from_first_column) {
        shift @col_names;
    }
    @col_names = map { $check_name->($_) } @col_names;

    my %columns = map { $_ => [] } @col_names;

    my @row_names;
    my $rows = $csv->getline_all($fh);
    for my $row (@$rows) {
        my $offset = 0;
        if ($row_names_from_first_column) {
            push @row_names, $row->[0];
            $offset = 1;
        }
        for my $i ( 0 .. $#col_names ) {
            my $col = $col_names[$i];
            push @{ $columns{$col} }, $row->[ $i + $offset ];
        }
    }

    if ($row_names_from_first_column) {
        $row_names = \@row_names;
    }
    else {
        if ( defined $row_names ) {
            if ( looks_like_number($row_names) ) {
                my $col_index = int($row_names);
                $row_names = $columns{ $col_names[$col_index] };
            }
        }
    }

    my $pdl_types = $class->_pdl_types;
    my $package_pdl_core = Package::Stash->new('PDL::Core');
    my $to_piddle = sub {
        my ($name) = @_;
        my $x = $columns{$name};

        if (my $col_type = $col_types->{$name}) {
            if (elem($col_type, $pdl_types)) {
                my $f = $package_pdl_core->get_symbol("&$col_type");
                return $f->($x) if $f;
            } 
            if ($col_type =~ /^PDL::(?:Factor|SV|DateTime)$/) {
                if ($col_type eq 'PDL::DateTime') {
                    return $col_type->new_from_datetime($x);               
                } else {
                    return $col_type->new($x);               
                }
            }

            die "Invalid column type '$col_type'";
        } else {
            return guess_and_convert_to_pdl(
                $x,
                na                 => $na,
                strings_as_factors => $strings_as_factors
              );
        }
    };

    my $df = $class->new(
        columns => [
            map {
                $_ => $to_piddle->($_),
            } @col_names
        ],
        ( $row_names ? ( row_names => $row_names ) : () ),
    );

    return $df;
}

=method to_csv
    
    to_csv($file, :$sep=',', :$quote='"', :$na='NA',
           :$col_names=true, :$row_names=true)

Write the data frame to a csv file.

=cut

method to_csv ($file, :$sep=',', :$quote='"', :$na='NA',
               :$col_names=true, :$row_names=true) {
    my $csv = Text::CSV->new(
        {
            binary    => 1,
            auto_diag => 1,
            sep       => $sep,
            quote     => $quote,
            eol       => "\n",
        }
    );

    my $fh = openhandle($file);
    unless ($fh) {
        open $fh, ">", "$file" or die "$file: $!";
    }

    my $row_names_data = $row_names ? $self->row_names : undef;
    if ($col_names) {
        my @header = ( ( $row_names ? '' : () ), @{ $self->names } );
        $csv->print( $fh, \@header );
    }

    # a hash to store isbad info for each column
    my %is_bad = map { $_ => $self->at($_)->isbad; } ( $self->names->flatten );

    for ( my $i = 0 ; $i < $self->nrow ; $i++ ) {
        my @row = (
            ( $row_names ? $row_names_data->at($i) : () ),
            (
                map { $is_bad{$_}->at($i) ? $na : $self->at($_)->at($i); }
                  @{ $self->names }
            )
        );
        $csv->print( $fh, \@row );
    }
}

classmethod _pdl_types () {
    state $types = [ map { PDL::Types::typefld( $_, 'ppforcetype' ); }
          PDL::Types::typesrtkeys() ];
    return $types;
}

1;

__END__


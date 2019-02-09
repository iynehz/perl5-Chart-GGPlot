package Data::Frame::More;

# ABSTRACT: Data frame implementation

use Data::Frame::More::Class;
use namespace::autoclean;

with qw(
  MooX::Traits
  Data::Frame::More::Partial::CSV
  Data::Frame::More::Partial::Eval
  Data::Frame::More::Partial::Sugar
);

# VERSION

extends 'Data::Frame';

use PDL::Lite;
use PDL::Core qw(pdl null);
use PDL::Primitive ();
use PDL::Factor    ();
use PDL::SV        ();

use List::AllUtils qw(each_arrayref pairgrep pairkeys pairmap);
use List::MoreUtils 0.423;
use Ref::Util qw(is_plain_arrayref is_plain_hashref);
use Scalar::Util qw(looks_like_number);
use Sereal::Decoder;
use Sereal::Encoder;
use Type::Params;
use Types::Standard qw(Any ArrayRef CodeRef CycleTuple HashRef Maybe Str);
use Types::PDL qw(Piddle);

use Data::Frame::More::Indexer qw(:all);
use Data::Frame::More::Types qw(:all);
use Data::Frame::More::Util qw(:all);

use overload (
    '""' => sub { $_[0]->string },
    '.=' => sub {                    # this is similar to PDL
        my ( $self, $other ) = @_;
        $self->assign($other);
    },
    '==' => sub {
        my ( $self, $other ) = @_;
        $self->_compare( $other, 'eq' );
    },
    '!=' => sub {
        my ( $self, $other ) = @_;
        $self->_compare( $other, 'ne' );
    },
    '<' => sub {
        my ( $self, $other, $swap ) = @_;
        $self->_compare( $other, ( $swap ? 'ge' : 'lt' ) );
    },
    '<=' => sub {
        my ( $self, $other, $swap ) = @_;
        $self->_compare( $other, ( $swap ? 'gt' : 'le' ) );
    },
    '>' => sub {    # use '<' overload
        my ( $self, $other, $swap ) = @_;
        $swap ? ( $self < $other ) : ( $other < $self );
    },
    '>=' => sub {    # use '<=' overload
        my ( $self, $other, $swap ) = @_;
        $swap ? ( $self <= $other ) : ( $other <= $self );
    },
    fallback => 1
);

# Relative tolerance. This can be used for data frame comparison.
our $TOLERANCE_REL = undef;

# Check if all columns have same length or have a length of 1.
around BUILDARGS($orig, $class : @args) {
    my %args = @args;   

    my $columns = $args{columns};
    my $columns_is_aref = Ref::Util::is_plain_arrayref($columns);
    my $columns_href;
    if ($columns_is_aref) {
        $columns_href = { @$columns };
    } else {
        $columns_href = $columns;
    }

    my @lengths = map { $_->length } values %$columns_href;
    my $max_length = List::AllUtils::max(@lengths);
    for my $column_name (sort keys %$columns_href) {
        my $data = $columns_href->{$column_name};
        if ($data->length != $max_length) {
            if ($data->length == 1) {
                if ($columns_is_aref) {
                    my $idx = List::AllUtils::lastidx {
                        $_ eq $column_name
                    } List::AllUtils::pairkeys(@$columns); 
                    $columns->[2*$idx + 1] = $data->repeat($max_length);
                } else {    # hashref
                    $columns->{$column_name} = $data->repeat($max_length);
                }
            } else {
                die "Column piddles must all be same length or have a length of 1";
            }
        }
    }
    return $class->$orig(\%args);
}

method BUILD ($args) {
    my $row_names = $args->{row_names};
    if ( defined $row_names ) {
        $self->row_names($row_names);
    }

    $self->_initialize_sugar();
}

=method number_of_columns

    number_of_columns()

=method ncol

    ncol()

This is same as C<number_of_columns>.

=method length

    length()

This is same as C<number_of_columns>.

=method number_of_rows

    number_of_rows()

=method nrow

    nrow()

This is same as C<number_of_rows>.

=method dims
    
    dims()

Returns a perl list of C<($nrow, $ncol)>.

=method shape

    shape()

Similar to C<dims> but returns a piddle.

=cut

*ncol   = \&Data::Frame::number_of_columns;
*length = \&Data::Frame::number_of_columns;

*nrow = \&Data::Frame::number_of_rows;

method dims () {
    return ( $self->nrow, $self->ncol );
}

method shape () {
    return pdl( $self->dims );
}

=method at
    
    my $column_piddle = $df->at($column_indexer);
    my $cell_value = $df->at($row_indexer, $column_indexer);

If only one argument is given, it would treat the argument as column
indexer to get the column.
If two arguments are given, it would treat the arguments for row
indexer and column indexer respectively to get the cell value.

If a given argument is non-indexer, it would try guessing whether the
argument is numeric or not, and coerce it by either C<loc()> or
C<iloc()>.

=cut

method _indexer_to_indices ($indexer, $row_or_column) {
    if ( $indexer->$_isa('Data::Frame::More::Indexer::ByIndex') ) {
        return $indexer->indexer;
    }
    else {
        my $names_getter = "${row_or_column}_names";
        my @names        = $self->$names_getter()->flatten;
        return $indexer->indexer->map(
            sub {
                my ($name) = @_;
                my $ridx = List::AllUtils::firstidx { $name eq $_ } @names;
                if ( $ridx < 0 ) {
                    die "Cannot find $row_or_column name '$name'.";
                }
                return $ridx;
            }
        );
    }
}

method _cindexer_to_indices (Indexer $indexer) {
    return $self->_indexer_to_indices( $indexer, 'column' );
}

method _rindexer_to_indices (Indexer $indexer) {
    if ( $indexer->$_DOES('Data::Frame::More::Indexer::ByLabel') ) {
        die "select_rows() does not yet support 'ByLabel' indexer";
    }

    return $self->_indexer_to_indices( $indexer, 'row' );
}

method at (@rest) {
    my ( $rindexer, $cindexer ) = $self->_check_slice_args(@_);

    my $col;
    if ( $cindexer->$_DOES('Data::Frame::More::Indexer::ByIndex') ) {
        $col = $self->nth_column( $cindexer->indexer->[0] );
    }
    else {    # ByLabels;
        $col = $self->column( $cindexer->indexer->[0] );
    }

    if ( defined $rindexer ) {
        return $col->at( $rindexer->indexer->[0] );
    }
    else {
        return $col;
    }
}

=method exists

    exists($col_name)

Returns true of column C<$col_name> exists, false otherwise.

=method delete

    delete($col_name)

In-place delete column given by C<$col_name>.

=method rename

In-place rename columns.

=method select_columns

    select_columns($indexer) 

Returns a new data frame object which has the columns selected by C<$indexer>.

If a given argument is non-indexer, it would coerce it by C<loc()>.

=cut

# Public methods other than slice() shall be non-lvalue.
sub select_columns { shift->_select_columns(@_); }

method exists ($col_name) {
    return ( List::AllUtils::any { $_ eq $col_name }
        ( $self->names->flatten ) );
}

method delete ($col_name) {
    $self->_columns->Delete($col_name);
}

method rename ($href_or_coderef) {
    my $new_names;
    if ( Ref::Util::is_coderef($href_or_coderef) ) {
        $new_names = $self->names->map( sub { $href_or_coderef->($_) // $_ } );
    }
    else {
        $new_names = $self->names->map( sub { $href_or_coderef->{$_} // $_ } );
    }
    $self->names($new_names);
    return $self;
}

=method set

    set($col_name, $data)

Sets data to column. If C<$col_name> does not exist, it would add a new column.

=cut

method set ($indexer, $data) {
    state $check =
      Type::Params::compile( Indexer->plus_coercions(IndexerFromLabels) );
    ($indexer) = $check->($indexer);

    if ( $data->length == 1 ) {
        $data = $data->repeat( $self->nrow );
    }

    # Only ByLabel indexer can be used to add new columns.

    my $name;
    if ( $indexer->$_DOES('Data::Frame::More::Indexer::ByLabel') ) {
        $name = $indexer->indexer->[0];
    }
    else {
        my $cidx = $indexer->indexer->[0];
        if ( $cidx >= $self->ncol ) {
            die "Invalid column index: $cidx";
        }
        $name = $self->column_names->at($cidx);
    }

    if ( $self->exists($name) ) {
        $data = PDL::SV->new($data) if ( Ref::Util::is_plain_arrayref($data) );

        $self->_column_validate( $name => $data );
        $self->_columns->Push( $name => $data );
    }
    else {
        $self->SUPER::add_column( $name, $data );
    }

    return $data;
}

=method column_names

    column_names($new_names)

=method col_names

    col_names($new_names)

This is same as C<column_names>.

=method names

    names($new_names)

This is same as C<column_names>.

=method row_names

    row_names($new_names)

=cut

method column_names (@rest) {
    my @new_names = (
        ( @rest == 1 and Ref::Util::is_ref( $rest[0] ) )
        ? $rest[0]->flatten
        : @rest
    );
    return $self->SUPER::column_names(@new_names);
}

*names = \&column_names;

=method select_rows

    select_rows($indexer)

If a given argument is non-indexer, it would coerce it by C<iloc()>.

=method head

    head($n=6)

Returns a new data frame object of first C<$n> rows.

=method tail

    tail($n=6)

Returns a new data frame object of last C<$n> rows.

=method sample

    sample($n)

Get a random sample of rows from the data frame object.

    my $sample = $df->sample(100);

=cut

around select_rows(@rest) {
    my $indexer = iloc(@rest);
    return $self unless defined $indexer;

    my $indices = $self->_rindexer_to_indices($indexer);
    return $self->$orig($indices);
}

method head ($n=6) {
    my $indexer =
      iloc( [ 0 .. List::AllUtils::min( $n, $self->nrow ) - 1 ] );
    return $self->select_rows($indexer);
}

method tail ($n=6) {
    my $indexer = iloc(
        [
            $self->nrow -
              List::AllUtils::min( $n, $self->nrow ) .. $self->nrow - 1
        ]
    );
    return $self->select_rows($indexer);
}

method sample ($n) {
    if ($n > $self->nrow) {
        die "sample size is larger than nrow";
    }
    
    my $indices = [ List::MoreUtils::samples($n, (0 .. $self->nrow-1)) ];
    return $self->select_rows($indices);
}

=method merge

    merge($df)

=method cbind

    cbind($df)

This is same as C<merge()>.

=method append

    append($df)

=method rbind
    
    rbind($df)

This is same as C<append()>.

=method transform

    transform($func)

Apply a function to columns of the data frame, and returns a new data
frame object. 

C<$func> can be one of the following, 

=for :list
* A function coderef. It would be applied to all columns.
* A hashref of C<{ $column_name =E<gt> $coderef, ... }>. It allows to apply
the function to the specified columns. The raw data frame's columns not 
existing in the hashref be retained unchanged. Hashref keys not yet
existing in the raw data frame can be used for creating new columns.
* An arrayref like C<[ $column_name =E<gt> $coderef, ... ]>. In this mode
it's similar as the hasref above, but newly added columns would be in order.

In any of the forms of C<$func> above, if a new column data is calculated
to be C<undef>, or in the mappings like hashref or arrayref C<$coderef> is
an explicit C<undef>, then the column would be removed from the result
data frame.

Here are some examples, 

=over 4

=item Operate on all data of the data frame,

    my $df_new = $df->transform(
            sub {
                my ($col, $df) = @_;
                $col * 2;
            } );

=item Change some of the existing columns, 

    my $df_new = $df->transform( {
            foo => sub {
                my ($col, $df) = @_;
                $col * 2;
            },
            bar => sub {
                my ($col, $df) = @_;
                $col * 3;
            } );
 
=item Add a new column from existing data,
    
    # Equivalent to: 
    # do { my $x = $mtcars->copy;
    #      $x->set('kpg', $mtcars->at('mpg') * 1.609); $x; };
    my $mtcars_new = $mtcars->transform(
            kpg => sub { 
                my ($col, $df) = @_;    # $col is undef in this case
                $df->at('mpg') * 1.609,
            } );

=back

=cut

method merge (DataFrame $df) {
    my $class   = ref($self);
    my $columns = [
        $self->names->map( sub { $_ => $self->at($_) } )->flatten,
        $df->names->map( sub { $_ => $df->at($_) } )->flatten
    ];
    return $class->new(
        columns   => $columns,
        row_names => $self->row_names
    );
}
*cbind = \&merge;

method append (DataFrame $df) {
    if ( $df->nrow == 0 ) {                     # $df is empty
        return $self->clone();
    }
    if ( $self->column_names->length == 0) {    # $self has no columns
        return $df->clone;
    }

    my $class   = ref($self);
    my $columns = $self->names->map(
        sub {
            my $col = $self->at($_);
            # use glue() as PDL's append() cannot handle bad values
            $_ => $col->glue( 0, $df->at($_) );
        }
    );
    return $class->new( columns => $columns );
}
*rbind = \&append;

method transform ($func) {
    state $check = Type::Params::compile(
        (
            CodeRef | ( HashRef [ Maybe [CodeRef] ] ) |
              ( CycleTuple [ Str, Maybe [CodeRef] ] )
        )
    );
    ($func) = $check->($func);

    my $class = ref($self);

    my @columns;
    if ( Ref::Util::is_coderef($func) ) {
        @columns =
          $self->names->map( sub {
            $_ => $func->( $self->at($_), $self );
          } )->flatten;
    }
    else {    # hashref or arrayref
        my $column_names = $self->names;
        my $hashref;
        my @new_column_names;
        if ( Ref::Util::is_hashref($func) ) {
            $hashref = $func;
            @new_column_names =
              grep { !$self->exists($_) } sort( keys %$hashref );
        }
        else {    # arrayref
            $hashref = {@$func};
            @new_column_names = grep { !$self->exists($_) } ( pairkeys @$func );
        }

        @columns = $column_names->map(
            sub {
                my $f = exists($hashref->{$_}) ? $hashref->{$_} : sub { $_[0] };
                $f //= sub { undef };
                $_ => $f->( $self->at($_), $self );
            }
        )->flatten;
        push @columns,
          map { my $f = $hashref->{$_}; $_ => $f->( undef, $self ) }
          @new_column_names;
    }

    my %columns_to_drop = @columns;
    %columns_to_drop = pairgrep { not defined $b } %columns_to_drop;

    return $class->new(
        columns   => [ pairgrep { !exists($columns_to_drop{$a}) } @columns ],
        row_names => $self->row_names,
    );
}

=method split

    split($factor, $use_eq=true)

Splits the data in into groups defined by f. 
Returns a hash ref mapping value to data frame.

=cut

method split (Piddle $factor) {
    if ($factor->$_DOES('PDL::Factor')) {
        $factor = $factor->{PDL};
    }
    my $uniq_values = $factor->$_call_if_can('uniq')
      // [ List::AllUtils::uniq( $factor->flatten ) ];

    my %group = map {
        my $indices = PDL::Primitive::which( $factor == $_ );
        $_ => $self->select_rows($indices);
    } $uniq_values->flatten;
    return \%group;
}

=method slice

    my $subset1 = $df->slice($row_indexer, $column_indexer);

    # Note that below two cases are different.
    my $subset2 = $df->slice($column_indexer);
    my $subset3 = $df->slice($row_indexer, undef);

Returns a new dataframe object which is a slice of the raw data frame. 

This method returns an lvalue which allows PDL-like C<.=> assignment for
changing a subset of the raw data frame. For example,  

    $df->slice($row_indexer, $column_indexer) .= $another_df;
    $df->slice($row_indexer, $column_indexer) .= $piddle;

If a given argument is non-indexer, it would try guessing if the argument
is numeric or not, and coerce it by either C<loc()> or C<iloc()>.

=cut

# below lvalue methods are for slice()
sub _column : lvalue     { my $col = shift->column(@_);     return $col; }
sub _nth_column : lvalue { my $col = shift->nth_column(@_); return $col; }

method _select_columns (@rest) : lvalue {
    my $indexer = loc(@rest);
    return $self unless defined $indexer;

    my $indices      = $self->_cindexer_to_indices($indexer);
    my $column_names = $self->column_names;
    return ref($self)->new(
        columns => $indices->map(
            sub { $column_names->at($_) => $self->_nth_column($_) }
        ),
        row_names => $self->row_names
    );
}

classmethod _check_slice_args (@rest) {
    state $check_labels =
      Type::Params::compile( Indexer->plus_coercions(IndexerFromLabels) );
    state $check_indices =
      Type::Params::compile( Indexer->plus_coercions(IndexerFromIndices) );

    my ( $row_indexer, $column_indexer ) =
      map {
        if ( !defined($_) ) {
            undef;
        }
        elsif ( Indexer->check($_) ) {
            $_;
        }
        else {
            my $p = guess_and_convert_to_pdl($_);
            ($p->$_DOES('PDL::SV') ? $check_labels : $check_indices)->($p);
        }
      } ( @rest > 1 ? @rest : ( undef, $rest[0] ) );
    return ( $row_indexer, $column_indexer );
}

method slice (@rest) : lvalue {
    my ( $rindexer, $cindexer ) = $self->_check_slice_args(@_);

    my $new_df = $self->select_rows($rindexer);
    $new_df = $new_df->select_columns($cindexer);
    return $new_df;
}

=method assign

    assign((DataFrame|Piddle) $x)

Assign another data frame or a piddle to this data frame for in-place change.

C<$x> can be, 

=for :list
*A data frame object having the same dimensions and column names as C<$self>.
*A piddle having the same number of elements as C<$self>.

=cut

method assign ((DataFrame | Piddle) $x) {
    if ( DataFrame->check($x) ) {
        unless ( ( $self->shape == $x->shape )->all ) {
            die "Cannot assign a data frame of different shape.";
        }
        for my $name ( $self->names->flatten ) {
            my $col = $self->at($name);
            $col .= $x->at($name);
        }
    }
    elsif ( $x->$_DOES('PDL') ) {
        my @dims = $self->dims;

        unless ( $x->ndims == 1 and $x->dim(0) == $dims[0] * $dims[1]
            or $x->ndims == 2
            and $x->dim(0) == $dims[0]
            and $x->dim(1) == $dims[1] )
        {
            die;
        }

        for my $i ( 0 .. $self->length - 1 ) {
            $self->_nth_column($i) .=
              $x->flat->slice( pdl( 0 .. $dims[0] - 1 ) + $i * $dims[1] );
        }
    }
    return $self;
}

=method is_numeric_column

    is_numeric_column($column_name_or_idx)

=cut

method is_numeric_column ($column_name_or_idx) {
    my $column = $self->at($column_name_or_idx);
    return !is_discrete($column);
}

=method sort

    sort($by_columns, $ascending=true)

Sort rows for given columns.
Returns a new data frame.

    my $df_sorted1 = $df->sort([qw(a b)], true);
    my $df_sorted2 = $df->sort([qw(a b)], [1, 0]);
    my $df_sorted3 = $df->sort([qw(a b)], pdl([1, 0]));

=cut

method sort ($by_columns, $ascending=true) {
    return $self->clone if $by_columns->length == 0;

    my $row_indices = $self->sorti( $by_columns, $ascending );
    return $self->select_rows($row_indices);
}

method sorti ($by_columns, $ascending=true) {
    if (Ref::Util::is_plain_arrayref($ascending)) {
        $ascending = logical($ascending);
    }

    return pdl( [ 0 .. $self->nrow - 1 ] ) if $by_columns->length == 0;

    my $is_number = $by_columns->map( sub { $self->is_numeric_column($_) } );
    my $compare = sub {
        my ( $a, $b ) = @_;
        for my $i ( 0 .. $#$is_number ) {
            my $rslt = (
                  $is_number->[$i]
                ? $a->[$i] <=> $b->[$i]
                : $a->[$i] cmp $b->[$i]
            );
            next if $rslt == 0;

            my $this_ascending = $ascending->$_call_if_can( 'at', $i )
              // $ascending;
            return ( $this_ascending ? $rslt : -$rslt );
        }
        return 0;
    };

    my $ea =
      each_arrayref( @{ $by_columns->map( sub { $self->at($_)->unpdl } ) } );
    my @sorted_row_indices = map { $_->[0] }
      sort { $compare->( $a->[1], $b->[1] ) }
      map {
        my @row_data = $ea->();
        [ $_, \@row_data ];
      } ( 0 .. $self->nrow - 1 );

    return pdl( \@sorted_row_indices );
}

=method uniq

Returns a new data frame, which has the unique rows. The row names
are from the first occurrance of each unique row in the raw data frame.

=cut

method _serialize_row ($i) {
    state $sereal = Sereal::Encoder->new();
    my @row_data = map { $self->at($_)->at($i) } @{ $self->column_names };
    return $sereal->encode( \@row_data );
}

method uniq () {
    my %uniq;
    my @uniq_ridx;
    for my $i ( 0 .. $self->nrow - 1 ) {
        my $key = $self->_serialize_row($i);
        unless ( exists $uniq{$key} ) {
            $uniq{$key} = 1;
            push @uniq_ridx, $i;
        }
    }
    return $self->select_rows( \@uniq_ridx );
}

=method id

Compute a unique numeric id for each unique row in a data frame.

=cut

method id () {
    my %uniq_serialized;
    my @uniq_rindices;
    for my $ridx ( 0 .. $self->nrow - 1 ) {
        my $key = $self->_serialize_row($ridx);
        if ( not exists $uniq_serialized{$key} ) {
            $uniq_serialized{$key} = [];
            push @uniq_rindices, $ridx;
        }
        push @{ $uniq_serialized{$key} }, $ridx;
    }

    my %rindex_to_serialized = pairmap { $b->[0] => $a } %uniq_serialized;
    my $rindices_sorted =
      $self->select_rows( \@uniq_rindices )->sorti( $self->names );

    my $rslt = PDL::Core::zeros( $self->nrow );
    for my $i ( 1 .. $#uniq_rindices ) {
        my $serialized =
          $rindex_to_serialized{ $uniq_rindices[ $rindices_sorted->at($i) ] };
        my $rindices = $uniq_serialized{$serialized};
        $rslt->slice( pdl($rindices) ) .= $i;
    }
    return $rslt;
}

=method copy

    copy()

Make a deep copy of this data frame object.

=method clone
    
    clone()

This is same as C<copy()>.

=cut

method copy () {
    return ref($self)->new(
        columns   => $self->names->map( sub { $_ => $self->at($_)->copy } ),
        row_names => $self->row_names
    );
}
*clone = \&copy;

method _compare ($other, $mode) {
    my $class = ref($self);

    state $gen_fcompare = sub {
        my ($f) = @_;

        return sub {
            my ( $col, $x ) = @_;
            my $col_isbad = $col->isbad;
            my $x_isbad   = $x->$_call_if_can('isbad') // 1;
            my $both_bad  = ( $col_isbad & $x_isbad );

            my $rslt = $f->( $col, $x );
            return ( $rslt, $both_bad );
        }
    };

    state $fcompare_exact = {
        pairmap { $a => $gen_fcompare->($b) }
        (
            eq => sub { $_[0] == $_[1] },
            ne => sub { $_[0] != $_[1] },
            lt => sub { $_[0] < $_[1] },
            le => sub { $_[0] <= $_[1] },
            gt => sub { $_[0] > $_[1] },
            ge => sub { $_[0] >= $_[1] },
        )
    };

    # Absolute tolerance, calculated from multiplying $TOLERANCE_REL 
    #  with max abs of the two values.
    state $_tolerance = sub {
        my ( $col, $x ) = @_;
        my $a = $col->abs;
        my $b = ref($x) ? $x->abs : abs($x);
        return ifelse( $a > $b, $a, $b ) * $TOLERANCE_REL;
    };

    state $fcompare_float = {
        pairmap { $a => $gen_fcompare->($b) }
        (
            eq => sub { ( $_[0] - $_[1] )->abs < $_tolerance->(@_) },
            ne => sub { ( $_[0] - $_[1] )->abs > $_tolerance->(@_) },
            lt => sub { ( $_[0] - $_[1] ) < $_tolerance->(@_) },
            le => sub { ( $_[0] - $_[1] ) < $_tolerance->(@_) },
            gt => sub { ( $_[0] - $_[1] ) > $_tolerance->(@_) },
        )
    };

    state $same_names = sub {
        my ( $a, $b ) = @_;
        return 0 unless $a->length eq $b->length;
        return (
            List::AllUtils::all { $a->at($_) eq $b->at($_) }
            ( 0 .. $a->length - 1 )
        );
    };

    my $compare_column = sub {
        my ( $name, $x ) = @_;

        my $col = $self->at($name);

        my $fcompare;
        if ( $self->is_numeric_column($name) ) {
            $fcompare =
              (
                not defined $TOLERANCE_REL
                  or ( $col->type < PDL::float
                    and ( !ref($x) and $x->type < PDL::float ) )
              )
              ? $fcompare_exact->{$mode}
              : $fcompare_float->{$mode};
        }
        elsif ( $col->$_DOES('PDL::SV') ) {
            $fcompare = $fcompare_exact->{$mode};
        }
        elsif ( $col->$_DOES('PDL::Factor') ) {
            $fcompare = $fcompare_exact->{$mode};
        }

        unless ($fcompare) {
            die qq{Different types found on column "$name"};
        }

        return $fcompare->( $col, $x );
    };

    my $result_columns;
    if ( $other->$_DOES('Data::Frame::More') ) {
        unless ($same_names->( $self->column_names, $other->column_names )
            and $same_names->( $self->row_names, $other->row_names ) )
        {
            die
"Cannot compare data frame objects of different dimensions or column/row names.";
        }
        $result_columns = {
            $self->names->map(
                sub { $_ => [ $compare_column->( $_, $other->at($_) ) ]; }
            )->flatten
        };
    }
    else {
        unless ( looks_like_number($other)
            or ( $other->$_DOES('PDL') and $other->length == 1 ) )
        {
            die "Cannot compare data frame with non-number or non-data-frame.";
        }
        $result_columns = {
            $self->names->map(
                sub { $_ => [ $compare_column->( $_, $other ) ]; }
            )->flatten
        };
    }

    my $both_bad =
      $class->new( columns =>
          $self->names->map( sub { $_ => $result_columns->{$_}->[1] } ) );
    return $class->with_traits('Data::Frame::More::Role::CompareResult')->new(
        columns =>
          $self->names->map( sub { $_ => $result_columns->{$_}->[0] } ),
        both_bad => $both_bad,
    );
}

=method which

    which(:$bad_to_val=undef, :$ignore_both_bad=true)

Returns a pdl of C<[[col_idx, row_idx], ...]>, like the output of
L<PDL::Primitive/whichND>.

=cut

method which (:$bad_to_val=undef, :$ignore_both_bad=true) {
    my $coordinates = [ 0 .. $self->ncol - 1 ]->map(
        fun($cidx)
        {
            my $column = $self->at( iloc( [$cidx] ) );
            my $both_bad =
                $self->DOES('Data::Frame::More::Role::CompareResult')
              ? $self->both_bad->at( iloc( [$cidx] ) )
              : undef;

            if ( defined $bad_to_val ) {
                $column = $column->setbadtoval($bad_to_val);
            }

            my $indices_false = PDL::Primitive::which(
                defined $both_bad ? ( !$both_bad & $column ) : $column );
            return $indices_false->unpdl->map( sub { [ $_, $cidx ] } )->flatten;
        }
    );
    return pdl($coordinates);
}

=method isempty

    isempty()

Returns true if the data frame has no rows.

=cut

method isempty () { $self->nrow == 0; }

# modified from Data::Frame::string()
method _string () {
    my $rows = [];
    push @$rows, [ '', @{ $self->column_names } ];
    for my $r_idx ( 0 .. $self->number_of_rows - 1 ) {
        my $r = [
            $self->row_names->slice($r_idx)->squeeze->string,
            map {
                my $col = $self->nth_column($_);
                if ($col->$_DOES('PDL::DateTime')) {
                    $col->dt_at($r_idx);
                } else {
                    $col->slice($r_idx)->squeeze->string
                }
            } 0 .. $self->number_of_columns - 1
        ];
        push @$rows, $r;
    }
    {
        # clear column separators
        local $Text::Table::Tiny::COLUMN_SEPARATOR = '';
        local $Text::Table::Tiny::CORNER_MARKER    = '';

        Text::Table::Tiny::table( rows => $rows, header_row => 1 )
    }
}

method string( $row_limit = 10 ) {
    if ( $row_limit < 0 ) {
        $row_limit = $self->nrow;
    }

    my $more_rows = $self->nrow - $row_limit;
    my $df        = $more_rows > 0 ? $self->head($row_limit) : $self;
    my $text      = $df->_string() . "\n";
    if ( $more_rows > 0 ) {
        $text .= "# ... with $more_rows more rows\n";
    }

    return $text;
}

1;

__END__

=head1 SYNOPSIS

    use Data::Frame::More;
    use PDL::Core qw(pdl);

    my $df = Data::Frame::More->new(
            columns => [ a => pdl(0..9), b => pdl(0..9)/10 ] );

    $df->slice([0,1], ['a', 'b']) .= pdl(1,2,3,4);

=head1 DESCRIPTION

=head1 CONSTRUCTION

    my $df = Data::Frame::More->new(
            columns => $columns,
            row_names => $row_names );

When C<columns> is passed an array ref of pairs, then the column data
is added to the data frame in the order that the pairs appear in the 
array ref.

When C<columns> is passed a hadh ref, then the column data is added
to the data frame by the order of keys in the hash ref (sorted with
a stringwise C<cmp>).

=head1 TODO

=begin :list

* Now it does not really support indexing/slicing by row names.
* See if PDL::DateTime can work with this library or not.
* Use hdf5 or sereal to store the example data frames. Now loading from
CSV is slow for a large data set.

=end :list

=head1 SEE ALSO

L<Data::Frame>


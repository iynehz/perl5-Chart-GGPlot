package Chart::GGPlot::Stat::Smooth;

# ABSTRACT: Statistic method that does smoothing

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;
use MooseX::Singleton;

# VERSION

use Data::Frame;
use Module::Load;
use PDL::Core ();
use PDL::MatrixOps ();

use Chart::GGPlot::Layer;
use Chart::GGPlot::Util qw(seq_n);
use Chart::GGPlot::Util::Pod qw(layer_func_pod);

with qw(
  Chart::GGPlot::Stat
);

classmethod required_aes () { [qw(x y)] }

classmethod _parameters () {
    [   
        qw(
          na_rm
          method se n span fullrange level method_args
          )
    ]   
}

my $stat_smooth_pod = layer_func_pod(<<'EOT');

    stat_smooth(:$maping=undef, :$data=undef,
                :$geom='smooth', :$position='identity',
                :$method='auto', :$se=true,
                :$n=80, :$span=0.75, :$fullrange=false, :$level=0.95,
                :$method_args={},
                :$na_rm=false, :$show_legend='auto', :$inherit_aes=true,
                %rest)

    Arguments:
    
    =over 4

    %TMPL_COMMON_ARGS%

    =item * method

    Smoothing method (function) to use.
    
    The available methods are,

    =over 8
    
    =item * 'auto'

    'loess' is used for less than 1000 observations, 'glm' otherwise 

    =item * 'loess'

    Locally Weighted Regression

    Requires L<Math::LOESS>.

    Supported C<$method_args>, (see L<Math::LOESS::Model> for details, )

    =over 12

    =item * $degree

    =item * $parametric
    
    =item * $drop_square

    =item * $normalize

    =item * $family

    =back

    =item * 'glm' : Generalized Linear Model

    Requires L<PDL::Stats::GLM> and L<PDL::GSL::CDF>.

    At this moment we can do only simple linear modeling. To support logistic
    and polynomial in future.

    Supported C<$method_args>,

    =over 12

    =item * $family

    =back

    =back

    =item * method_args

    Additional optional arguments passed on to the modeling function
    defined by C<$method>.

    =item * se

    Display confidence interval around smooth? (true by default, see
    C<$level> to control.)

    =item * fullrange

    Should the fit span the full range of the plot, or just the data?

    =item * level

    Level of confidence interval to use (0.95 by default). Effective when
    C<$se> is true.

    =item * span

    Controls the amount of smoothing for the default loess smoother.
    Larger number means more smoothing. It should be in the C<(0, 1)> range.

    =item * n
        
    Number of points at which to evaluate smoother.

    =back

EOT

my $stat_smooth_code = fun (
    :$maping=undef, :$data=undef,
    :$geom='smooth', :$position='identity',
    :$method='auto', :$se=true,
    :$n=80, :$span=0.75, :$fullrange=false, :$level=0.95,
    :$method_args={},
    :$na_rm=false, :$show_legend='auto', :$inherit_aes=true,
    %rest )
{
    return Chart::GGPlot::Layer->new(
        data        => $data,
        mapping     => $maping,
        stat        => 'smooth',
        geom        => $geom,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        parmas      => {
            method      => $method,
            se          => $se,
            n           => $n,
            fullrange   => $fullrange,
            level       => $level,
            na_rm       => $na_rm,
            method_args => $method_args,
            span        => $span,
            %rest
        },
    );
};

classmethod ggplot_functions() {
    return [
        {
            name => 'stat_smooth',
            code => $stat_smooth_code,
            pod => $stat_smooth_pod,
        },
    ];  
}

classmethod _predictdf($method) {
    my $func = "_predictdf_${method}";
    no strict 'refs';
    unless (exists &{$func}) {
        die "Unsupported smooth method: $method";
    }
    return $func;
}

method setup_params($data, $params) {
    my $method = $params->at('method');
    if ($method eq 'auto') {

        # Use loess for small datasets
        # Based on size of the "largest" group to avoid bad memory
        #  behaviour of loess
        my $data1    = $data->select_columns( [qw(group PANEL)] );
        my $splitted = $data1->split( $data1->id );
        my $max_group =
          List::AllUtils::max( map { $_->nrow } ( values %$splitted ) );

        if ($max_group < 1000) {
            $method = 'loess';
            $params->set('method', $method);
        }

        $log->debugf("geom_smooth() using method = %s", $method);
    }

    # check if method is supported or not
    $self->_predictdf($method);
    return $params;
}
 
around compute_layer( $data, $params, $layout ) {

    # remove all "*_raw" columns, to avoid backends like plotly from
    #  generating wrong hovertext.
    my $data1 = $data->copy;
    for my $colname ( $data1->names->flatten ) {
        if ( $colname =~ /_raw$/ ) {
            $data1->delete($colname);
        }
    }
    $self->$orig( $data1, $params, $layout );
}

method compute_group($data, $scales, $params) {
    my $method      = $params->at('method');
    my $se          = $params->at('se') // true;
    my $n           = $params->at('n') // 80;
    my $span        = $params->at('span') // 0.75;
    my $fullrange   = $params->at('fullrange') // false;
    my $xseq        = $params->at('xseq');
    my $level       = $params->at('level') // 0.95;
    my $method_args = $params->at('method_args') // {};
    my $na_rm       = $params->at('na_rm') // false;

    if ($data->at('x')->uniq->length <  2) {
        # Not enough data to perform fit
        return Data::Frame->new();
    }

    unless (defined $xseq) {
        my $x = $data->at('x');
        if ($x->type < PDL::float) {
            $xseq =
                $fullrange
              ? $scales->at('x')->dimension
              : $x->uniq->qsort;
        }
        else {
            my $range =
                $fullrange
              ? $scales->at('x')->dimension
              : pdl($x->minmax);
            $xseq = seq_n($range->at(0), $range->at(1), $n);
        }
    }

    my $predictdf = $self->_predictdf($method);

    my %base_args = (
        x       => $data->at('x'),
        y       => $data->at('y'),
        weights => (
              $data->exists('weight')
            ? $data->at('weight')
            : PDL::Core::ones( $data->nrow )
        ),
        xseq    => $xseq,
        se      => $se,
        level   => $level,
    );
    if ($method eq 'loess') {
        $method_args->{span} = $span;
    }

    no strict 'refs';
    return $predictdf->( %base_args, %$method_args );
}

fun _predictdf_loess (:$x, :$y, :$weights, :$xseq, :$se, :$level, :$span,
                      :$degree=undef, :$parametric=undef,
                      :$drop_square=undef, :$normalize=undef,
                      :$family=undef) {
    load Math::LOESS;

    my $loess = Math::LOESS->new(
        x            => $x,
        y            => $y,
        weights      => $weights,
        span         => $span,
        maybe family => $family,
    );
    $loess->model->degree($degree)      if defined $degree;
    $loess->model->degree($parametric)  if defined $parametric;
    $loess->model->degree($drop_square) if defined $drop_square;
    $loess->model->degree($normalize)   if defined $normalize;

    $loess->fit();
    my $predict = $loess->predict( $xseq, $se );

    my $ci =
      $se ? $predict->confidence( 1 - $level ) : { fit => $predict->values };
    my @columns = ( x => $xseq, y => $ci->{fit} );
    if ($se) {
        push @columns, ( ymin => $ci->{lower}, ymax => $ci->{upper} );
    }
    return Data::Frame->new( columns => \@columns );
}

fun _predictdf_glm (:$x, :$y, :$xseq, :$se, :$level,
        :$family='gaussian', %rest) {
    load PDL::Stats::GLM;
    load PDL::GSL::CDF;

    my $n = $x->length;
    my %m = PDL::Stats::GLM::ols( $y, $x, { plot => 0 } );

    # fit_t = Xb = pdl($x, [1...])->t x $m{b}->t = $m{b} x pdl($x, [1...])
    my $fit = ( $m{b} x pdl( $xseq, [ (1) x $xseq->length ] ) )->flat;
    my @columns = ( x => $xseq, y => $fit );

    if ($se) {
        my $res            = $y - $m{y_pred};
        my $mse            = ( $res**2 )->sum / ( $y->length - 2 );
        my $residual_scale = sqrt($mse);

        my $se_fit =
          $residual_scale *
          sqrt( 1 / $n +
              $n *
              ( $xseq - $x->average )**2 /
              ( $n * ( $x**2 )->sum - ( $x->sum )**2 ) );

        my $cdf_func = "PDL::GSL::CDF::gsl_cdf_${family}_Pinv";
        no strict 'refs';
        my $t        = $cdf_func->( 1 - ( 1 - $level ) / 2, 1 );

        push @columns,
          ( ymin => $fit - $t * $se_fit, ymax => $fit + $t * $se_fit );
    }

    return Data::Frame->new( columns => \@columns );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Stat>

L<Math::LOESS>

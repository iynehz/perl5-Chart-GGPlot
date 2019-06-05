package Chart::GGPlot::Util::Stats;

# ABSTRACT: Utility statistics functions

use Chart::GGPlot::Setup qw(:base :pdl);

# VERSION

use parent qw(Exporter::Tiny);

use Data::Frame;
use Module::Load;

our @EXPORT_OK = qw(loess glm);

=func loess

=cut

fun loess (:$x, :$y, :$weights, :$xseq, :$se, :$level, :$span,
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

=func glm

=cut

fun glm (:$x, :$y, :$xseq, :$se, :$level,
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

1;

__END__

=head1 DESCRIPTION

Functions in this module are used by L<Chart::GGPlot::Stat::Smooth>.

=head1 SEE ALSO

L<Chart::GGPlot::Stat::Smooth>


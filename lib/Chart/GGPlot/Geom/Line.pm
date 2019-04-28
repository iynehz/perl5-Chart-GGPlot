package Chart::GGPlot::Geom::Line;

# ABSTRACT: Class for line geom

use Chart::GGPlot::Class qw(:pdl);
use namespace::autoclean;

extends qw(Chart::GGPlot::Geom::Path);

# VERSION

use Chart::GGPlot::Layer::Functions qw(layer);

my $geom_line_pod = <<'END_OF_TEXT';

    geom_line(:$mapping = undef, :$data = undef, :$stat = 'identity',
        :$position = 'identity', :$na_rm = false, :$show_legend = 'auto',           :$inherit_aes = true, 
        %rest)

The "line" geom connects the observations in the order of the variable on
the x axis.

END_OF_TEXT

my $geom_line_code = fun (
        :$mapping = undef, :$data = undef,
        :$stat = 'identity', :$position = 'identity',
        :$na_rm = false,
        :$show_legend = 'auto', :$inherit_aes = true,
        %rest )
{
    return layer(
        data        => $data,
        mapping     => $mapping,
        stat        => $stat,
        position    => $position,
        show_legend => $show_legend,
        inherit_aes => $inherit_aes,
        geom        => 'line',
        params      => { na_rm => $na_rm, %rest },
    );
};

classmethod ggplot_functions() {
    return [
        {
            name => 'geom_line',
            code => $geom_line_code,
            pod => $geom_line_pod,
        }
    ];
}

method setup_data ($data, $params) {
    return $data->sort( [qw(PANEL group x)] );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__

=head1 SEE ALSO

L<Chart::GGPlot::Geom>
